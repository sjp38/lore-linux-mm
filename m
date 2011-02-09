Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B1EAB8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 06:02:21 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/4] memcg: convert per-cpu stock from bytes to page granularity
Date: Wed,  9 Feb 2011 12:01:51 +0100
Message-Id: <1297249313-23746-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We never keep subpage quantities in the per-cpu stock.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cabf421..179fd74 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1624,14 +1624,14 @@ EXPORT_SYMBOL(mem_cgroup_update_page_stat);
 #define CHARGE_SIZE	(32 * PAGE_SIZE)
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
-	int charge;
+	unsigned int nr_pages;
 	struct work_struct work;
 };
 static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
 static atomic_t memcg_drain_count;
 
 /*
- * Try to consume stocked charge on this cpu. If success, PAGE_SIZE is consumed
+ * Try to consume stocked charge on this cpu. If success, one page is consumed
  * from local stock and true is returned. If the stock is 0 or charges from a
  * cgroup which is not current target, returns false. This stock will be
  * refilled.
@@ -1642,8 +1642,8 @@ static bool consume_stock(struct mem_cgroup *mem)
 	bool ret = true;
 
 	stock = &get_cpu_var(memcg_stock);
-	if (mem == stock->cached && stock->charge)
-		stock->charge -= PAGE_SIZE;
+	if (mem == stock->cached && stock->nr_pages)
+		stock->nr_pages--;
 	else /* need to call res_counter_charge */
 		ret = false;
 	put_cpu_var(memcg_stock);
@@ -1657,13 +1657,15 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 {
 	struct mem_cgroup *old = stock->cached;
 
-	if (stock->charge) {
-		res_counter_uncharge(&old->res, stock->charge);
+	if (stock->nr_pages) {
+		unsigned long bytes = stock->nr_pages * PAGE_SIZE;
+
+		res_counter_uncharge(&old->res, bytes);
 		if (do_swap_account)
-			res_counter_uncharge(&old->memsw, stock->charge);
+			res_counter_uncharge(&old->memsw, bytes);
+		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
-	stock->charge = 0;
 }
 
 /*
@@ -1680,7 +1682,7 @@ static void drain_local_stock(struct work_struct *dummy)
  * Cache charges(val) which is from res_counter, to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
  */
-static void refill_stock(struct mem_cgroup *mem, int val)
+static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
 {
 	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
 
@@ -1688,7 +1690,7 @@ static void refill_stock(struct mem_cgroup *mem, int val)
 		drain_stock(stock);
 		stock->cached = mem;
 	}
-	stock->charge += val;
+	stock->nr_pages += nr_pages;
 	put_cpu_var(memcg_stock);
 }
 
@@ -1986,7 +1988,7 @@ again:
 	} while (ret != CHARGE_OK);
 
 	if (csize > page_size)
-		refill_stock(mem, csize - page_size);
+		refill_stock(mem, (csize - page_size) >> PAGE_SHIFT);
 	css_put(&mem->css);
 done:
 	*memcg = mem;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
