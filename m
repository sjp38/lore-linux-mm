Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB2A6B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 08:29:10 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x55so4040104wes.5
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 05:29:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si11876455wja.131.2014.02.04.05.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 05:29:08 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 1/6] memcg: do not replicate try_get_mem_cgroup_from_mm in __mem_cgroup_try_charge
Date: Tue,  4 Feb 2014 14:28:55 +0100
Message-Id: <1391520540-17436-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Johannes Weiner has pointed out that __mem_cgroup_try_charge duplicates
try_get_mem_cgroup_from_mm for charges which came without a memcg. The
only reason seems to be a tiny optimization when css_tryget is not
called if the charge can be consumed from the stock. Nevertheless
css_tryget is very cheap since it has been reworked to use per-cpu
counting so this optimization doesn't give us anything these days.

So let's drop the code duplication so that the code is more readable.
While we are at it also remove a very confusing comment in
try_get_mem_cgroup_from_mm.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 49 ++++++++-----------------------------------------
 1 file changed, 8 insertions(+), 41 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 53385cd4e6f0..042e4ff36c05 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1081,11 +1081,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 
 	if (!mm)
 		return NULL;
-	/*
-	 * Because we have no locks, mm->owner's may be being moved to other
-	 * cgroup. We use css_tryget() here even if this looks
-	 * pessimistic (rather than adding locks here).
-	 */
+
 	rcu_read_lock();
 	do {
 		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
@@ -2759,45 +2755,15 @@ again:
 			goto done;
 		css_get(&memcg->css);
 	} else {
-		struct task_struct *p;
-
-		rcu_read_lock();
-		p = rcu_dereference(mm->owner);
-		/*
-		 * Because we don't have task_lock(), "p" can exit.
-		 * In that case, "memcg" can point to root or p can be NULL with
-		 * race with swapoff. Then, we have small risk of mis-accouning.
-		 * But such kind of mis-account by race always happens because
-		 * we don't have cgroup_mutex(). It's overkill and we allo that
-		 * small race, here.
-		 * (*) swapoff at el will charge against mm-struct not against
-		 * task-struct. So, mm->owner can be NULL.
-		 */
-		memcg = mem_cgroup_from_task(p);
-		if (!memcg)
+		memcg = try_get_mem_cgroup_from_mm(mm);
+		if (!memcg) {
 			memcg = root_mem_cgroup;
-		if (mem_cgroup_is_root(memcg)) {
-			rcu_read_unlock();
-			goto done;
-		}
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
 			goto done;
 		}
-		/* after here, we may be blocked. we need to get refcnt */
-		if (!css_tryget(&memcg->css)) {
-			rcu_read_unlock();
-			goto again;
-		}
-		rcu_read_unlock();
+		if (mem_cgroup_is_root(memcg))
+			goto done_put;
+		if (consume_stock(memcg, nr_pages))
+			goto done_put;
 	}
 
 	do {
@@ -2834,6 +2800,7 @@ again:
 
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
+done_put:
 	css_put(&memcg->css);
 done:
 	*ptr = memcg;
-- 
1.9.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
