From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:53:43 -0400
Message-Id: <20070625195343.21210.57811.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 11/11] Shared Policy: add generic file set/get policy vm ops
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Mapped File Policy 11/11 add generic file set/get policy vm ops

Against 2.6.22-rc4-mm2

Add set/get policy vm ops to generic_file_vm_ops in support of
mmap()ed file memory policies.  This patch effectively "hooks up"
shared file mappings to the NUMA shared policy infrastructure.

NOTE:  we could return an error on an attempt to mbind() a shared,
mapped file when shared_file_policy is disabled instead of just ignoring.
This would change existing behavior in the default case--something
I've tried to avoid--but would let the application/programmer know
that the operation is unsupported.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/filemap.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-06-25 15:03:25.000000000 -0400
+++ Linux/mm/filemap.c	2007-06-25 15:04:37.000000000 -0400
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/mempolicy.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/mempolicy.h>
 
@@ -508,6 +509,42 @@ struct page *__page_cache_alloc(struct a
 	return alloc_page_pol(gfp, pol, pgoff);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
+
+static int generic_file_set_policy(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end,
+			struct mempolicy *new)
+{
+	struct address_space *mapping;
+	struct shared_policy *sp;
+	unsigned long sz;
+	pgoff_t pgoff;
+
+	if (!current->shared_file_policy_enabled)
+		return 0;	/* could [should?] be -EINVAL */
+
+	mapping = vma->vm_file->f_mapping;
+	sp = mapping->spolicy;
+	if (!sp) {
+		sp = mpol_shared_policy_new(mapping, MPOL_DEFAULT, NULL);
+		if (IS_ERR(sp))
+			return PTR_ERR(sp);
+	}
+
+	sz = (end - start) >> PAGE_SHIFT;
+	pgoff = vma_addr_to_pgoff(vma, start, PAGE_SHIFT);
+	return mpol_set_shared_policy(sp, pgoff, sz, new);
+}
+
+static struct mempolicy *
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
@@ -1547,6 +1584,10 @@ EXPORT_SYMBOL(filemap_fault);
 
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
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
