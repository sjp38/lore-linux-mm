Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 354356B0038
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 20:02:44 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id ft15so3219596pdb.23
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 17:02:43 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id tc10si13421320pbc.42.2014.09.21.17.02.40
        for <linux-mm@kvack.org>;
        Sun, 21 Sep 2014 17:02:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 2/5] mm: add full variable in swap_info_struct
Date: Mon, 22 Sep 2014 09:03:08 +0900
Message-Id: <1411344191-2842-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1411344191-2842-1-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, Minchan Kim <minchan@kernel.org>

Now, swap leans on !p->highest_bit to indicate a swap is full.
It works well for normal swap because every slot on swap device
is used up when the swap is full but in case of zram, swap sees
still many empty slot although backed device(ie, zram) is full
since zram's limit is over so that it could make trouble when
swap use highest_bit to select new slot via free_cluster.

This patch introduces full varaiable in swap_info_struct
to solve the problem.

Suggested-by: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  1 +
 mm/swapfile.c        | 33 +++++++++++++++++++--------------
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ea4f926e6b9b..a3c11c051495 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -224,6 +224,7 @@ struct swap_info_struct {
 	struct swap_cluster_info free_cluster_tail; /* free cluster list tail */
 	unsigned int lowest_bit;	/* index of first free in swap_map */
 	unsigned int highest_bit;	/* index of last free in swap_map */
+	bool	full;			/* whether swap is full or not */
 	unsigned int pages;		/* total of usable pages of swap */
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c07f7f4912e9..209112cf8b83 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -558,7 +558,7 @@ checks:
 	}
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
-	if (!si->highest_bit)
+	if (si->full)
 		goto no_page;
 	if (offset > si->highest_bit)
 		scan_base = offset = si->lowest_bit;
@@ -589,6 +589,7 @@ checks:
 		spin_lock(&swap_avail_lock);
 		plist_del(&si->avail_list, &swap_avail_head);
 		spin_unlock(&swap_avail_lock);
+		si->full = true;
 	}
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
@@ -653,14 +654,14 @@ start_over:
 		plist_requeue(&si->avail_list, &swap_avail_head);
 		spin_unlock(&swap_avail_lock);
 		spin_lock(&si->lock);
-		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
+		if (si->full || !(si->flags & SWP_WRITEOK)) {
 			spin_lock(&swap_avail_lock);
 			if (plist_node_empty(&si->avail_list)) {
 				spin_unlock(&si->lock);
 				goto nextsi;
 			}
-			WARN(!si->highest_bit,
-			     "swap_info %d in list but !highest_bit\n",
+			WARN(si->full,
+			     "swap_info %d in list but swap is full\n",
 			     si->type);
 			WARN(!(si->flags & SWP_WRITEOK),
 			     "swap_info %d in list but !SWP_WRITEOK\n",
@@ -796,21 +797,25 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
+		bool was_full;
+
 		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
-		if (offset > p->highest_bit) {
-			bool was_full = !p->highest_bit;
+		if (offset > p->highest_bit)
 			p->highest_bit = offset;
-			if (was_full && (p->flags & SWP_WRITEOK)) {
-				spin_lock(&swap_avail_lock);
-				WARN_ON(!plist_node_empty(&p->avail_list));
-				if (plist_node_empty(&p->avail_list))
-					plist_add(&p->avail_list,
-						  &swap_avail_head);
-				spin_unlock(&swap_avail_lock);
-			}
+		was_full = p->full;
+
+		if (was_full && (p->flags & SWP_WRITEOK)) {
+			spin_lock(&swap_avail_lock);
+			WARN_ON(!plist_node_empty(&p->avail_list));
+			if (plist_node_empty(&p->avail_list))
+				plist_add(&p->avail_list,
+					  &swap_avail_head);
+			spin_unlock(&swap_avail_lock);
+			p->full = false;
 		}
+
 		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
