Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DD0906B0105
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:33:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 80D973EE0BD
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:33:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66D2045DE52
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:33:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D5EE45DE4F
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:33:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4054B1DB802F
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:33:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA47C1DB803B
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:33:29 +0900 (JST)
Message-ID: <4F86BD18.4010505@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:31:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 7/7] memcg: remove drain_all_stock_sync.
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Because a function moving pages to ancestor works asynchronously now,
drain_all_stock_sync() is unnecessary.

Signed-off-by: KAMEAZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e466809..d42811b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2053,7 +2053,7 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
  * of the hierarchy under it. sync flag says whether we should block
  * until the work is done.
  */
-static void drain_all_stock(struct mem_cgroup *root_memcg, bool sync)
+static void drain_all_stock(struct mem_cgroup *root_memcg)
 {
 	int cpu, curcpu;
 
@@ -2077,16 +2077,6 @@ static void drain_all_stock(struct mem_cgroup *root_memcg, bool sync)
 		}
 	}
 	put_cpu();
-
-	if (!sync)
-		goto out;
-
-	for_each_online_cpu(cpu) {
-		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
-			flush_work(&stock->work);
-	}
-out:
  	put_online_cpus();
 }
 
@@ -2103,15 +2093,7 @@ static void drain_all_stock_async(struct mem_cgroup *root_memcg)
 	 */
 	if (!mutex_trylock(&percpu_charge_mutex))
 		return;
-	drain_all_stock(root_memcg, false);
-	mutex_unlock(&percpu_charge_mutex);
-}
-
-static void drain_all_stock_sync(struct mem_cgroup *root_memcg)
-{
-	/* called when force_empty is called */
-	mutex_lock(&percpu_charge_mutex);
-	drain_all_stock(root_memcg, true);
+	drain_all_stock(root_memcg);
 	mutex_unlock(&percpu_charge_mutex);
 }
 
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
