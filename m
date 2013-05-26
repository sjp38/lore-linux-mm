Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D6F926B005A
	for <linux-mm@kvack.org>; Sun, 26 May 2013 00:32:12 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 01/02] swap: discard while swapping only if SWAP_FLAG_DISCARD_PAGES
Date: Sun, 26 May 2013 01:31:55 -0300
Message-Id: <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
In-Reply-To: <cover.1369529143.git.aquini@redhat.com>
References: <cover.1369529143.git.aquini@redhat.com>
In-Reply-To: <cover.1369529143.git.aquini@redhat.com>
References: <cover.1369529143.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, kosaki.motohiro@gmail.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

This patch introduces SWAP_FLAG_DISCARD_PAGES and SWAP_FLAG_DISCARD_ONCE
new flags to allow more flexibe swap discard policies being flagged through
swapon(8). The default behavior is to keep both single-time, or batched, area
discards (SWAP_FLAG_DISCARD_ONCE) and fine-grained discards for page-clusters
(SWAP_FLAG_DISCARD_PAGES) enabled, in order to keep consistentcy with older
kernel behavior, as well as maintain compatibility with older swapon(8).
However, through the new introduced flags the best suitable discard policy 
can be selected accordingly to any given swap device constraint.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/swap.h | 13 +++++++++----
 mm/swapfile.c        | 55 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1701ce4..33fa21f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -19,10 +19,13 @@ struct bio;
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
-#define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
+#define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
+#define SWAP_FLAG_DISCARD_ONCE	0x20000 /* discard swap area at swapon-time */
+#define SWAP_FLAG_DISCARD_PAGES 0x40000 /* discard page-clusters after use */
 
 #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
-				 SWAP_FLAG_DISCARD)
+				 SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
+				 SWAP_FLAG_DISCARD_PAGES)
 
 static inline int current_is_kswapd(void)
 {
@@ -146,14 +149,16 @@ struct swap_extent {
 enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
-	SWP_DISCARDABLE = (1 << 2),	/* swapon+blkdev support discard */
+	SWP_DISCARDABLE = (1 << 2),	/* blkdev support discard */
 	SWP_DISCARDING	= (1 << 3),	/* now discarding a free cluster */
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
 	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
+	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
+	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 10),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c340d9..719513d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -212,7 +212,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-		if (si->flags & SWP_DISCARDABLE) {
+		if (si->flags & SWP_PAGE_DISCARD) {
 			/*
 			 * Start range check on racing allocations, in case
 			 * they overlap the cluster we eventually decide on
@@ -322,7 +322,7 @@ checks:
 
 	if (si->lowest_alloc) {
 		/*
-		 * Only set when SWP_DISCARDABLE, and there's a scan
+		 * Only set when SWP_PAGE_DISCARD, and there's a scan
 		 * for a free cluster in progress or just completed.
 		 */
 		if (found_free_cluster) {
@@ -2016,6 +2016,20 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 	return nr_extents;
 }
 
+/*
+ * Helper to sys_swapon determining if a given swap
+ * backing device queue supports DISCARD operations.
+ */
+static bool swap_discardable(struct swap_info_struct *si)
+{
+	struct request_queue *q = bdev_get_queue(si->bdev);
+
+	if (!q || !blk_queue_discard(q))
+		return false;
+
+	return true;
+}
+
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
@@ -2123,8 +2137,37 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			p->flags |= SWP_SOLIDSTATE;
 			p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		}
-		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
-			p->flags |= SWP_DISCARDABLE;
+
+		if ((swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
+			/*
+			 * When discard is enabled for swap, with no particular
+			 * policy flagged, we set all swap discard flags here
+			 * in order to sustain backward compatibility with
+			 * older swapon(8) releases.
+			 */
+			p->flags |= (SWP_DISCARDABLE | SWP_AREA_DISCARD |
+				     SWP_PAGE_DISCARD);
+
+			/*
+			 * By flagging sys_swapon, a sysadmin can tell us to
+			 * either do sinle-time area discards only, or to just
+			 * perform discards for released swap page-clusters.
+			 * Now it's time to adjust the p->flags accordingly.
+			 */
+			if (swap_flags & SWAP_FLAG_DISCARD_ONCE)
+				p->flags &= ~SWP_PAGE_DISCARD;
+			else if (swap_flags & SWAP_FLAG_DISCARD_PAGES)
+				p->flags &= ~SWP_AREA_DISCARD;
+
+			/* issue a swapon-time discard if it's still required */
+			if (p->flags & SWP_AREA_DISCARD) {
+				int err = discard_swap(p);
+				if (unlikely(err))
+					printk(KERN_ERR
+					       "swapon: discard_swap(%p): %d\n",
+						p, err);
+			}
+		}
 	}
 
 	mutex_lock(&swapon_mutex);
@@ -2135,11 +2178,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	enable_swap_info(p, prio, swap_map, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s%s%s%s\n",
 		p->pages<<(PAGE_SHIFT-10), name->name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
 		(p->flags & SWP_DISCARDABLE) ? "D" : "",
+		(p->flags & SWP_AREA_DISCARD) ? "s" : "",
+		(p->flags & SWP_PAGE_DISCARD) ? "c" : "",
 		(frontswap_map) ? "FS" : "");
 
 	mutex_unlock(&swapon_mutex);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
