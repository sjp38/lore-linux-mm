Message-ID: <385932608.30250@ustc.edu.cn>
Date: Wed, 1 Aug 2007 09:32:08 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: make swappiness safer to use
Message-ID: <20070801013208.GA20085@mail.ustc.edu.cn>
References: <20070731215228.GU6910@v2.random> <20070731151244.3395038e.akpm@linux-foundation.org> <20070731224052.GW6910@v2.random> <20070731155109.228b4f19.akpm@linux-foundation.org> <20070731230251.GX6910@v2.random> <20070801011925.GB20109@mail.ustc.edu.cn> <20070801012222.GA20565@mail.ustc.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070801012222.GA20565@mail.ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Here's the updated patch without underflows.

Signed-off-by: Kurt Garloff <garloff@suse.de>
Signed-off-by: Andrea Arcangeli <andrea@suse.de>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
---
 mm/vmscan.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

--- linux-2.6.22-rc6-mm1.orig/mm/vmscan.c
+++ linux-2.6.22-rc6-mm1/mm/vmscan.c
@@ -887,6 +887,7 @@ static void shrink_active_list(unsigned 
 		long mapped_ratio;
 		long distress;
 		long swap_tendency;
+		long imbalance;
 
 		if (zone_is_near_oom(zone))
 			goto force_reclaim_mapped;
@@ -922,6 +923,46 @@ static void shrink_active_list(unsigned 
 		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
 
 		/*
+		 * If there's huge imbalance between active and inactive
+		 * (think active 100 times larger than inactive) we should
+		 * become more permissive, or the system will take too much
+		 * cpu before it start swapping during memory pressure.
+		 * Distress is about avoiding early-oom, this is about
+		 * making swappiness graceful despite setting it to low
+		 * values.
+		 *
+		 * Avoid div by zero with nr_inactive+1, and max resulting
+		 * value is vm_total_pages.
+		 */
+		imbalance  = zone_page_state(zone, NR_ACTIVE);
+		imbalance /= zone_page_state(zone, NR_INACTIVE) + 1;
+
+		/*
+		 * Reduce the effect of imbalance if swappiness is low,
+		 * this means for a swappiness very low, the imbalance
+		 * must be much higher than 100 for this logic to make
+		 * the difference.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= (vm_swappiness + 1);
+		imbalance /= 100;
+
+		/*
+		 * If not much of the ram is mapped, makes the imbalance
+		 * less relevant, it's high priority we refill the inactive
+		 * list with mapped pages only in presence of high ratio of
+		 * mapped pages.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= mapped_ratio;
+		imbalance /= 100;
+
+		/* apply imbalance feedback to swap_tendency */
+		swap_tendency += imbalance;
+
+		/*
 		 * Now use this metric to decide whether to start moving mapped
 		 * memory onto the inactive list.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
