Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DF4C16B0074
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:16 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2359172pbc.28
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:16 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/9] mm: introduce mm_populate() for populating new vmas
Date: Thu, 20 Dec 2012 16:49:51 -0800
Message-Id: <1356050997-2688-4-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When creating new mappings using the MAP_POPULATE / MAP_LOCKED flags
(or with MCL_FUTURE in effect), we want to populate the pages within the
newly created vmas. This may take a while as we may have to read pages
from disk, so ideally we want to do this outside of the write-locked
mmap_sem region.

This change introduces mm_populate(), which is used to defer populating
such mappings until after the mmap_sem write lock has been released.
This is implemented as a generalization of the former do_mlock_pages(),
which accomplished the same task but was using during mlock() / mlockall().

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Michel Lespinasse <walken@google.com>

---
 fs/aio.c           |    6 +++++-
 include/linux/mm.h |   18 +++++++++++++++---
 ipc/shm.c          |   12 +++++++-----
 mm/mlock.c         |   17 +++++++++++------
 mm/mmap.c          |   20 +++++++++++++++-----
 mm/nommu.c         |    5 ++++-
 mm/util.c          |    6 +++++-
 7 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 71f613cf4a85..82eec7c7b4bb 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -103,6 +103,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	unsigned nr_events = ctx->max_reqs;
 	unsigned long size;
 	int nr_pages;
+	bool populate;
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -129,7 +130,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	down_write(&ctx->mm->mmap_sem);
 	info->mmap_base = do_mmap_pgoff(NULL, 0, info->mmap_size, 
 					PROT_READ|PROT_WRITE,
-					MAP_ANONYMOUS|MAP_PRIVATE, 0);
+					MAP_ANONYMOUS|MAP_PRIVATE, 0,
+					&populate);
 	if (IS_ERR((void *)info->mmap_base)) {
 		up_write(&ctx->mm->mmap_sem);
 		info->mmap_size = 0;
@@ -147,6 +149,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 		aio_free_ring(ctx);
 		return -EAGAIN;
 	}
+	if (populate)
+		mm_populate(info->mmap_base, info->mmap_size);
 
 	ctx->user_id = info->mmap_base;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e6fe91..fea461cd9027 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1444,11 +1444,23 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff);
-extern unsigned long do_mmap_pgoff(struct file *, unsigned long,
-        unsigned long, unsigned long,
-        unsigned long, unsigned long);
+extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot, unsigned long flags,
+	unsigned long pgoff, bool *populate);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
+#ifdef CONFIG_MMU
+extern int __mm_populate(unsigned long addr, unsigned long len,
+			 int ignore_errors);
+static inline void mm_populate(unsigned long addr, unsigned long len)
+{
+	/* Ignore errors */
+	(void) __mm_populate(addr, len, 1);
+}
+#else
+static inline void mm_populate(unsigned long addr, unsigned long len) {}
+#endif
+
 /* These take the mm semaphore themselves */
 extern unsigned long vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
diff --git a/ipc/shm.c b/ipc/shm.c
index dff40c9f73c9..ee2dde1f94d1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -966,11 +966,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	unsigned long flags;
 	unsigned long prot;
 	int acc_mode;
-	unsigned long user_addr;
 	struct ipc_namespace *ns;
 	struct shm_file_data *sfd;
 	struct path path;
 	fmode_t f_mode;
+	bool populate = false;
 
 	err = -EINVAL;
 	if (shmid < 0)
@@ -1069,13 +1069,15 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 			goto invalid;
 	}
 		
-	user_addr = do_mmap_pgoff(file, addr, size, prot, flags, 0);
-	*raddr = user_addr;
+	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate);
+	*raddr = addr;
 	err = 0;
-	if (IS_ERR_VALUE(user_addr))
-		err = (long)user_addr;
+	if (IS_ERR_VALUE(addr))
+		err = (long)addr;
 invalid:
 	up_write(&current->mm->mmap_sem);
+	if (populate)
+		mm_populate(addr, size);
 
 out_fput:
 	fput(file);
diff --git a/mm/mlock.c b/mm/mlock.c
index a2ee45c030fa..7f94bc3b46ef 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -416,7 +416,14 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-static int do_mlock_pages(unsigned long start, size_t len, int ignore_errors)
+/*
+ * __mm_populate - populate and/or mlock pages within a range of address space.
+ *
+ * This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap
+ * flags. VMAs must be already marked with the desired vm_flags, and
+ * mmap_sem must not be held.
+ */
+int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long end, nstart, nend;
@@ -498,7 +505,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 		error = do_mlock(start, len, 1);
 	up_write(&current->mm->mmap_sem);
 	if (!error)
-		error = do_mlock_pages(start, len, 0);
+		error = __mm_populate(start, len, 0);
 	return error;
 }
 
@@ -565,10 +572,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
 	up_write(&current->mm->mmap_sem);
-	if (!ret && (flags & MCL_CURRENT)) {
-		/* Ignore errors */
-		do_mlock_pages(0, TASK_SIZE, 1);
-	}
+	if (!ret && (flags & MCL_CURRENT))
+		mm_populate(0, TASK_SIZE);
 out:
 	return ret;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index 9a796c41e7d9..a16fc499dbd1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1001,12 +1001,15 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 
 unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff)
+			unsigned long flags, unsigned long pgoff,
+			bool *populate)
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
 	vm_flags_t vm_flags;
 
+	*populate = false;
+
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
 	 *
@@ -1127,7 +1130,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		}
 	}
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	addr = mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	if (!IS_ERR_VALUE(addr) &&
+	    ((vm_flags & VM_LOCKED) ||
+	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
+		*populate = true;
+	return addr;
 }
 
 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
@@ -1373,10 +1381,12 @@ out:
 
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		if (!mlock_vma_pages_range(vma, addr, addr + len))
+		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
+					vma == get_gate_vma(current->mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
-	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
-		make_pages_present(addr, addr + len);
+		else
+			vma->vm_flags &= ~VM_LOCKED;
+	}
 
 	if (file)
 		uprobe_mmap(vma);
diff --git a/mm/nommu.c b/mm/nommu.c
index 45131b41bcdb..d7690b97b81d 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1234,7 +1234,8 @@ unsigned long do_mmap_pgoff(struct file *file,
 			    unsigned long len,
 			    unsigned long prot,
 			    unsigned long flags,
-			    unsigned long pgoff)
+			    unsigned long pgoff,
+			    bool *populate)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -1244,6 +1245,8 @@ unsigned long do_mmap_pgoff(struct file *file,
 
 	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
 
+	*populate = false;
+
 	/* decide whether we should attempt the mapping, and if so what sort of
 	 * mapping */
 	ret = validate_mmap_request(file, addr, len, prot, flags, pgoff,
diff --git a/mm/util.c b/mm/util.c
index dc3036cdcc6a..44f006ac2ccd 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -355,12 +355,16 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
+	bool populate;
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
 		down_write(&mm->mmap_sem);
-		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff);
+		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
+				    &populate);
 		up_write(&mm->mmap_sem);
+		if (!IS_ERR_VALUE(ret) && populate)
+			mm_populate(ret, len);
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
