Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAF126B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:41:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l188so27204859pfc.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:41:53 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n10si1831162pgc.242.2017.10.06.15.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:41:52 -0700 (PDT)
Subject: [PATCH v7 02/12] fs, mm: pass fd to ->mmap_validate()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:35:27 -0700
Message-ID: <150732932763.22363.2605808989118835376.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

The MAP_DIRECT mechanism for mmap intends to use a file lease to prevent
block map changes while the file is mapped. It requires the fd to setup
an fasync_struct for signalling lease break events to the lease holder.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/mips/kernel/vdso.c |    2 +-
 arch/tile/mm/elf.c      |    2 +-
 arch/x86/mm/mpx.c       |    3 ++-
 fs/aio.c                |    2 +-
 include/linux/fs.h      |    2 +-
 include/linux/mm.h      |    9 +++++----
 ipc/shm.c               |    3 ++-
 mm/internal.h           |    2 +-
 mm/mmap.c               |   13 +++++++------
 mm/nommu.c              |    5 +++--
 mm/util.c               |    7 ++++---
 11 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index cf10654477a9..ab26c7ac0316 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -110,7 +110,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
 			   VM_READ|VM_WRITE|VM_EXEC|
 			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-			   0, NULL, 0);
+			   0, NULL, 0, -1);
 	if (IS_ERR_VALUE(base)) {
 		ret = base;
 		goto out;
diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 5ffcbe76aef9..61a9588e141a 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -144,7 +144,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 		addr = mmap_region(NULL, addr, INTRPT_SIZE,
 				   VM_READ|VM_EXEC|
 				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0,
-				   NULL, 0);
+				   NULL, 0, -1);
 		if (addr > (unsigned long) -PAGE_SIZE)
 			retval = (int) addr;
 	}
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 9ceaa955d2ba..a8baa94a496b 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -52,7 +52,8 @@ static unsigned long mpx_mmap(unsigned long len)
 
 	down_write(&mm->mmap_sem);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
-		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL);
+			MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate,
+			NULL, -1);
 	up_write(&mm->mmap_sem);
 	if (populate)
 		mm_populate(addr, populate);
diff --git a/fs/aio.c b/fs/aio.c
index 5a2487217072..d10ca6db2ee6 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -519,7 +519,7 @@ static int aio_setup_ring(struct kioctx *ctx, unsigned int nr_events)
 
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
-				       MAP_SHARED, 0, &unused, NULL);
+				       MAP_SHARED, 0, &unused, NULL, -1);
 	up_write(&mm->mmap_sem);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 51538958f7f5..c2b9bf3dc4e9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1702,7 +1702,7 @@ struct file_operations {
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*mmap_validate) (struct file *, struct vm_area_struct *,
-			unsigned long);
+			unsigned long, int);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5c4c98e4adc9..0afa19feb755 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2133,11 +2133,11 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-	struct list_head *uf, unsigned long map_flags);
+	struct list_head *uf, unsigned long map_flags, int fd);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
-	struct list_head *uf);
+	struct list_head *uf, int fd);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
 		     struct list_head *uf);
 
@@ -2145,9 +2145,10 @@ static inline unsigned long
 do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	unsigned long pgoff, unsigned long *populate,
-	struct list_head *uf)
+	struct list_head *uf, int fd)
 {
-	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate, uf);
+	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate,
+			uf, fd);
 }
 
 #ifdef CONFIG_MMU
diff --git a/ipc/shm.c b/ipc/shm.c
index 1e2b1692ba2c..585e05eef40a 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1399,7 +1399,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 			goto invalid;
 	}
 
-	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate, NULL);
+	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate,
+			NULL, -1);
 	*raddr = addr;
 	err = 0;
 	if (IS_ERR_VALUE(addr))
diff --git a/mm/internal.h b/mm/internal.h
index 1df011f62480..70ed7b06dd85 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -466,7 +466,7 @@ extern u32 hwpoison_filter_enable;
 
 extern unsigned long  __must_check vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
-        unsigned long, unsigned long);
+        unsigned long, unsigned long, int);
 
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
diff --git a/mm/mmap.c b/mm/mmap.c
index a1bcaa9eff42..c2cb6334a7a9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1322,7 +1322,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, vm_flags_t vm_flags,
 			unsigned long pgoff, unsigned long *populate,
-			struct list_head *uf)
+			struct list_head *uf, int fd)
 {
 	struct mm_struct *mm = current->mm;
 	int pkey = 0;
@@ -1477,7 +1477,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags, fd);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1527,7 +1527,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, fd);
 out_fput:
 	if (file)
 		fput(file);
@@ -1614,7 +1614,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf, unsigned long map_flags)
+		struct list_head *uf, unsigned long map_flags, int fd)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1700,7 +1700,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		vma->vm_file = get_file(file);
 		if ((map_flags & MAP_TYPE) == MAP_SHARED_VALIDATE)
-			error = file->f_op->mmap_validate(file, vma, map_flags);
+			error = file->f_op->mmap_validate(file, vma,
+					map_flags, fd);
 		else
 			error = call_mmap(file, vma);
 		if (error)
@@ -2842,7 +2843,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 
 	file = get_file(vma->vm_file);
 	ret = do_mmap_pgoff(vma->vm_file, start, size,
-			prot, flags, pgoff, &populate, NULL);
+			prot, flags, pgoff, &populate, NULL, -1);
 	fput(file);
 out:
 	up_write(&mm->mmap_sem);
diff --git a/mm/nommu.c b/mm/nommu.c
index 17c00d93de2e..952d205d3b66 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1206,7 +1206,8 @@ unsigned long do_mmap(struct file *file,
 			vm_flags_t vm_flags,
 			unsigned long pgoff,
 			unsigned long *populate,
-			struct list_head *uf)
+			struct list_head *uf,
+			int fd)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -1439,7 +1440,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, fd);
 
 	if (file)
 		fput(file);
diff --git a/mm/util.c b/mm/util.c
index 34e57fae959d..dcf48d929185 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -319,7 +319,7 @@ EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
-	unsigned long flag, unsigned long pgoff)
+	unsigned long flag, unsigned long pgoff, int fd)
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
@@ -331,7 +331,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 		if (down_write_killable(&mm->mmap_sem))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
-				    &populate, &uf);
+				    &populate, &uf, fd);
 		up_write(&mm->mmap_sem);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
@@ -349,7 +349,8 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
-	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
+	return vm_mmap_pgoff(file, addr, len, prot, flag,
+			offset >> PAGE_SHIFT, -1);
 }
 EXPORT_SYMBOL(vm_mmap);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
