Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 437086B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 03:00:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m72so5219172wmc.0
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 00:00:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q80si279288wrb.397.2017.10.13.00.00.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 00:00:03 -0700 (PDT)
Date: Fri, 13 Oct 2017 09:00:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
References: <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Just to be explicit what I've had in mind. This hasn't been even compile
tested but it should provide at least an idea where I am trying to go..
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5f3a62887cf..91fa05372114 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1528,26 +1528,36 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom)
-		return;
 	/*
 	 * We are in the middle of the charge context here, so we
 	 * don't want to block when potentially sitting on a callstack
 	 * that holds all kinds of filesystem and mm locks.
 	 *
-	 * Also, the caller may handle a failed allocation gracefully
-	 * (like optional page cache readahead) and so an OOM killer
-	 * invocation might not even be necessary.
+	 * cgroup v1 allowes sync users space handling so we cannot afford
+	 * to get stuck here for that configuration. That's why we don't do
+	 * anything here except remember the OOM context and then deal with
+	 * it at the end of the page fault when the stack is unwound, the 
+	 * locks are released, and when we know whether the fault was overall
+	 * successful.
 	 *
-	 * That's why we don't do anything here except remember the
-	 * OOM context and then deal with it at the end of the page
-	 * fault when the stack is unwound, the locks are released,
-	 * and when we know whether the fault was overall successful.
+	 * On the other hand, in-kernel OOM killer allows for an async victim
+	 * memory reclaim (oom_reaper) and that means that we are not solely
+	 * relying on the oom victim to make a forward progress so we can stay
+	 * in the the try_charge context and keep retrying as long as there
+	 * are oom victims to select.
 	 */
-	css_get(&memcg->css);
-	current->memcg_in_oom = memcg;
-	current->memcg_oom_gfp_mask = mask;
-	current->memcg_oom_order = order;
+	if (memcg->oom_kill_disable) {
+		if (!current->memcg_may_oom)
+			return false;
+		css_get(&memcg->css);
+		current->memcg_in_oom = memcg;
+		current->memcg_oom_gfp_mask = mask;
+		current->memcg_oom_order = order;
+
+		return false;
+	}
+
+	return mem_cgroup_out_of_memory(memcg, mask, order);
 }
 
 /**
@@ -2007,8 +2017,11 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	mem_cgroup_event(mem_over_limit, MEMCG_OOM);
 
-	mem_cgroup_oom(mem_over_limit, gfp_mask,
-		       get_order(nr_pages * PAGE_SIZE));
+	if (mem_cgroup_oom(mem_over_limit, gfp_mask,
+		       get_order(nr_pages * PAGE_SIZE))) {
+		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+		goto retry;
+	}
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
