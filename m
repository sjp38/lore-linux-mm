Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 027496B025B
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 16:07:37 -0400 (EDT)
Received: by qgev79 with SMTP id v79so124937770qge.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 13:07:36 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id 19si13649312qhc.39.2015.09.14.13.07.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 13:07:35 -0700 (PDT)
Received: by qgt47 with SMTP id 47so124998624qgt.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 13:07:35 -0700 (PDT)
Date: Mon, 14 Sep 2015 16:07:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150914200732.GG25369@htj.duckdns.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913201442.GD25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

try_charge() is the main charging logic of memcg.  When it hits the
limit but either can't fail the allocation due to __GFP_NOFAIL or the
task is likely to free memory very soon, being OOM killed, has SIGKILL
pending or exiting, it "bypasses" the charge to the root memcg and
returns -EINTR.  While this is one approach which can be taken for
these situations, it has several issues.

* It unnecessarily lies about the reality.  The number itself doesn't
  go over the limit but the actual usage does.  memcg is either forced
  to or actively chooses to go over the limit because that is the
  right behavior under the circumstances, which is completely fine,
  but, if at all avoidable, it shouldn't be misrepresenting what's
  happening by sneaking the charges into the root memcg.

* Despite trying, we already do over-charge.  kmemcg can't deal with
  switching over to the root memcg by the point try_charge() returns
  -EINTR, so it open-codes over-charing.

* It complicates the callers.  Each try_charge() user has to handle
  the weird -EINTR exception.  memcg_charge_kmem() does the manual
  over-charging.  mem_cgroup_do_precharge() performs unnecessary
  uncharging of root memcg, which BTW is inconsistent with what
  memcg_charge_kmem() does but not broken as [un]charging are noops on
  root memcg.  mem_cgroup_try_charge() needs to switch the returned
  cgroup to the root one.

The reality is that in memcg there are cases where we are forced
and/or willing to go over the limit.  Each such case needs to be
scrutinized and justified but there definitely are situations where
that is the right thing to do.  We alredy do this but with a
superficial and inconsistent disguise which leads to unnecessary
complications.

This patch updates try_charge() so that it over-charges and returns 0
when deemed necessary.  -EINTR return is removed along with all
special case handling in the callers.

While at it, remove the local variable @ret, which was initialized to
zero and never changed, along with done: label which just returned the
always zero @ret.

v2: Minor update to patch description as per Vladimir.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c |   69 ++++++++++++++++----------------------------------------
 1 file changed, 20 insertions(+), 49 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1999,13 +1999,12 @@ static int try_charge(struct mem_cgroup
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
-	int ret = 0;
 
 	if (mem_cgroup_is_root(memcg))
-		goto done;
+		return 0;
 retry:
 	if (consume_stock(memcg, nr_pages))
-		goto done;
+		return 0;
 
 	if (!do_swap_account ||
 	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
@@ -2033,7 +2032,7 @@ retry:
 	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
 		     fatal_signal_pending(current) ||
 		     current->flags & PF_EXITING))
-		goto bypass;
+		goto force;
 
 	if (unlikely(task_in_memcg_oom(current)))
 		goto nomem;
@@ -2079,10 +2078,10 @@ retry:
 		goto retry;
 
 	if (gfp_mask & __GFP_NOFAIL)
-		goto bypass;
+		goto force;
 
 	if (fatal_signal_pending(current))
-		goto bypass;
+		goto force;
 
 	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
 
@@ -2090,8 +2089,18 @@ retry:
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-bypass:
-	return -EINTR;
+force:
+	/*
+	 * The allocation either can't fail or will lead to more memory
+	 * being freed very soon.  Allow memory usage go over the limit
+	 * temporarily by force charging it.
+	 */
+	page_counter_charge(&memcg->memory, nr_pages);
+	if (do_swap_account)
+		page_counter_charge(&memcg->memsw, nr_pages);
+	css_get_many(&memcg->css, nr_pages);
+
+	return 0;
 
 done_restock:
 	css_get_many(&memcg->css, batch);
@@ -2114,8 +2123,8 @@ done_restock:
 			break;
 		}
 	} while ((memcg = parent_mem_cgroup(memcg)));
-done:
-	return ret;
+
+	return 0;
 }
 
 static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
@@ -2207,28 +2216,7 @@ int memcg_charge_kmem(struct mem_cgroup
 		return ret;
 
 	ret = try_charge(memcg, gfp, nr_pages);
-	if (ret == -EINTR)  {
-		/*
-		 * try_charge() chose to bypass to root due to OOM kill or
-		 * fatal signal.  Since our only options are to either fail
-		 * the allocation or charge it to this cgroup, do it as a
-		 * temporary condition. But we can't fail. From a kmem/slab
-		 * perspective, the cache has already been selected, by
-		 * mem_cgroup_kmem_get_cache(), so it is too late to change
-		 * our minds.
-		 *
-		 * This condition will only trigger if the task entered
-		 * memcg_charge_kmem in a sane state, but was OOM-killed
-		 * during try_charge() above. Tasks that were already dying
-		 * when the allocation triggers should have been already
-		 * directed to the root cgroup in memcontrol.h
-		 */
-		page_counter_charge(&memcg->memory, nr_pages);
-		if (do_swap_account)
-			page_counter_charge(&memcg->memsw, nr_pages);
-		css_get_many(&memcg->css, nr_pages);
-		ret = 0;
-	} else if (ret)
+	if (ret)
 		page_counter_uncharge(&memcg->kmem, nr_pages);
 
 	return ret;
@@ -4433,22 +4421,10 @@ static int mem_cgroup_do_precharge(unsig
 		mc.precharge += count;
 		return ret;
 	}
-	if (ret == -EINTR) {
-		cancel_charge(root_mem_cgroup, count);
-		return ret;
-	}
 
 	/* Try charges one by one with reclaim */
 	while (count--) {
 		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
-		/*
-		 * In case of failure, any residual charges against
-		 * mc.to will be dropped by mem_cgroup_clear_mc()
-		 * later on.  However, cancel any charges that are
-		 * bypassed to root right away or they'll be lost.
-		 */
-		if (ret == -EINTR)
-			cancel_charge(root_mem_cgroup, 1);
 		if (ret)
 			return ret;
 		mc.precharge++;
@@ -5353,11 +5329,6 @@ int mem_cgroup_try_charge(struct page *p
 	ret = try_charge(memcg, gfp_mask, nr_pages);
 
 	css_put(&memcg->css);
-
-	if (ret == -EINTR) {
-		memcg = root_mem_cgroup;
-		ret = 0;
-	}
 out:
 	*memcgp = memcg;
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
