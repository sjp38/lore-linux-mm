Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D46846B005A
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 00:50:01 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1221987dak.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2012 21:50:01 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] mm: Downgrade mmap_sem before locking or populating on mmap
Date: Thu, 13 Dec 2012 21:49:43 -0800
Message-Id: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Andy Lutomirski <luto@amacapital.net>

This is a serious cause of mmap_sem contention.  MAP_POPULATE
and MCL_FUTURE, in particular, are disastrous in multithreaded programs.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

Sensible people use anonymous mappings.  I write kernel patches :)

I'm not entirely thrilled by the aesthetics of this patch.  The MAP_POPULATE case
could also be improved by doing it without any lock at all.  This is still a big
improvement, though.

 arch/tile/mm/elf.c |   9 ++--
 fs/aio.c           |   8 ++--
 include/linux/mm.h |   8 ++--
 ipc/shm.c          |   6 ++-
 mm/fremap.c        |  10 ++--
 mm/mmap.c          | 133 +++++++++++++++++++++++++++++++++++++----------------
 mm/util.c          |   3 +-
 7 files changed, 117 insertions(+), 60 deletions(-)

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
index 71f613c..8e2b162 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -127,11 +127,10 @@ static int aio_setup_ring(struct kioctx *ctx)
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
 	down_write(&ctx->mm->mmap_sem);
-	info->mmap_base = do_mmap_pgoff(NULL, 0, info->mmap_size, 
-					PROT_READ|PROT_WRITE,
-					MAP_ANONYMOUS|MAP_PRIVATE, 0);
+	info->mmap_base = do_mmap_pgoff_unlock(NULL, 0, info->mmap_size,
+					       PROT_READ|PROT_WRITE,
+					       MAP_ANONYMOUS|MAP_PRIVATE, 0);
 	if (IS_ERR((void *)info->mmap_base)) {
-		up_write(&ctx->mm->mmap_sem);
 		info->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
@@ -141,7 +140,6 @@ static int aio_setup_ring(struct kioctx *ctx)
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 
 					1, 0, info->ring_pages, NULL);
-	up_write(&ctx->mm->mmap_sem);
 
 	if (unlikely(info->nr_pages != nr_pages)) {
 		aio_free_ring(ctx);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..bb13d11 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1441,12 +1441,12 @@ extern int install_special_mapping(struct mm_struct *mm,
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
-extern unsigned long mmap_region(struct file *file, unsigned long addr,
+extern unsigned long mmap_region_unlock(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff);
-extern unsigned long do_mmap_pgoff(struct file *, unsigned long,
-        unsigned long, unsigned long,
-        unsigned long, unsigned long);
+extern unsigned long do_mmap_pgoff_unlock(struct file *, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flags, unsigned long pgoff);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 /* These take the mm semaphore themselves */
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
index a0aaf0e..232402c 100644
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
+			return err;  /* We just unlocked. */
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
index 9a796c4..d275e05 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -999,7 +999,7 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
  * The caller must hold down_write(&current->mm->mmap_sem).
  */
 
-unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+unsigned long do_mmap_pgoff_unlock(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, unsigned long pgoff)
 {
@@ -1017,31 +1017,39 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
 			prot |= PROT_EXEC;
 
-	if (!len)
-		return -EINVAL;
+	if (!len) {
+		addr = -EINVAL;
+		goto out_unlock;
+	}
 
 	if (!(flags & MAP_FIXED))
 		addr = round_hint_to_min(addr);
 
 	/* Careful about overflows.. */
 	len = PAGE_ALIGN(len);
-	if (!len)
-		return -ENOMEM;
+	if (!len) {
+		addr = -ENOMEM;
+		goto out_unlock;
+	}
 
 	/* offset overflow? */
-	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
-               return -EOVERFLOW;
+	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff) {
+		addr = -EOVERFLOW;
+		goto out_unlock;
+	}
 
 	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count)
-		return -ENOMEM;
+	if (mm->map_count > sysctl_max_map_count) {
+		addr = -ENOMEM;
+		goto out_unlock;
+	}
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
 	addr = get_unmapped_area(file, addr, len, pgoff, flags);
 	if (addr & ~PAGE_MASK)
-		return addr;
+		goto out_unlock;
 
 	/* Do simple checking here so the lower-level routines won't have
 	 * to. we assume access permissions have been handled by the open
@@ -1050,9 +1058,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
-	if (flags & MAP_LOCKED)
-		if (!can_do_mlock())
-			return -EPERM;
+	if (flags & MAP_LOCKED) {
+		if (!can_do_mlock()) {
+			addr = -EPERM;
+			goto out_unlock;
+		}
+	}
 
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
@@ -1061,8 +1072,10 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		locked += mm->locked_vm;
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
-			return -EAGAIN;
+		if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
+			addr = -EAGAIN;
+			goto out_unlock;
+		}
 	}
 
 	inode = file ? file->f_path.dentry->d_inode : NULL;
@@ -1070,21 +1083,27 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (file) {
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
-			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
+			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE)) {
+				addr = -EACCES;
+				goto out_unlock;
+			}
 
 			/*
 			 * Make sure we don't allow writing to an append-only
 			 * file..
 			 */
-			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
-				return -EACCES;
+			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE)) {
+				addr = -EACCES;
+				goto out_unlock;
+			}
 
 			/*
 			 * Make sure there are no mandatory locks on the file.
 			 */
-			if (locks_verify_locked(inode))
-				return -EAGAIN;
+			if (locks_verify_locked(inode)) {
+				addr = -EAGAIN;
+				goto out_unlock;
+			}
 
 			vm_flags |= VM_SHARED | VM_MAYSHARE;
 			if (!(file->f_mode & FMODE_WRITE))
@@ -1092,20 +1111,27 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 
 			/* fall through */
 		case MAP_PRIVATE:
-			if (!(file->f_mode & FMODE_READ))
-				return -EACCES;
+			if (!(file->f_mode & FMODE_READ)) {
+				addr = -EACCES;
+				goto out_unlock;
+			}
 			if (file->f_path.mnt->mnt_flags & MNT_NOEXEC) {
-				if (vm_flags & VM_EXEC)
-					return -EPERM;
+				if (vm_flags & VM_EXEC) {
+					addr = -EPERM;
+					goto out_unlock;
+				}
 				vm_flags &= ~VM_MAYEXEC;
 			}
 
-			if (!file->f_op || !file->f_op->mmap)
-				return -ENODEV;
+			if (!file->f_op || !file->f_op->mmap) {
+				addr = -ENODEV;
+				goto out_unlock;
+			}
 			break;
 
 		default:
-			return -EINVAL;
+			addr = -EINVAL;
+			goto out_unlock;
 		}
 	} else {
 		switch (flags & MAP_TYPE) {
@@ -1123,11 +1149,16 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			pgoff = addr >> PAGE_SHIFT;
 			break;
 		default:
-			return -EINVAL;
+			addr = -EINVAL;
+			goto out_unlock;
 		}
 	}
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	return mmap_region_unlock(file, addr, len, flags, vm_flags, pgoff);
+
+out_unlock:
+	up_write(&mm->mmap_sem);
+	return addr;
 }
 
 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
@@ -1240,9 +1271,9 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
-unsigned long mmap_region(struct file *file, unsigned long addr,
-			  unsigned long len, unsigned long flags,
-			  vm_flags_t vm_flags, unsigned long pgoff)
+unsigned long mmap_region_unlock(struct file *file, unsigned long addr,
+				 unsigned long len, unsigned long flags,
+				 vm_flags_t vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1251,19 +1282,24 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	struct rb_node **rb_link, *rb_parent;
 	unsigned long charged = 0;
 	struct inode *inode =  file ? file->f_path.dentry->d_inode : NULL;
+	bool downgraded = false;
 
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
-		if (do_munmap(mm, addr, len))
-			return -ENOMEM;
+		if (do_munmap(mm, addr, len)) {
+			error = -ENOMEM;
+			goto unacct_error;
+		}
 		goto munmap_back;
 	}
 
 	/* Check against address space limit. */
-	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
-		return -ENOMEM;
+	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
+		error = -ENOMEM;
+		goto unacct_error;
+	}
 
 	/*
 	 * Set 'VM_NORESERVE' if we should not account for the
@@ -1284,8 +1320,10 @@ munmap_back:
 	 */
 	if (accountable_mapping(file, vm_flags)) {
 		charged = len >> PAGE_SHIFT;
-		if (security_vm_enough_memory_mm(mm, charged))
-			return -ENOMEM;
+		if (security_vm_enough_memory_mm(mm, charged)) {
+			error = -ENOMEM;
+			goto unacct_error;
+		}
 		vm_flags |= VM_ACCOUNT;
 	}
 
@@ -1372,15 +1410,27 @@ out:
 	perf_event_mmap(vma);
 
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
+
+	downgraded = false;
 	if (vm_flags & VM_LOCKED) {
+		downgrade_write(&mm->mmap_sem);
+		downgraded = true;
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm += (len >> PAGE_SHIFT);
-	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK)) {
+		downgrade_write(&mm->mmap_sem);
+		downgraded = true;
 		make_pages_present(addr, addr + len);
+	}
 
 	if (file)
 		uprobe_mmap(vma);
 
+	if (downgraded)
+		up_read(&mm->mmap_sem);
+	else
+		up_write(&mm->mmap_sem);
+
 	return addr;
 
 unmap_and_free_vma:
@@ -1397,6 +1447,9 @@ free_vma:
 unacct_error:
 	if (charged)
 		vm_unacct_memory(charged);
+
+	up_write(&mm->mmap_sem);
+
 	return error;
 }
 
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
