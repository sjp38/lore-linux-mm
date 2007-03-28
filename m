Date: Wed, 28 Mar 2007 15:52:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/4] holepunch: fix disconnected pages after second truncate
In-Reply-To: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0703281551301.11726@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Badari Pulavarty <pbadari@us.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

shmem_truncate_range has its own truncate_inode_pages_range, to free any
pages racily instantiated while it was in progress: a SHMEM_PAGEIN flag
is set when this might have happened.  But holepunching gets no chance
to clear that flag at the start of vmtruncate_range, so it's always set
(unless a truncate came just before), so holepunch almost always does
this second truncate_inode_pages_range.

shmem holepunch has unlikely swap<->file races hereabouts whatever we do
(without a fuller rework than is fit for this release): I was going to
skip the second truncate in the punch_hole case, but Miklos points out
that would make holepunch correctness more vulnerable to swapoff.  So
keep the second truncate, but follow it by an unmap_mapping_range to
eliminate the disconnected pages (freed from pagecache while still
mapped in userspace) that it might have left behind.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>
Cc: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>
---
This patch can safely go into 2.6.21 and 2.6.21-rc-mm, but Nick's
pagefault/truncation patches in mm do change the rules, so it's
probably overkill there - but there's unmap_mapping_range issues
I need to clarify with Nick before undoing this in mm.

 mm/shmem.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- punch2/mm/shmem.c	2007-03-28 11:50:58.000000000 +0100
+++ punch3/mm/shmem.c	2007-03-28 11:50:59.000000000 +0100
@@ -674,8 +674,16 @@ done2:
 		 * generic_delete_inode did it, before we lowered next_index.
 		 * Also, though shmem_getpage checks i_size before adding to
 		 * cache, no recheck after: so fix the narrow window there too.
+		 *
+		 * Recalling truncate_inode_pages_range and unmap_mapping_range
+		 * every time for punch_hole (which never got a chance to clear
+		 * SHMEM_PAGEIN at the start of vmtruncate_range) is expensive,
+		 * yet hardly ever necessary: try to optimize them out later.
 		 */
 		truncate_inode_pages_range(inode->i_mapping, start, end);
+		if (punch_hole)
+			unmap_mapping_range(inode->i_mapping, start,
+							end - start, 1);
 	}
 
 	spin_lock(&info->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
