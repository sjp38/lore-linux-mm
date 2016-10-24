Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 302976B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:27:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d199so34751442wmd.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:24 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e133si12607718wma.73.2016.10.24.08.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:27:22 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o81so10305510wma.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:22 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [Stable 4.4 - NEEDS REVIEW - 2/3] mm: filemap: don't plant shadow entries without radix tree node
Date: Mon, 24 Oct 2016 17:26:04 +0200
Message-Id: <20161024152605.11707-3-mhocko@kernel.org>
In-Reply-To: <20161024152605.11707-1-mhocko@kernel.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>

From: Johannes Weiner <hannes@cmpxchg.org>

Commit d3798ae8c6f3767c726403c2ca6ecc317752c9dd upstream.

When the underflow checks were added to workingset_node_shadow_dec(),
they triggered immediately:

  kernel BUG at ./include/linux/swap.h:276!
  invalid opcode: 0000 [#1] SMP
  Modules linked in: isofs usb_storage fuse xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_REJECT nf_reject_ipv6
   soundcore wmi acpi_als pinctrl_sunrisepoint kfifo_buf tpm_tis industrialio acpi_pad pinctrl_intel tpm_tis_core tpm nfsd auth_rpcgss nfs_acl lockd grace sunrpc dm_crypt
  CPU: 0 PID: 20929 Comm: blkid Not tainted 4.8.0-rc8-00087-gbe67d60ba944 #1
  Hardware name: System manufacturer System Product Name/Z170-K, BIOS 1803 05/06/2016
  task: ffff8faa93ecd940 task.stack: ffff8faa7f478000
  RIP: page_cache_tree_insert+0xf1/0x100
  Call Trace:
    __add_to_page_cache_locked+0x12e/0x270
    add_to_page_cache_lru+0x4e/0xe0
    mpage_readpages+0x112/0x1d0
    blkdev_readpages+0x1d/0x20
    __do_page_cache_readahead+0x1ad/0x290
    force_page_cache_readahead+0xaa/0x100
    page_cache_sync_readahead+0x3f/0x50
    generic_file_read_iter+0x5af/0x740
    blkdev_read_iter+0x35/0x40
    __vfs_read+0xe1/0x130
    vfs_read+0x96/0x130
    SyS_read+0x55/0xc0
    entry_SYSCALL_64_fastpath+0x13/0x8f
  Code: 03 00 48 8b 5d d8 65 48 33 1c 25 28 00 00 00 44 89 e8 75 19 48 83 c4 18 5b 41 5c 41 5d 41 5e 5d c3 0f 0b 41 bd ef ff ff ff eb d7 <0f> 0b e8 88 68 ef ff 0f 1f 84 00
  RIP  page_cache_tree_insert+0xf1/0x100

This is a long-standing bug in the way shadow entries are accounted in
the radix tree nodes. The shrinker needs to know when radix tree nodes
contain only shadow entries, no pages, so node->count is split in half
to count shadows in the upper bits and pages in the lower bits.

Unfortunately, the radix tree implementation doesn't know of this and
assumes all entries are in node->count. When there is a shadow entry
directly in root->rnode and the tree is later extended, the radix tree
implementation will copy that entry into the new node and and bump its
node->count, i.e. increases the page count bits. Once the shadow gets
removed and we subtract from the upper counter, node->count underflows
and triggers the warning. Afterwards, without node->count reaching 0
again, the radix tree node is leaked.

Limit shadow entries to when we have actual radix tree nodes and can
count them properly. That means we lose the ability to detect refaults
from files that had only the first page faulted in at eviction time.

Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-and-tested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/radix-tree.h |  3 +++
 lib/radix-tree.c           | 14 ++++++++++++++
 mm/filemap.c               | 48 +++++++++++++++++++++-------------------------
 3 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 5d5174b59802..1fe61d2a3875 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -271,6 +271,9 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
+void radix_tree_clear_tags(struct radix_tree_root *root,
+			   struct radix_tree_node *node,
+			   void **slot);
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6b79e9026e24..3ca8be1d1c70 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1430,6 +1430,20 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_delete);
 
+void radix_tree_clear_tags(struct radix_tree_root *root,
+			   struct radix_tree_node *node,
+			   void **slot)
+{
+	if (node) {
+		unsigned int tag, offset = get_slot_offset(node, slot);
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			node_tag_clear(root, node, tag, offset);
+	} else {
+		/* Clear root node tags */
+		root->gfp_mask &= __GFP_BITS_MASK;
+	}
+}
+
 /**
  *	radix_tree_tagged - test whether any items in the tree are tagged
  *	@root:		radix tree root
diff --git a/mm/filemap.c b/mm/filemap.c
index 4cfe423d3e8a..c9c19c12f61d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -155,44 +155,27 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
 	struct radix_tree_node *node;
-	unsigned long index;
-	unsigned int offset;
-	unsigned int tag;
 	void **slot;
 
 	VM_BUG_ON(!PageLocked(page));
 
 	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
 
-	if (shadow) {
-		mapping->nrshadows++;
-		/*
-		 * Make sure the nrshadows update is committed before
-		 * the nrpages update so that final truncate racing
-		 * with reclaim does not see both counters 0 at the
-		 * same time and miss a shadow entry.
-		 */
-		smp_wmb();
-	}
-	mapping->nrpages--;
+	radix_tree_clear_tags(&mapping->page_tree, node, slot);
 
 	if (!node) {
-		/* Clear direct pointer tags in root node */
-		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
-		radix_tree_replace_slot(slot, shadow);
-		return;
-	}
-
-	/* Clear tree tags for the removed page */
-	index = page->index;
-	offset = index & RADIX_TREE_MAP_MASK;
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (test_bit(offset, node->tags[tag]))
-			radix_tree_tag_clear(&mapping->page_tree, index, tag);
+		/*
+		 * We need a node to properly account shadow
+		 * entries. Don't plant any without. XXX
+		 */
+		shadow = NULL;
 	}
 
 	/* Delete page, swap shadow entry */
 	radix_tree_replace_slot(slot, shadow);
+	if (!node)
+		goto out;
+
 	workingset_node_pages_dec(node);
 	if (shadow)
 		workingset_node_shadows_inc(node);
@@ -212,6 +195,19 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		node->private_data = mapping;
 		list_lru_add(&workingset_shadow_nodes, &node->private_list);
 	}
+
+out:
+	if (shadow) {
+		mapping->nrshadows++;
+		/*
+		 * Make sure the nrshadows update is committed before
+		 * the nrpages update so that final truncate racing
+		 * with reclaim does not see both counters 0 at the
+		 * same time and miss a shadow entry.
+		 */
+		smp_wmb();
+	}
+	mapping->nrpages--;
 }
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
