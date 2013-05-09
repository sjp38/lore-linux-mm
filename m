Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6C1D56B006E
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:52:10 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id g12so3114293oah.40
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:52:09 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 6/6] mm : add new option MREMAP_DUP to mremap() syscall
Date: Thu,  9 May 2013 17:50:11 +0800
Message-Id: <1368093011-4867-7-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

This option allow user space program getting a mirror for
mem, that is two virtual mapping. The content is COW so
it can be used for snapshot a region of mem.

Now shared memory is not COWED yet.

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 include/uapi/linux/mman.h |    1 +
 mm/mremap.c               |  103 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
index ade4acd..5cf7816 100644
--- a/include/uapi/linux/mman.h
+++ b/include/uapi/linux/mman.h
@@ -5,6 +5,7 @@
 
 #define MREMAP_MAYMOVE	1
 #define MREMAP_FIXED	2
+#define MREMAP_DUP	4
 
 #define OVERCOMMIT_GUESS		0
 #define OVERCOMMIT_ALWAYS		1
diff --git a/mm/mremap.c b/mm/mremap.c
index 2cc1cae..f6cc29f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -391,6 +391,45 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	return new_addr;
 }
 
+static unsigned long dup_vma(struct vm_area_struct *vma,
+			     unsigned long old_addr, unsigned long new_addr,
+			     unsigned long len, bool *locked)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct vm_area_struct *new_vma;
+	unsigned long vm_flags = vma->vm_flags;
+	unsigned long new_pgoff;
+	unsigned long duped_len;
+	int err;
+	bool need_rmap_locks;
+
+	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
+	new_vma = copy_vma(&vma, new_addr, len, new_pgoff,
+			   &need_rmap_locks);
+	if (!new_vma)
+		return -ENOMEM;
+
+	duped_len = move_page_tables(vma, old_addr, new_vma, new_addr, len,
+				     need_rmap_locks, false);
+	if (duped_len < len) {
+		/* remove new duplicated area */
+		move_page_tables(new_vma, new_addr, vma, old_addr, duped_len,
+				 true, true);
+		err = do_munmap(mm, new_addr, duped_len);
+		VM_BUG_ON(err < 0);
+		return -ENOMEM;
+	}
+
+	vm_stat_account(mm, vma->vm_flags, vma->vm_file, len>>PAGE_SHIFT);
+
+	if (vm_flags & VM_LOCKED) {
+		mm->locked_vm += len >> PAGE_SHIFT;
+		*locked = true;
+	}
+
+	return new_addr;
+}
+
 static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	unsigned long old_len, unsigned long new_len, unsigned long *p)
 {
@@ -511,6 +550,59 @@ out:
 	return ret;
 }
 
+static unsigned long mremap_dup(unsigned long old_addr, unsigned long new_addr,
+				unsigned long len, unsigned long flags,
+				bool *locked)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long ret = -EINVAL, map_flags = 0;
+
+	if (flags & MREMAP_FIXED) {
+		if (new_addr & ~PAGE_MASK)
+			goto out;
+		if (len > TASK_SIZE || new_addr > TASK_SIZE - len)
+			goto out;
+		/* Overlap */
+		if ((new_addr <= old_addr) && (new_addr + len) > old_addr)
+			goto out;
+		if ((old_addr <= new_addr) && (old_addr + len) > new_addr)
+			goto out;
+
+		map_flags = MAP_FIXED;
+	} else {
+		new_addr = 0;
+	}
+
+	vma = find_vma(mm, old_addr);
+
+	/* We can't remap across vm area boundaries */
+	if (!vma || vma->vm_start > old_addr || len > vma->vm_end - old_addr)
+		goto out;
+
+	/* Currently, shared mem can't be cowed */
+	if (vma->vm_flags & VM_MAYSHARE)
+		map_flags |= MAP_SHARED;
+
+	ret = get_unmapped_area(vma->vm_file, new_addr, len, vma->vm_pgoff +
+				((old_addr - vma->vm_start) >> PAGE_SHIFT),
+				map_flags);
+	if (ret & ~PAGE_MASK)
+		goto out;
+
+	new_addr = ret;
+
+	/* for debug */
+	printk(KERN_WARNING
+		"mremap dup %lx with len %lx to %lx, original vm_flag %lx.",
+		old_addr, len, new_addr, vma->vm_flags);
+
+	ret = dup_vma(vma, old_addr, new_addr, len, locked);
+
+out:
+	return ret;
+}
+
 static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 {
 	unsigned long end = vma->vm_end + delta;
@@ -543,7 +635,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	down_write(&current->mm->mmap_sem);
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_DUP))
 		goto out;
 
 	if (addr & ~PAGE_MASK)
@@ -552,6 +644,10 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	old_len = PAGE_ALIGN(old_len);
 	new_len = PAGE_ALIGN(new_len);
 
+	if (flags & MREMAP_DUP) {
+		ret = mremap_dup(addr, new_addr, old_len, flags, &locked);
+		goto out;
+	}
 	/*
 	 * We allow a zero old-len as a special case
 	 * for DOS-emu "duplicate shm area" thing. But
@@ -638,7 +734,10 @@ out:
 	if (ret & ~PAGE_MASK)
 		vm_unacct_memory(charged);
 	up_write(&current->mm->mmap_sem);
-	if (locked && new_len > old_len)
+	/* locked == true only when operation success */
+	if ((flags & MREMAP_DUP) && (!IS_ERR_VALUE(ret)) && locked)
+		mm_populate(ret, old_len);
+	else if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	return ret;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
