Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 230376B009A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:07:48 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 01/13] memcg: Make it possible to use the stock for more than one page.
Date: Tue, 18 Sep 2012 18:03:58 +0400
Message-Id: <1347977050-29476-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1347977050-29476-1-git-send-email-glommer@parallels.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>

From: Suleiman Souhlal <ssouhlal@FreeBSD.org>

We currently have a percpu stock cache scheme that charges one page at a
time from memcg->res, the user counter. When the kernel memory
controller comes into play, we'll need to charge more than that.

This is because kernel memory allocations will also draw from the user
counter, and can be bigger than a single page, as it is the case with
the stack (usually 2 pages) or some higher order slabs.

[ glommer@parallels.com: added a changelog ]

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 795e525..9d3bc72 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2034,20 +2034,28 @@ struct memcg_stock_pcp {
 static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
 static DEFINE_MUTEX(percpu_charge_mutex);
 
-/*
- * Try to consume stocked charge on this cpu. If success, one page is consumed
- * from local stock and true is returned. If the stock is 0 or charges from a
- * cgroup which is not current target, returns false. This stock will be
- * refilled.
+/**
+ * consume_stock: Try to consume stocked charge on this cpu.
+ * @memcg: memcg to consume from.
+ * @nr_pages: how many pages to charge.
+ *
+ * The charges will only happen if @memcg matches the current cpu's memcg
+ * stock, and at least @nr_pages are available in that stock.  Failure to
+ * service an allocation will refill the stock.
+ *
+ * returns true if succesfull, false otherwise.
  */
-static bool consume_stock(struct mem_cgroup *memcg)
+static bool consume_stock(struct mem_cgroup *memcg, int nr_pages)
 {
 	struct memcg_stock_pcp *stock;
 	bool ret = true;
 
+	if (nr_pages > CHARGE_BATCH)
+		return false;
+
 	stock = &get_cpu_var(memcg_stock);
-	if (memcg == stock->cached && stock->nr_pages)
-		stock->nr_pages--;
+	if (memcg == stock->cached && stock->nr_pages >= nr_pages)
+		stock->nr_pages -= nr_pages;
 	else /* need to call res_counter_charge */
 		ret = false;
 	put_cpu_var(memcg_stock);
@@ -2346,7 +2354,7 @@ again:
 		VM_BUG_ON(css_is_removed(&memcg->css));
 		if (mem_cgroup_is_root(memcg))
 			goto done;
-		if (nr_pages == 1 && consume_stock(memcg))
+		if (consume_stock(memcg, nr_pages))
 			goto done;
 		css_get(&memcg->css);
 	} else {
@@ -2371,7 +2379,7 @@ again:
 			rcu_read_unlock();
 			goto done;
 		}
-		if (nr_pages == 1 && consume_stock(memcg)) {
+		if (consume_stock(memcg, nr_pages)) {
 			/*
 			 * It seems dagerous to access memcg without css_get().
 			 * But considering how consume_stok works, it's not
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
