Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D3C746B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 04:45:49 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id wz12so3210002pbc.41
        for <linux-mm@kvack.org>; Sat, 22 Dec 2012 01:45:49 -0800 (PST)
Date: Sat, 22 Dec 2012 01:45:45 -0800
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 10/9] mm: make do_mmap_pgoff return populate as a size in
 bytes, not as a bool
Message-ID: <20121222094545.GA4222@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
 <CALCETrUi4JJSahrDKBARrwGsGE=1RbH8WL4tk1YgDmEowzXtSQ@mail.gmail.com>
 <CANN689H+yOeA3pvBMGu52q7brfoDwtkh0pA==c8VVoCkapkx6g@mail.gmail.com>
 <CALCETrU7u7P67QCwmj4qTMHti1=MXyjy3V9FejWbbrMVi01mDw@mail.gmail.com>
 <CANN689GBCsZWKkAQuNGfF4OJwVOyZ5neUcJo=ajzMKNmFug+XQ@mail.gmail.com>
 <CALCETrUOXjm6uoZ=TwyPr0_EQT-10ko5k448FwGP_dMwb=v=AA@mail.gmail.com>
 <CANN689G-+Dns7BEJVG1SNO_CYA1vCEhiyf7F90sKYPvrNsXN9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689G-+Dns7BEJVG1SNO_CYA1vCEhiyf7F90sKYPvrNsXN9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

do_mmap_pgoff() rounds up the desired size to the next PAGE_SIZE multiple,
however there was no equivalent code in mm_populate(), which caused issues.

This could be fixed by introduced the same rounding in mm_populate(),
however I think it's preferable to make do_mmap_pgoff() return populate
as a size rather than as a boolean, so we don't have to duplicate the
size rounding logic in mm_populate().

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 fs/aio.c           |    5 ++---
 include/linux/mm.h |    2 +-
 ipc/shm.c          |    4 ++--
 mm/mmap.c          |    6 +++---
 mm/nommu.c         |    4 ++--
 mm/util.c          |    6 +++---
 6 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 82eec7c7b4bb..064bfbe37566 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -101,9 +101,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	struct aio_ring *ring;
 	struct aio_ring_info *info = &ctx->ring_info;
 	unsigned nr_events = ctx->max_reqs;
-	unsigned long size;
+	unsigned long size, populate;
 	int nr_pages;
-	bool populate;
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -150,7 +149,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 		return -EAGAIN;
 	}
 	if (populate)
-		mm_populate(info->mmap_base, info->mmap_size);
+		mm_populate(info->mmap_base, populate);
 
 	ctx->user_id = info->mmap_base;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 77311274f0b5..5fe5b86908ab 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1445,7 +1445,7 @@ extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
-	unsigned long pgoff, bool *populate);
+	unsigned long pgoff, unsigned long *populate);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 #ifdef CONFIG_MMU
diff --git a/ipc/shm.c b/ipc/shm.c
index ee2dde1f94d1..2171b3d43943 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -970,7 +970,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	struct shm_file_data *sfd;
 	struct path path;
 	fmode_t f_mode;
-	bool populate = false;
+	unsigned long populate = 0;
 
 	err = -EINVAL;
 	if (shmid < 0)
@@ -1077,7 +1077,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 invalid:
 	up_write(&current->mm->mmap_sem);
 	if (populate)
-		mm_populate(addr, size);
+		mm_populate(addr, populate);
 
 out_fput:
 	fput(file);
diff --git a/mm/mmap.c b/mm/mmap.c
index 27f98850fa8c..0baf8a42b822 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1010,13 +1010,13 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, unsigned long pgoff,
-			bool *populate)
+			unsigned long *populate)
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
 	vm_flags_t vm_flags;
 
-	*populate = false;
+	*populate = 0;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1154,7 +1154,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 
 	addr = mmap_region(file, addr, len, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) && (vm_flags & VM_POPULATE))
-		*populate = true;
+		*populate = len;
 	return addr;
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index d7690b97b81d..0622fb9d083a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1235,7 +1235,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 			    unsigned long prot,
 			    unsigned long flags,
 			    unsigned long pgoff,
-			    bool *populate)
+			    unsigned long *populate)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -1245,7 +1245,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 
 	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
 
-	*populate = false;
+	*populate = 0;
 
 	/* decide whether we should attempt the mapping, and if so what sort of
 	 * mapping */
diff --git a/mm/util.c b/mm/util.c
index 44f006ac2ccd..463ef33b32fa 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -355,7 +355,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
-	bool populate;
+	unsigned long populate;
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
@@ -363,8 +363,8 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate);
 		up_write(&mm->mmap_sem);
-		if (!IS_ERR_VALUE(ret) && populate)
-			mm_populate(ret, len);
+		if (populate)
+			mm_populate(ret, populate);
 	}
 	return ret;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
