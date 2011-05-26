Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C5BF36B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 06:16:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7F2733EE0BC
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:16:36 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 614F145DECC
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:16:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 38B6945DEC5
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:16:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D9161DB8040
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:16:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E0A021DB803B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:16:35 +0900 (JST)
Message-ID: <4DDE2873.7060409@jp.fujitsu.com>
Date: Thu, 26 May 2011 19:16:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm: don't access vm_flags as 'int'
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: kosaki.motohiro@jp.fujitsu.com

The type of vma->vm_flags is 'unsigned long'. Neither 'int' nor
'unsigned int'. This patch fixes such misuse.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/hugetlbfs/inode.c           |    3 ++-
 fs/proc/task_mmu.c             |    2 +-
 include/linux/hugetlb.h        |    6 +++---
 include/linux/hugetlb_inline.h |    2 +-
 include/linux/mm.h             |    6 +++---
 ipc/shm.c                      |    2 +-
 mm/fremap.c                    |    2 +-
 mm/hugetlb.c                   |    4 ++--
 mm/memory.c                    |    2 +-
 mm/mlock.c                     |    8 ++++----
 mm/mmap.c                      |    8 ++++----
 11 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index e7a0357..1eb08d0 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -921,7 +921,8 @@ static int can_do_hugetlb_shm(void)
 	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }

-struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				unsigned long acctflag,
 				struct user_struct **user, int creat_flags)
 {
 	int error = -ENOMEM;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2c9db29..f0f9d29 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -211,7 +211,7 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct file *file = vma->vm_file;
-	int flags = vma->vm_flags;
+	unsigned long flags = vma->vm_flags;
 	unsigned long ino = 0;
 	unsigned long long pgoff = 0;
 	unsigned long start, end;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 943c76b..a0e0c6a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -41,7 +41,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
-						int acctflags);
+						unsigned long vm_flags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
@@ -168,7 +168,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)

 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t size, int acct,
+struct file *hugetlb_file_setup(const char *name, size_t size, unsigned long acct,
 				struct user_struct **user, int creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
@@ -192,7 +192,7 @@ static inline void set_file_hugepages(struct file *file)
 #define is_file_hugepages(file)			0
 #define set_file_hugepages(file)		BUG()
 static inline struct file *hugetlb_file_setup(const char *name, size_t size,
-		int acctflag, struct user_struct **user, int creat_flags)
+		unsigned long acctflag, struct user_struct **user, int creat_flags)
 {
 	return ERR_PTR(-ENOSYS);
 }
diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 6931489..2bb681f 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -7,7 +7,7 @@

 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
-	return vma->vm_flags & VM_HUGETLB;
+	return !!(vma->vm_flags & VM_HUGETLB);
 }

 #else
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8eb969e..6edc831 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -165,12 +165,12 @@ extern pgprot_t protection_map[16];
  */
 static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
 {
-	return (vma->vm_flags & VM_PFN_AT_MMAP);
+	return !!(vma->vm_flags & VM_PFN_AT_MMAP);
 }

 static inline int is_pfn_mapping(struct vm_area_struct *vma)
 {
-	return (vma->vm_flags & VM_PFNMAP);
+	return !!(vma->vm_flags & VM_PFNMAP);
 }

 /*
@@ -1432,7 +1432,7 @@ extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long flag, unsigned long pgoff);
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
-	unsigned int vm_flags, unsigned long pgoff);
+	unsigned long vm_flags, unsigned long pgoff);

 static inline unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
diff --git a/ipc/shm.c b/ipc/shm.c
index 729acb7..f924655 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -347,7 +347,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	struct file * file;
 	char name[13];
 	int id;
-	int acctflag = 0;
+	unsigned long acctflag = 0;

 	if (size < SHMMIN || size > ns->shm_ctlmax)
 		return -EINVAL;
diff --git a/mm/fremap.c b/mm/fremap.c
index 7f41230..59e677f 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -224,7 +224,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		/*
 		 * drop PG_Mlocked flag for over-mapped range
 		 */
-		unsigned int saved_flags = vma->vm_flags;
+		unsigned long saved_flags = vma->vm_flags;
 		munlock_vma_pages_range(vma, start, start + size);
 		vma->vm_flags = saved_flags;
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5fd68b9..450b59c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2833,7 +2833,7 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 int hugetlb_reserve_pages(struct inode *inode,
 					long from, long to,
 					struct vm_area_struct *vma,
-					int acctflag)
+					unsigned long vm_flags)
 {
 	long ret, chg;
 	struct hstate *h = hstate_inode(inode);
@@ -2843,7 +2843,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * attempt will be made for VM_NORESERVE to allocate a page
 	 * and filesystem quota without using reserves
 	 */
-	if (acctflag & VM_NORESERVE)
+	if (vm_flags & VM_NORESERVE)
 		return 0;

 	/*
diff --git a/mm/memory.c b/mm/memory.c
index b73f677..69cfed5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -730,7 +730,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	add_taint(TAINT_BAD_PAGE);
 }

-static inline int is_cow_mapping(unsigned int flags)
+static inline int is_cow_mapping(unsigned long flags)
 {
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
diff --git a/mm/mlock.c b/mm/mlock.c
index 516b2c2..c92b16c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -307,13 +307,13 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
  * For vmas that pass the filters, merge/split as appropriate.
  */
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
-	unsigned long start, unsigned long end, unsigned int newflags)
+	unsigned long start, unsigned long end, unsigned long newflags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
 	int nr_pages;
 	int ret = 0;
-	int lock = newflags & VM_LOCKED;
+	int lock = !!(newflags & VM_LOCKED);

 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
@@ -385,7 +385,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 		prev = vma;

 	for (nstart = start ; ; ) {
-		unsigned int newflags;
+		unsigned long newflags;

 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */

@@ -524,7 +524,7 @@ static int do_mlockall(int flags)
 		goto out;

 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
-		unsigned int newflags;
+		unsigned long newflags;

 		newflags = vma->vm_flags | VM_LOCKED;
 		if (!(flags & MCL_CURRENT))
diff --git a/mm/mmap.c b/mm/mmap.c
index ac2631b..6ffb885 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -960,7 +960,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
-	unsigned int vm_flags;
+	unsigned long vm_flags;
 	int error;
 	unsigned long reqprot = prot;

@@ -1165,7 +1165,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
  */
 int vma_wants_writenotify(struct vm_area_struct *vma)
 {
-	unsigned int vm_flags = vma->vm_flags;
+	unsigned long vm_flags = vma->vm_flags;

 	/* If it was private or non-writable, the write bit is already clear */
 	if ((vm_flags & (VM_WRITE|VM_SHARED)) != ((VM_WRITE|VM_SHARED)))
@@ -1193,7 +1193,7 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
  * We account for memory if it's a private writeable mapping,
  * not hugepages and VM_NORESERVE wasn't set.
  */
-static inline int accountable_mapping(struct file *file, unsigned int vm_flags)
+static inline int accountable_mapping(struct file *file, unsigned long vm_flags)
 {
 	/*
 	 * hugetlb has its own accounting separate from the core VM
@@ -1207,7 +1207,7 @@ static inline int accountable_mapping(struct file *file, unsigned int vm_flags)

 unsigned long mmap_region(struct file *file, unsigned long addr,
 			  unsigned long len, unsigned long flags,
-			  unsigned int vm_flags, unsigned long pgoff)
+			  unsigned long vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
-- 
1.7.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
