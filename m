Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C79D06B0033
	for <linux-mm@kvack.org>; Mon, 20 May 2013 20:04:39 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [RFC PATCH 01/02] swap: discard while swapping only if SWAP_FLAG_DISCARD_CLUSTER
Date: Mon, 20 May 2013 21:04:24 -0300
Message-Id: <e3ae11727f13e1580ae66ce80845e9002ec90ea6.1369092449.git.aquini@redhat.com>
In-Reply-To: <cover.1369092449.git.aquini@redhat.com>
References: <cover.1369092449.git.aquini@redhat.com>
In-Reply-To: <cover.1369092449.git.aquini@redhat.com>
References: <cover.1369092449.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

Intruduce a new flag to make page-cluster fine-grained discards while swapping
conditional, as they can be considered detrimental to some setups. However,
keep allowing batched discards at sys_swapon() time, when enabled by the
system administrator. 

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/swap.h |  8 +++++---
 mm/swapfile.c        | 12 ++++++++----
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1701ce4..ab2e742 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -19,10 +19,11 @@ struct bio;
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
-#define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
+#define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap areas */
+#define SWAP_FLAG_DISCARD_CLUSTER 0x20000 /* discard swap clusters after use */
 
 #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
-				 SWAP_FLAG_DISCARD)
+				 SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_CLUSTER)
 
 static inline int current_is_kswapd(void)
 {
@@ -152,8 +153,9 @@ enum {
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
 	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
+	SWP_CLUSTERDISCARD = (1 << 8),	/* discard swap cluster after usage */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 9),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c340d9..197461f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -212,7 +212,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-		if (si->flags & SWP_DISCARDABLE) {
+		if (si->flags & SWP_CLUSTERDISCARD) {
 			/*
 			 * Start range check on racing allocations, in case
 			 * they overlap the cluster we eventually decide on
@@ -322,7 +322,7 @@ checks:
 
 	if (si->lowest_alloc) {
 		/*
-		 * Only set when SWP_DISCARDABLE, and there's a scan
+		 * Only set when SWP_CLUSTERDISCARD, and there's a scan
 		 * for a free cluster in progress or just completed.
 		 */
 		if (found_free_cluster) {
@@ -2123,8 +2123,11 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			p->flags |= SWP_SOLIDSTATE;
 			p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		}
-		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
+		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0) {
 			p->flags |= SWP_DISCARDABLE;
+			if (swap_flags & SWAP_FLAG_DISCARD_CLUSTER)
+				p->flags |= SWP_CLUSTERDISCARD;
+		}
 	}
 
 	mutex_lock(&swapon_mutex);
@@ -2135,11 +2138,12 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	enable_swap_info(p, prio, swap_map, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s%s%s\n",
 		p->pages<<(PAGE_SHIFT-10), name->name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
 		(p->flags & SWP_DISCARDABLE) ? "D" : "",
+		(p->flags & SWP_CLUSTERDISCARD) ? "C" : "",
 		(frontswap_map) ? "FS" : "");
 
 	mutex_unlock(&swapon_mutex);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
