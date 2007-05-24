From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:28:51 -0400
Message-Id: <20070524172851.13933.81050.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
References: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 4/8] Mapped File Policy: add generic file set/get policy vm ops
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, clameter@sgi.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Mapped File Policy  4/8 add generic file set/get policy vm ops

Against 2.6.22-rc2-mm1

Add set/get policy vm ops to generic_file_vm_ops in support of
mmap()ed file memory policies.

Note that these ops are identical in all but name to the shmem
policy vm ops as modified by this series.  So, let's try to 
use the generic ones for shmem--but, we'll keep the shmem names
around for now.

Hook up hugetlbfs mappings to the shared policy infrastructure
via the generic_file_vm_ops.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm.h |   12 ++++++++----
 mm/filemap.c       |   28 ++++++++++++++++++++++++++++
 mm/hugetlb.c       |    4 ++++
 mm/shmem.c         |   28 ----------------------------
 4 files changed, 40 insertions(+), 32 deletions(-)

Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-05-23 10:57:09.000000000 -0400
+++ Linux/mm/filemap.c	2007-05-23 11:34:43.000000000 -0400
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/mempolicy.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -478,6 +479,29 @@ struct page *__page_cache_alloc(gfp_t gf
 	return alloc_pages(gfp, 0);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
+
+int generic_file_set_policy(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, struct mempolicy *new)
+{
+	struct shared_policy *sp = vma->vm_file->f_mapping->spolicy;
+
+	if (!sp) {
+		sp = mpol_shared_policy_new(MPOL_DEFAULT, NULL);
+		vma->vm_file->f_mapping->spolicy = sp;
+	}
+	return mpol_set_shared_policy(sp, vma, start, end, new);
+}
+
+struct mempolicy *
+generic_file_get_policy(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct shared_policy *sp = vma->vm_file->f_mapping->spolicy;
+	if (!sp)
+		return NULL;
+
+	return mpol_shared_policy_lookup(sp,
+				 vma_addr_to_pgoff(vma, addr, PAGE_SHIFT));
+}
 #endif
 
 static int __sleep_on_page_lock(void *word)
@@ -1529,6 +1553,10 @@ EXPORT_SYMBOL(filemap_fault);
 
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_NUMA
+	.set_policy     = generic_file_set_policy,
+	.get_policy     = generic_file_get_policy,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-05-23 11:34:40.000000000 -0400
+++ Linux/include/linux/mm.h	2007-05-23 11:34:43.000000000 -0400
@@ -707,10 +707,9 @@ static inline int page_mapped(struct pag
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
-int shmem_set_policy(struct vm_area_struct *, unsigned long, unsigned long,
-			 struct mempolicy *);
-struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
-					unsigned long addr);
+#define shmem_set_policy generic_file_set_policy
+#define shmem_get_policy generic_file_get_policy
+
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
 #else
 static inline int shmem_lock(struct file *file, int lock,
@@ -1066,6 +1065,11 @@ static inline pgoff_t vma_addr_to_pgoff(
 {
 	return ((addr - vma->vm_start) >> shift) + vma->vm_pgoff;
 }
+
+int generic_file_set_policy(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, struct mempolicy *new);
+struct mempolicy *generic_file_get_policy(struct vm_area_struct *vma,
+		unsigned long addr);
 #else
 static inline void setup_per_cpu_pageset(void) {}
 #endif
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-05-23 11:34:40.000000000 -0400
+++ Linux/mm/shmem.c	2007-05-23 11:34:43.000000000 -0400
@@ -1332,34 +1332,6 @@ static struct page *shmem_fault(struct v
 	return page;
 }
 
-#ifdef CONFIG_NUMA
-int shmem_set_policy(struct vm_area_struct *vma, unsigned long start,
-			unsigned long end, struct mempolicy *new)
-{
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	struct shared_policy *sp = mapping_shared_policy(mapping);
-
-	if (!sp) {
-		sp = mpol_shared_policy_new(MPOL_DEFAULT, NULL);
-		set_mapping_shared_policy(mapping, sp);
-	}
-	return mpol_set_shared_policy(sp, vma, start, end, new);
-}
-
-struct mempolicy *
-shmem_get_policy(struct vm_area_struct *vma, unsigned long addr)
-{
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	struct shared_policy *sp = mapping_shared_policy(mapping);
-	unsigned long idx;
-
-	if (!sp)
-		return NULL;
-	idx = vma_addr_to_pgoff(vma, addr, PAGE_SHIFT);
-	return mpol_shared_policy_lookup(sp, idx);
-}
-#endif
-
 int shmem_lock(struct file *file, int lock, struct user_struct *user)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-05-23 11:05:09.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-05-23 11:34:43.000000000 -0400
@@ -326,6 +326,10 @@ static struct page *hugetlb_vm_op_fault(
 
 struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
+#ifdef CONFIG_NUMA
+	.set_policy	= generic_file_set_policy,
+	.get_policy	= generic_file_get_policy,
+#endif
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
