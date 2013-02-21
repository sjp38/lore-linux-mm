Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 5FA6E6B0011
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:22:45 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so4041408dak.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:22:44 -0800 (PST)
Date: Thu, 21 Feb 2013 00:22:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/7] ksm: shrink 32-bit rmap_item back to 32 bytes
In-Reply-To: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1302210020530.17843@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Think of struct rmap_item as an extension of struct page (restricted
to MADV_MERGEABLE areas): there may be a lot of them, we need to keep
them small, especially on 32-bit architectures of limited lowmem.

Siting "int nid" after "unsigned int checksum" works nicely on 64-bit,
making no change to its 64-byte struct rmap_item; but bloats the 32-bit
struct rmap_item from (nicely cache-aligned) 32 bytes to 36 bytes, which
rounds up to 40 bytes once allocated from slab.  We'd better avoid that.

Hey, I only just remembered that the anon_vma pointer in struct rmap_item
has no purpose until the rmap_item is hung from a stable tree node (which
has its own nid field); and rmap_item's nid field no purpose than to say
which tree root to tell rb_erase() when unlinking from an unstable tree.

Double them up in a union.  There's just one place where we set anon_vma
early (when we already hold mmap_sem): now we must remove tree_rmap_item
from its unstable tree there, before overwriting nid.  No need to spatter
BUG()s around: we'd be seeing oopses if this were wrong.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

--- mmotm.orig/mm/ksm.c	2013-02-20 22:28:27.288001480 -0800
+++ mmotm/mm/ksm.c	2013-02-20 22:28:29.688001537 -0800
@@ -150,23 +150,25 @@ struct stable_node {
  * struct rmap_item - reverse mapping item for virtual addresses
  * @rmap_list: next rmap_item in mm_slot's singly-linked rmap_list
  * @anon_vma: pointer to anon_vma for this mm,address, when in stable tree
+ * @nid: NUMA node id of unstable tree in which linked (may not match page)
  * @mm: the memory structure this rmap_item is pointing into
  * @address: the virtual address this rmap_item tracks (+ flags in low bits)
  * @oldchecksum: previous checksum of the page at that virtual address
- * @nid: NUMA node id of unstable tree in which linked (may not match page)
  * @node: rb node of this rmap_item in the unstable tree
  * @head: pointer to stable_node heading this list in the stable tree
  * @hlist: link into hlist of rmap_items hanging off that stable_node
  */
 struct rmap_item {
 	struct rmap_item *rmap_list;
-	struct anon_vma *anon_vma;	/* when stable */
+	union {
+		struct anon_vma *anon_vma;	/* when stable */
+#ifdef CONFIG_NUMA
+		int nid;		/* when node of unstable tree */
+#endif
+	};
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
-#ifdef CONFIG_NUMA
-	int nid;
-#endif
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -1092,6 +1094,9 @@ static int try_to_merge_with_ksm_page(st
 	if (err)
 		goto out;
 
+	/* Unstable nid is in union with stable anon_vma: remove first */
+	remove_rmap_item_from_tree(rmap_item);
+
 	/* Must get reference to anon_vma while still holding mmap_sem */
 	rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
@@ -1466,14 +1471,11 @@ static void cmp_and_merge_page(struct pa
 		kpage = try_to_merge_two_pages(rmap_item, page,
 						tree_rmap_item, tree_page);
 		put_page(tree_page);
-		/*
-		 * As soon as we merge this page, we want to remove the
-		 * rmap_item of the page we have merged with from the unstable
-		 * tree, and insert it instead as new node in the stable tree.
-		 */
 		if (kpage) {
-			remove_rmap_item_from_tree(tree_rmap_item);
-
+			/*
+			 * The pages were successfully merged: insert new
+			 * node in the stable tree and add both rmap_items.
+			 */
 			lock_page(kpage);
 			stable_node = stable_tree_insert(kpage);
 			if (stable_node) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
