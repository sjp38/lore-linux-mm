Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0E8E36B13F1
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:42:29 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3584330bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:42:28 -0800 (PST)
Subject: [PATCH 2/4] shmem: tag swap entries in radix tree
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:42:26 +0400
Message-ID: <20120210194225.6492.26880.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Shmem not uses any radix tree tags. Let's use one of them to mark
swap-entries stored in radix-tree as exceptional entries.
This allows to simplify and speedup truncate and swapoff operations.

Plus put tag manipulation, shmem_unuse(), shmem_unuse_inode() and
shmem_writepage() under CONFIG_SWAP. They are useless without swap.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 4af8e85..b8e5f90 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -76,6 +76,9 @@ static struct vfsmount *shm_mnt;
 /* Symlink up to this size is kmalloc'ed instead of using a swappable page */
 #define SHORT_SYMLINK_LEN 128
 
+/* Radix-tree tag for swap-entries */
+#define SHMEM_TAG_SWAP		0
+
 struct shmem_xattr {
 	struct list_head list;	/* anchored by shmem_inode_info->xattr_list */
 	char *name;		/* xattr name */
@@ -239,9 +242,17 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
 							&mapping->tree_lock);
 	if (item != expected)
 		return -ENOENT;
-	if (replacement)
+	if (replacement) {
+#ifdef CONFIG_SWAP
+		if (radix_tree_exceptional_entry(replacement))
+			radix_tree_tag_set(&mapping->page_tree,
+					index, SHMEM_TAG_SWAP);
+		else if (radix_tree_exceptional_entry(expected))
+			radix_tree_tag_clear(&mapping->page_tree,
+					index, SHMEM_TAG_SWAP);
+#endif
 		radix_tree_replace_slot(pslot, replacement);
-	else
+	} else
 		radix_tree_delete(&mapping->page_tree, index);
 	return 0;
 }
@@ -592,6 +603,8 @@ static void shmem_evict_inode(struct inode *inode)
 	end_writeback(inode);
 }
 
+#ifdef CONFIG_SWAP
+
 /*
  * If swap found in inode, free it and move page from swapcache to filecache.
  */
@@ -760,6 +773,8 @@ redirty:
 	return 0;
 }
 
+#endif /* CONFIG_SWAP */
+
 #ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
@@ -2281,7 +2296,9 @@ static void shmem_destroy_inodecache(void)
 }
 
 static const struct address_space_operations shmem_aops = {
+#ifdef CONFIG_SWAP
 	.writepage	= shmem_writepage,
+#endif
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
 	.write_begin	= shmem_write_begin,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
