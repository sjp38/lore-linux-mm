Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id BACD96B005C
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:45:52 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so2962112eek.36
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:45:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s42si5139784eew.245.2013.12.17.07.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 07:45:52 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/5] memcg: move stock charge into __mem_cgroup_try_charge_memcg
Date: Tue, 17 Dec 2013 16:45:27 +0100
Message-Id: <1387295130-19771-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

bacause both mem_cgroup_try_charge and mem_cgroup_try_charg_memcg
do the same thing. mem_cgroup_try_charge tries to safe one css_tryget
because it relies on the fact that the stock consumption disables
preemption while checking the memcg so it either sees an alive memcg or
NULL.
The css_tryget doesn't seem to be a bottleneck anymore (after
per-cpu reference counting has been merged) so let's make the
code simpler and easier to understand and move consume_stock into
__mem_cgroup_try_charge_memcg where it logically belongs.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 509bb59f4744..3f01dc9aa101 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2678,6 +2678,9 @@ static int __mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
 	if (unlikely(task_in_memcg_oom(current)))
 		goto nomem;
 
+	if (consume_stock(memcg, nr_pages))
+		return 0;
+
 	if (gfp_mask & __GFP_NOFAIL)
 		oom = false;
 
@@ -2772,18 +2775,6 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 			rcu_read_unlock();
 			goto bypass;
 		}
-		if (consume_stock(memcg, nr_pages)) {
-			/*
-			 * It seems dagerous to access memcg without css_get().
-			 * But considering how consume_stok works, it's not
-			 * necessary. If consume_stock success, some charges
-			 * from this memcg are cached on this cpu. So, we
-			 * don't need to call css_get()/css_tryget() before
-			 * calling consume_stock().
-			 */
-			rcu_read_unlock();
-			goto done;
-		}
 		/* after here, we may be blocked. we need to get refcnt */
 	} while(!css_tryget(&memcg->css));
 	rcu_read_unlock();
@@ -2794,7 +2785,7 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 		goto bypass;
 	else if (ret == -ENOMEM)
 		memcg = NULL;
-done:
+
 	return memcg;
 bypass:
 	return root_mem_cgroup;
@@ -2812,9 +2803,6 @@ static int mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
 	if (mem_cgroup_is_root(memcg) || mem_cgroup_bypass_charge())
 		return -EINTR;
 
-	if (consume_stock(memcg, nr_pages))
-		return 0;
-
 	return __mem_cgroup_try_charge_memcg(gfp_mask, nr_pages, memcg, oom);
 }
 
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
