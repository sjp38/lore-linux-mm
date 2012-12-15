Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B8A006B005D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 21:17:42 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2677069pbc.14
        for <linux-mm@kvack.org>; Fri, 14 Dec 2012 18:17:42 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2] mm: Downgrade mmap_sem before locking or populating on mmap
Date: Fri, 14 Dec 2012 18:17:21 -0800
Message-Id: <2e91ea19fbd30fa17718cb293473ae207ee8fd0f.1355536006.git.luto@amacapital.net>
In-Reply-To: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Andy Lutomirski <luto@amacapital.net>

This is a serious cause of mmap_sem contention.  MAP_POPULATE
and MCL_FUTURE, in particular, are disastrous in multithreaded programs.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

Changes from v1:

The non-unlocking versions of do_mmap_pgoff and mmap_region are still
available for aio_setup_ring's benefit.  In theory, aio_setup_ring
would do better with a lock-downgrading version, but that would be
somewhat ugly and doesn't help my workload.

 arch/tile/mm/elf.c |  9 +++---
 fs/aio.c           |  4 +++
 include/linux/mm.h | 19 ++++++++++--
 ipc/shm.c          |  6 ++--
 mm/fremap.c        | 10 ++++--
 mm/mmap.c          | 89 ++++++++++++++++++++++++++++++++++++++++++++++++------
 mm/util.c          |  3 +-
 7 files changed, 117 insertions(+), 23 deletions(-)

diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 3cfa98b..a0441f2 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -129,12 +129,13 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	 */
 	if (!retval) {
 		unsigned long addr = MEM_USER_INTRPT;
-		addr = mmap_region(NULL, addr, INTRPT_SIZE,
-				   MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
-				   VM_READ|VM_EXEC|
-				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
+		addr = mmap_region_unlock(NULL, addr, INTRPT_SIZE,
+					  MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
+					  VM_READ|VM_EXEC|
+					  VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
 		if (addr > (unsigned long) -PAGE_SIZE)
 			retval = (int) addr;
+		return retval;  /* We already unlocked mmap_sem. */
 	}
 #endif
 
diff --git a/fs/aio.c b/fs/aio.c
index 71f613c..253396c 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -127,6 +127,10 @@ static int aio_setup_ring(struct kioctx *ctx)
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
 	down_write(&ctx->mm->mmap_sem);
+	/*
+	 * XXX: If MCL_FUTURE is set, this will hold mmap_sem for write for
+	 *      longer than necessary.
+	 */
 	info->mmap_base = do_mmap_pgoff(NULL, 0, info->mmap_size, 
 					PROT_READ|PROT_WRITE,
 					MAP_ANONYMOUS|MAP_PRIVATE, 0);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..139f636 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1441,14 +1441,27 @@ extern int install_special_mapping(struct mm_struct *mm,
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
+/* These must be called with mmap_sem held for write. */
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff);
-extern unsigned long do_mmap_pgoff(struct file *, unsigned long,
-        unsigned long, unsigned long,
-        unsigned long, unsigned long);
+extern unsigned long do_mmap_pgoff(struct file *, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flags, unsigned long pgoff);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
+/*
+ * These must be called with mmap_sem held for write, and they will release
+ * mmap_sem before they return.  They hold mmap_sem for a shorter time than
+ * the non-unlocking variants.
+ */
+extern unsigned long mmap_region_unlock(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long flags,
+	vm_flags_t vm_flags, unsigned long pgoff);
+extern unsigned long do_mmap_pgoff_unlock(struct file *, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flags, unsigned long pgoff);
+
 /* These take the mm semaphore themselves */
 extern unsigned long vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
diff --git a/ipc/shm.c b/ipc/shm.c
index dff40c9..d0001c8 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1068,12 +1068,14 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
 			goto invalid;
 	}
-		
-	user_addr = do_mmap_pgoff(file, addr, size, prot, flags, 0);
+
+	user_addr = do_mmap_pgoff_unlock(file, addr, size, prot, flags, 0);
 	*raddr = user_addr;
 	err = 0;
 	if (IS_ERR_VALUE(user_addr))
 		err = (long)user_addr;
+	goto out_fput;
+
 invalid:
 	up_write(&current->mm->mmap_sem);
 
diff --git a/mm/fremap.c b/mm/fremap.c
index a0aaf0e..7ebe0a4 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -200,8 +200,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			struct file *file = get_file(vma->vm_file);
 
 			flags &= MAP_NONBLOCK;
-			addr = mmap_region(file, start, size,
-					flags, vma->vm_flags, pgoff);
+			addr = mmap_region_unlock(file, start, size,
+						  flags, vma->vm_flags, pgoff);
 			fput(file);
 			if (IS_ERR_VALUE(addr)) {
 				err = addr;
@@ -209,7 +209,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 				BUG_ON(addr != start);
 				err = 0;
 			}
-			goto out;
+			return err;  /* We already unlocked. */
 		}
 		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
@@ -237,6 +237,10 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			/*
 			 * might be mapping previously unmapped range of file
 			 */
+			if (unlikely(has_write_lock)) {
+				downgrade_write(&mm->mmap_sem);
+				has_write_lock = 0;
+			}
 			mlock_vma_pages_range(vma, start, start + size);
 		} else {
 			if (unlikely(has_write_lock)) {
diff --git a/mm/mmap.c b/mm/mmap.c
index 9a796c4..2dd6b2f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -995,13 +995,22 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 	return hint;
 }
 
+static unsigned long mmap_region_helper(struct file *file, unsigned long addr,
+					unsigned long len, unsigned long flags,
+					vm_flags_t vm_flags,
+                                        unsigned long pgoff, int *downgraded);
+
 /*
  * The caller must hold down_write(&current->mm->mmap_sem).
+ *
+ * If downgraded is non-null, do_mmap_pgoff_helper may downgrade mmap_sem
+ * and write 1 to *downgraded.
  */
-
-unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
-			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff)
+static unsigned long do_mmap_pgoff_helper(
+	struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flags, unsigned long pgoff,
+	int *downgraded)
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
@@ -1127,7 +1136,32 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		}
 	}
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	return mmap_region_helper(file, addr, len, flags, vm_flags, pgoff,
+				  downgraded);
+}
+
+
+unsigned long do_mmap_pgoff_unlock(struct file *file, unsigned long addr,
+				   unsigned long len, unsigned long prot,
+				   unsigned long flags, unsigned long pgoff)
+{
+	int downgraded = 0;
+	unsigned long ret = do_mmap_pgoff_helper(file, addr, len,
+		prot, flags, pgoff, &downgraded);
+
+	if (downgraded)
+		up_read(&current->mm->mmap_sem);
+	else
+		up_write(&current->mm->mmap_sem);
+
+	return ret;
+}
+
+unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+			    unsigned long len, unsigned long prot,
+			    unsigned long flags, unsigned long pgoff)
+{
+	return do_mmap_pgoff_helper(file, addr, len, prot, flags, pgoff, 0);
 }
 
 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
@@ -1240,9 +1274,14 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
-unsigned long mmap_region(struct file *file, unsigned long addr,
-			  unsigned long len, unsigned long flags,
-			  vm_flags_t vm_flags, unsigned long pgoff)
+/*
+ * If downgraded is null, then mmap_sem won't be touched.  Otherwise it
+ * may be downgraded, in which case *downgraded will be set to 1.
+ */
+static unsigned long mmap_region_helper(struct file *file, unsigned long addr,
+					unsigned long len, unsigned long flags,
+					vm_flags_t vm_flags,
+					unsigned long pgoff, int *downgraded)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1373,10 +1412,19 @@ out:
 
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
+		if (downgraded) {
+			downgrade_write(&mm->mmap_sem);
+			*downgraded = 1;
+		}
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm += (len >> PAGE_SHIFT);
-	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK)) {
+		if (downgraded) {
+			downgrade_write(&mm->mmap_sem);
+			*downgraded = 1;
+		}
 		make_pages_present(addr, addr + len);
+	}
 
 	if (file)
 		uprobe_mmap(vma);
@@ -1400,6 +1448,29 @@ unacct_error:
 	return error;
 }
 
+unsigned long mmap_region(struct file *file, unsigned long addr,
+			  unsigned long len, unsigned long flags,
+			  vm_flags_t vm_flags, unsigned long pgoff)
+{
+	return mmap_region_helper(file, addr, len, flags, vm_flags, pgoff, 0);
+}
+
+unsigned long mmap_region_unlock(struct file *file, unsigned long addr,
+				 unsigned long len, unsigned long flags,
+				 vm_flags_t vm_flags, unsigned long pgoff)
+{
+	int downgraded = 0;
+	unsigned long ret = mmap_region_helper(file, addr, len,
+		flags, vm_flags, pgoff, &downgraded);
+
+	if (downgraded)
+		up_read(&current->mm->mmap_sem);
+	else
+		up_write(&current->mm->mmap_sem);
+
+	return ret;
+}
+
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
  *
diff --git a/mm/util.c b/mm/util.c
index dc3036c..fd54884 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -359,8 +359,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
 		down_write(&mm->mmap_sem);
-		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff);
-		up_write(&mm->mmap_sem);
+		ret = do_mmap_pgoff_unlock(file, addr, len, prot, flag, pgoff);
 	}
 	return ret;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
