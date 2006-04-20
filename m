Subject: [PATCH/RFC] Page Cache Policy V0.0 5/5 - use file policy for page
	cache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:50:47 -0400
Message-Id: <1145566247.10092.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Page Cache Policy V0.0 5/5 - use file policy for page cache

This patch implements a "get_file_policy()" function, analogous
to get_vma_policy(), but for a given file[inode/mapping] at
at specified offset, using the shared_policy, if any, in the
file's address_space.  If no shared policy, returns the default
policy.

Implement alloc_page_pol() to allocate a page given a policy and
an offset.  No vma,addr needed.   alloc_page_pol() duplicated some
of the code in alloc_page_vma(), so this patch revises alloc_page_vma()
to just call alloc_page_pol() after looking up the policy.  This
change rippled into the interleaving functions.  Was able to
eliminate interleave_nid() by computing the offset at the call sites
and calling [modified] offset_il_node() directly.

	#if out interleave_nid() for now.  If noone complains,
	we can remove it.

Enhance page_cache_alloc[_cold]() to use get_file_policy() and
alloc_page_pol().  Because this would have duplicated a fair
bit of code, the patch extracts the common bits into
__page_cache_alloc() and passes the __GFP_COLD flag when called
from page_cache_alloc_cold(), 0 otherwise.

page_cache_alloc[_cold]() now take an additional offset/index
argument, available at all call sites, to lookup the appropriate
policy.  The patches fixes all in kernel users of the modified
interfaces.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/mm/filemap.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/filemap.c	2006-04-20 14:27:12.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/filemap.c	2006-04-20 15:24:53.000000000 -0400
@@ -439,23 +439,48 @@ int add_to_page_cache_lru(struct page *p
 }
 
 #ifdef CONFIG_NUMA
-struct page *page_cache_alloc(struct address_space *x)
+/*
+ * Return effective policy for file [address_space] at pgoff
+ */
+static struct mempolicy *get_file_policy(struct address_space *x, pgoff_t pgoff)
+{
+	struct shared_policy *sp = x->spolicy;
+	struct mempolicy *pol = NULL;
+
+	if (sp)
+		pol = mpol_shared_policy_lookup(sp, pgoff);
+	if (pol)
+		return pol;
+
+	return &default_policy;
+}
+
+static struct page *__page_cache_alloc(struct address_space *x, pgoff_t pgoff,
+					int cold)
 {
-	if (cpuset_do_page_mem_spread()) {
+	struct mempolicy *pol = get_file_policy(x, pgoff);
+	gfp_t gfp = mapping_gfp_mask(x) | cold;
+
+	/*
+	 * Only spread if default policy
+	 */
+	if (pol->policy == MPOL_DEFAULT && cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
-		return alloc_pages_node(n, mapping_gfp_mask(x), 0);
+		return alloc_pages_node(n, gfp, 0);
 	}
-	return alloc_pages(mapping_gfp_mask(x), 0);
+
+	return alloc_page_pol(gfp, pol, pgoff);
+}
+
+struct page *page_cache_alloc(struct address_space *x, pgoff_t pgoff)
+{
+	return __page_cache_alloc(x, pgoff, 0);
 }
 EXPORT_SYMBOL(page_cache_alloc);
 
-struct page *page_cache_alloc_cold(struct address_space *x)
+struct page *page_cache_alloc_cold(struct address_space *x, pgoff_t pgoff)
 {
-	if (cpuset_do_page_mem_spread()) {
-		int n = cpuset_mem_spread_node();
-		return alloc_pages_node(n, mapping_gfp_mask(x)|__GFP_COLD, 0);
-	}
-	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, 0);
+	return __page_cache_alloc(x, pgoff, __GFP_COLD);
 }
 EXPORT_SYMBOL(page_cache_alloc_cold);
 
@@ -973,7 +998,7 @@ no_cached_page:
 		 * page..
 		 */
 		if (!cached_page) {
-			cached_page = page_cache_alloc_cold(mapping);
+			cached_page = page_cache_alloc_cold(mapping, index);
 			if (!cached_page) {
 				desc->error = -ENOMEM;
 				goto out;
@@ -1237,7 +1262,7 @@ static int fastcall page_cache_read(stru
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, offset);
 		if (!page)
 			return -ENOMEM;
 
@@ -1691,7 +1716,7 @@ repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
-			cached_page = page_cache_alloc_cold(mapping);
+			cached_page = page_cache_alloc_cold(mapping, index);
 			if (!cached_page)
 				return ERR_PTR(-ENOMEM);
 		}
@@ -1773,7 +1798,7 @@ repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!*cached_page) {
-			*cached_page = page_cache_alloc(mapping);
+			*cached_page = page_cache_alloc(mapping, index);
 			if (!*cached_page)
 				return NULL;
 		}
Index: linux-2.6.17-rc1-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/gfp.h	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/gfp.h	2006-04-20 14:27:24.000000000 -0400
@@ -133,10 +133,13 @@ alloc_pages(gfp_t gfp_mask, unsigned int
 }
 extern struct page *alloc_page_vma(gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr);
+struct mempolicy;
+extern struct page *alloc_page_pol(gfp_t, struct mempolicy *, pgoff_t);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#define alloc_page_pol(gfp_mask, pol, off)  alloc_pages(gfp_mask, 0)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-20 14:19:14.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-20 14:30:28.000000000 -0400
@@ -1151,9 +1151,8 @@ unsigned slab_node(struct mempolicy *pol
 	}
 }
 
-/* Do static interleaving for a VMA with known offset. */
-static unsigned offset_il_node(struct mempolicy *pol,
-		struct vm_area_struct *vma, unsigned long off)
+/* Do static interleaving for a policy with known offset. */
+static unsigned offset_il_node(struct mempolicy *pol, pgoff_t off)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target = (unsigned)off % nnodes;
@@ -1168,19 +1167,24 @@ static unsigned offset_il_node(struct me
 	return nid;
 }
 
+#if 0
+//TODO:  looks like this is unused after switching to explicit
+//       offsets for interleaving and calling offset_il_node()
+//       directly.  If no-one misses it, we can delete...
 /* Determine a node number for interleave */
 static inline unsigned interleave_nid(struct mempolicy *pol,
-		 struct vm_area_struct *vma, unsigned long addr, int shift)
+		 struct vm_area_struct *vma, pgoff_t off)
 {
 	if (vma) {
 		unsigned long off;
 
 		off = vma->vm_pgoff;
 		off += (addr - vma->vm_start) >> shift;
-		return offset_il_node(pol, vma, off);
+		return offset_il_node(pol, off);
 	} else
 		return interleave_nodes(pol);
 }
+#endif
 
 #ifdef CONFIG_HUGETLBFS
 /* Return a zonelist suitable for a huge page allocation. */
@@ -1191,7 +1195,8 @@ struct zonelist *huge_zonelist(struct vm
 	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
+		nid = offset_il_node(pol,
+				vma_addr_to_pgoff(vma, addr, HPAGE_SHIFT));
 		return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
@@ -1215,6 +1220,23 @@ static struct page *alloc_page_interleav
 	return page;
 }
 
+/*
+ * alloc_page_pol() -- allocate a page based on policy,offset.
+ * Used for mmap()ed file policy allocations where policy is based
+ * on file offset rather than a vma,addr pair
+ */
+struct page *alloc_page_pol(gfp_t gfp, struct mempolicy *pol, pgoff_t pgoff)
+{
+	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+		unsigned nid;
+
+		nid = offset_il_node(pol, pgoff);
+		return alloc_page_interleave(gfp, 0, nid);
+	}
+	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+}
+EXPORT_SYMBOL(alloc_page_pol);
+
 /**
  * 	alloc_page_vma	- Allocate a page for a VMA.
  *
@@ -1244,13 +1266,8 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 
 	cpuset_update_task_memory_state();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
-		unsigned nid;
-
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
-		return alloc_page_interleave(gfp, 0, nid);
-	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return alloc_page_pol(gfp, pol,
+				vma_addr_to_pgoff(vma, addr, PAGE_SHIFT));
 }
 
 /**
Index: linux-2.6.17-rc1-mm2/include/linux/pagemap.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/pagemap.h	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/pagemap.h	2006-04-20 14:27:24.000000000 -0400
@@ -52,15 +52,17 @@ static inline void mapping_set_gfp_mask(
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
-extern struct page *page_cache_alloc(struct address_space *x);
-extern struct page *page_cache_alloc_cold(struct address_space *x);
+extern struct page *page_cache_alloc(struct address_space *, pgoff_t);
+extern struct page *page_cache_alloc_cold(struct address_space *, pgoff_t);
 #else
-static inline struct page *page_cache_alloc(struct address_space *x)
+static inline struct page *page_cache_alloc(struct address_space *x,
+						pgoff_t off)
 {
 	return alloc_pages(mapping_gfp_mask(x), 0);
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
+static inline struct page *page_cache_alloc_cold(struct address_space *x,
+						pgoff_t off)
 {
 	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, 0);
 }
Index: linux-2.6.17-rc1-mm2/drivers/mtd/devices/block2mtd.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/drivers/mtd/devices/block2mtd.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/drivers/mtd/devices/block2mtd.c	2006-04-20 14:27:24.000000000 -0400
@@ -72,7 +72,7 @@ static void cache_readahead(struct addre
 		if (page)
 			continue;
 		read_unlock_irq(&mapping->tree_lock);
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, pagei);
 		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
Index: linux-2.6.17-rc1-mm2/fs/splice.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/fs/splice.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/fs/splice.c	2006-04-20 14:27:24.000000000 -0400
@@ -278,7 +278,7 @@ find_page:
 			/*
 			 * page didn't exist, allocate one
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc_cold(mapping, index);
 			if (!page)
 				break;
 
Index: linux-2.6.17-rc1-mm2/mm/readahead.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/readahead.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/readahead.c	2006-04-20 14:27:24.000000000 -0400
@@ -298,7 +298,7 @@ __do_page_cache_readahead(struct address
 			continue;
 
 		read_unlock_irq(&mapping->tree_lock);
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, page_offset);
 		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
Index: linux-2.6.17-rc1-mm2/fs/ntfs/file.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/fs/ntfs/file.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/fs/ntfs/file.c	2006-04-20 14:27:24.000000000 -0400
@@ -425,7 +425,7 @@ static inline int __ntfs_grab_cache_page
 		pages[nr] = find_lock_page(mapping, index);
 		if (!pages[nr]) {
 			if (!*cached_page) {
-				*cached_page = page_cache_alloc(mapping);
+				*cached_page = page_cache_alloc(mapping, index);
 				if (unlikely(!*cached_page)) {
 					err = -ENOMEM;
 					goto err_out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
