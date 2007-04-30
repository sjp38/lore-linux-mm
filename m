Date: Sun, 29 Apr 2007 23:17:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: page migration: Only migrate pages if allocation in the highest zone
 is possible
Message-ID: <Pine.LNX.4.64.0704292316040.3036@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Address spaces contain an allocation flag that specifies restriction on
the zone for pages placed in the mapping. I.e. some device may require pages
to be allocated from a DMA zone. Block devices may not be able to use pages
from HIGHMEM.

Memory policies and the common use of page migration works only on the
highest zone. If the address space does not allow allocation from the
highest zone then the pages in the address space are not migratable simply
because we can only allocate memory for a specified node if we allow
allocation for the highest zone on each node.

Cc: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/migrate.h |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-2.6.21-rc7-mm2/include/linux/migrate.h
===================================================================
--- linux-2.6.21-rc7-mm2.orig/include/linux/migrate.h	2007-04-15 16:50:57.000000000 -0700
+++ linux-2.6.21-rc7-mm2/include/linux/migrate.h	2007-04-27 23:14:49.000000000 -0700
@@ -2,6 +2,7 @@
 #define _LINUX_MIGRATE_H
 
 #include <linux/mm.h>
+#include <linux/mempolicy.h>
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
@@ -10,6 +11,14 @@ static inline int vma_migratable(struct 
 {
 	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
 		return 0;
+	/*
+	 * Migration allocates pages in the highest zone. If we cannot
+	 * do so then migration (at least from node to node) is not
+	 * possible.
+	 */
+	if (vma->vm_file && vma->vm_file->f_mapping &&
+		gfp_zone(vma->vm_file->f_mapping->flags) < policy_zone)
+			return 0;
 	return 1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
