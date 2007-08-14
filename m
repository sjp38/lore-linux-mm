Message-Id: <20070814143303.432960585@sgi.com>
References: <20070814142103.204771292@sgi.com>
Date: Tue, 14 Aug 2007 07:21:06 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 3/3] Test code for PF_MEMALLOC reclaim
Content-Disposition: inline; filename=test_reclaim
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Insert an allocation of 12 MB into shrink_slab(). The allocation occurs every
2 minutes. Reserves are typically around 5-10MB and so it will invariably
exhaust the reserves.

Without the earlier patches this will cause an OOM.

With the patches to allow reclaim with PF_MEMALLOC we will reclaim and
continue

Typical trace output is:

Reclaim: Excessive GFP_KERNEL allocs
Reclaimed 63 pages with NOMEMALLOC
Reclaimed 60 pages with NOMEMALLOC
Reclaimed 52 pages with NOMEMALLOC
Reclaimed 62 pages with NOMEMALLOC
Reclaimed 64 pages with NOMEMALLOC
Reclaimed 64 pages with NOMEMALLOC
Reclaimed 64 pages with NOMEMALLOC
Reclaim: Memory freed

---
 mm/vmscan.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 44 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-14 00:04:26.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-14 00:15:41.000000000 -0700
@@ -132,6 +132,14 @@ void unregister_shrinker(struct shrinker
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
+/*
+ * Min freekbytes is 2m. 3000 pages give us 12M which is
+ * able to exhaust the reserves
+ */
+#define NR_TEST 3000
+
+static void isittime(void);
+
 #define SHRINK_BATCH 128
 /*
  * Call the shrink functions to age shrinkable caches
@@ -161,6 +169,7 @@ unsigned long shrink_slab(unsigned long 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
+	isittime();
 	/*
 	 * Not sure if we can keep this clean of allocs.
 	 * Better leave it off for now
@@ -1110,7 +1119,36 @@ static unsigned long shrink_zones(int pr
 	}
 	return nr_reclaimed;
 }
- 
+
+
+static void isittime(void)
+{
+	struct page **base;
+	int i;
+	static unsigned long lasttime = 120 * HZ;
+
+	/* Every 2 minutes */
+	if (time_after(jiffies, lasttime)) {
+		lasttime = jiffies + 120 * HZ;
+		printk(KERN_CRIT "Reclaim: Excessive GFP_KERNEL allocs\n");
+		/* Force memory to become exhausted */
+		base = kzalloc(NR_TEST * sizeof(void *), GFP_KERNEL);
+
+		for (i = 0; i < NR_TEST; i++) {
+			base[i] = alloc_page(GFP_KERNEL);
+			if (!base[i]) {
+				printk("Alloc failed at %d\n", i);
+				break;
+			}
+		}
+		for (i = 0; i < NR_TEST; i++)
+			if (base[i])
+				put_page(base[i]);
+		kfree(base);
+		printk(KERN_CRIT "Reclaim: Memory freed\n");
+	}
+}
+
 /*
  * This is the main entry point to direct page reclaim.
  *
@@ -1216,6 +1254,11 @@ out:
 
 		zone->prev_priority = priority;
 	}
+
+	if (gfp_mask & __GFP_NOMEMALLOC)
+		printk(KERN_WARNING "Reclaimed %lu pages with NOMEMALLOC\n",
+								nr_reclaimed);
+
 	return ret;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
