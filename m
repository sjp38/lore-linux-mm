Subject: [PATCH/RFC] Page Cache Policy V0.0 4/5 add generic file set/get
	policy vm ops
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:49:03 -0400
Message-Id: <1145566143.10092.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Page Cache Policy V0.0 4/5 add generic file set/get policy vm ops

Add set/get policy vm ops to generic_file_vm_ops in support of
mmap()ed file memory policies.

Note that these ops are identical in all but name to the shmem
policy vm ops as modified by this series.  Perhaps shmem could
use the "generic" ones if this series is eventually accepted.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/mm/filemap.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/filemap.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/filemap.c	2006-04-20 14:27:12.000000000 -0400
@@ -31,6 +31,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/mempolicy.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -457,6 +458,29 @@ struct page *page_cache_alloc_cold(struc
 	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, 0);
 }
 EXPORT_SYMBOL(page_cache_alloc_cold);
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
 
 /*
@@ -1614,6 +1638,10 @@ EXPORT_SYMBOL(filemap_populate);
 struct vm_operations_struct generic_file_vm_ops = {
 	.nopage		= filemap_nopage,
 	.populate	= filemap_populate,
+#ifdef CONFIG_NUMA
+	.set_policy     = generic_file_set_policy,
+	.get_policy     = generic_file_get_policy,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
