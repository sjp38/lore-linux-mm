Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 192236B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:24:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k7so1305282wre.5
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:24:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b18si958520wrc.406.2017.10.13.08.24.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 08:24:26 -0700 (PDT)
Date: Fri, 13 Oct 2017 17:24:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
References: <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
 <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Well, it actually occured to me that this would trigger the global oom
killer in case no memcg specific victim can be found which is definitely
not something we would like to do. This should work better. I am not
sure we can trigger this corner case but we should cover it and it
actually doesn't make the code much worse.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5f3a62887cf..7b370f070b82 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1528,26 +1528,40 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
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
+	 *
+	 * On the other hand, in-kernel OOM killer allows for an async victim
+	 * memory reclaim (oom_reaper) and that means that we are not solely
+	 * relying on the oom victim to make a forward progress so we can stay
+	 * in the the try_charge context and keep retrying as long as there
+	 * are oom victims to select.
 	 *
-	 * That's why we don't do anything here except remember the
-	 * OOM context and then deal with it at the end of the page
-	 * fault when the stack is unwound, the locks are released,
-	 * and when we know whether the fault was overall successful.
+	 * Please note that mem_cgroup_oom_synchronize might fail to find a
+	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
+	 * we would fall back to the global oom killer in pagefault_out_of_memory
 	 */
+	if (!memcg->oom_kill_disable &&
+			mem_cgroup_out_of_memory(memcg, mask, order))
+		return true;
+
+	if (!current->memcg_may_oom)
+		return false;
 	css_get(&memcg->css);
 	current->memcg_in_oom = memcg;
 	current->memcg_oom_gfp_mask = mask;
 	current->memcg_oom_order = order;
+
+	return false;
 }
 
 /**
@@ -2007,8 +2021,11 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
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
