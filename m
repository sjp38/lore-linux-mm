Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E64885F0008
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:42 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:36 -0700
Message-Id: <1243893048-17031-11-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 11/23] mm: Teach mmap to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 mm/mmap.c  |   78 +++++++++++++++++++++++++++++++++++++++--------------------
 mm/nommu.c |   21 +++++++++++++++-
 2 files changed, 71 insertions(+), 28 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6b7b1a9..f13251a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -914,9 +914,13 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
 	unsigned int vm_flags;
-	int error;
+	unsigned long retval;
 	unsigned long reqprot = prot;
 
+	retval = -EIO;
+	if (file && !file_hotplug_read_trylock(file))
+		goto out;
+
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
 	 *
@@ -927,35 +931,40 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
 			prot |= PROT_EXEC;
 
+	retval = -EINVAL;
 	if (!len)
-		return -EINVAL;
+		goto out_unlock;
 
 	if (!(flags & MAP_FIXED))
 		addr = round_hint_to_min(addr);
 
-	error = arch_mmap_check(addr, len, flags);
-	if (error)
-		return error;
+	retval = arch_mmap_check(addr, len, flags);
+	if (retval)
+		goto out_unlock;
 
 	/* Careful about overflows.. */
+	retval = -ENOMEM;
 	len = PAGE_ALIGN(len);
 	if (!len || len > TASK_SIZE)
-		return -ENOMEM;
+		goto out_unlock;
 
 	/* offset overflow? */
+	retval = -EOVERFLOW;
 	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
-               return -EOVERFLOW;
+		goto out_unlock;
 
 	/* Too many mappings? */
+	retval = -ENOMEM;
 	if (mm->map_count > sysctl_max_map_count)
-		return -ENOMEM;
+		goto out_unlock;
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
 	addr = get_unmapped_area(file, addr, len, pgoff, flags);
+	retval = addr;
 	if (addr & ~PAGE_MASK)
-		return addr;
+		goto out_unlock;
 
 	/* Do simple checking here so the lower-level routines won't have
 	 * to. we assume access permissions have been handled by the open
@@ -965,8 +974,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED) {
+		retval = -EPERM;
 		if (!can_do_mlock())
-			return -EPERM;
+			goto out_unlock;
 		vm_flags |= VM_LOCKED;
 	}
 
@@ -977,8 +987,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		locked += mm->locked_vm;
 		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
 		lock_limit >>= PAGE_SHIFT;
+		retval = -EAGAIN;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
-			return -EAGAIN;
+			goto out_unlock;
 	}
 
 	inode = file ? file->f_path.dentry->d_inode : NULL;
@@ -986,21 +997,24 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (file) {
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
+			retval = -EACCES;
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
+				goto out_unlock;
 
 			/*
 			 * Make sure we don't allow writing to an append-only
 			 * file..
 			 */
+			retval = -EACCES;
 			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
-				return -EACCES;
+				goto out_unlock;
 
 			/*
 			 * Make sure there are no mandatory locks on the file.
 			 */
+			retval = -EAGAIN;
 			if (locks_verify_locked(inode))
-				return -EAGAIN;
+				goto out_unlock;
 
 			vm_flags |= VM_SHARED | VM_MAYSHARE;
 			if (!(file->f_mode & FMODE_WRITE))
@@ -1008,20 +1022,24 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 
 			/* fall through */
 		case MAP_PRIVATE:
+			retval = -EACCES;
 			if (!(file->f_mode & FMODE_READ))
-				return -EACCES;
+				goto out_unlock;
 			if (file->f_path.mnt->mnt_flags & MNT_NOEXEC) {
+				retval = -EPERM;
 				if (vm_flags & VM_EXEC)
-					return -EPERM;
+					goto out_unlock;
 				vm_flags &= ~VM_MAYEXEC;
 			}
 
+			retval = -ENODEV;
 			if (!file->f_op || !file->f_op->mmap)
-				return -ENODEV;
+				goto out_unlock;
 			break;
 
 		default:
-			return -EINVAL;
+			retval = -EINVAL;
+			goto out_unlock;
 		}
 	} else {
 		switch (flags & MAP_TYPE) {
@@ -1039,18 +1057,24 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			pgoff = addr >> PAGE_SHIFT;
 			break;
 		default:
-			return -EINVAL;
+			retval = -EINVAL;
+			goto out_unlock;
 		}
 	}
 
-	error = security_file_mmap(file, reqprot, prot, flags, addr, 0);
-	if (error)
-		return error;
-	error = ima_file_mmap(file, prot);
-	if (error)
-		return error;
+	retval = security_file_mmap(file, reqprot, prot, flags, addr, 0);
+	if (retval)
+		goto out_unlock;
+	retval = ima_file_mmap(file, prot);
+	if (retval)
+		goto out_unlock;
+	retval = mmap_region(file, addr, len, flags, vm_flags, pgoff);
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+out_unlock:
+	if (file)
+		file_hotplug_read_unlock(file);
+out:
+	return retval;
 }
 EXPORT_SYMBOL(do_mmap_pgoff);
 
diff --git a/mm/nommu.c b/mm/nommu.c
index b571ef7..08038b7 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1165,7 +1165,7 @@ enomem:
 /*
  * handle mapping creation for uClinux
  */
-unsigned long do_mmap_pgoff(struct file *file,
+static unsigned long __do_mmap_pgoff(struct file *file,
 			    unsigned long addr,
 			    unsigned long len,
 			    unsigned long prot,
@@ -1402,6 +1402,25 @@ error_getting_region:
 	show_free_areas();
 	return -ENOMEM;
 }
+
+unsigned long do_mmap_pgoff(struct file *file,
+			    unsigned long addr,
+			    unsigned long len,
+			    unsigned long prot,
+			    unsigned long flags,
+			    unsigned long pgoff)
+{
+	unsigned long result = -EIO;
+	if (file && !file_hotplug_read_trylock(file))
+		goto out;
+
+	result = __do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+
+	if (file)
+		file_hotplug_read_unlock(file);
+out:
+	return result;
+}
 EXPORT_SYMBOL(do_mmap_pgoff);
 
 /*
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
