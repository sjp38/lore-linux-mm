Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0593F6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:33:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v13-v6so455898wmc.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 12:33:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z25-v6si1483515edc.117.2018.06.20.12.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 12:33:25 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:35:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180620193549.GA4734@cmpxchg.org>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180620151812.GA2441@cmpxchg.org>
 <20180620153148.GO13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620153148.GO13685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 20, 2018 at 05:31:48PM +0200, Michal Hocko wrote:
> This?
> 	if (order > PAGE_ALLOC_COSTLY_ORDER)
> 		return OOM_SKIPPED;
> 
> 	/*
> 	 * We are in the middle of the charge context here, so we
> 	 * don't want to block when potentially sitting on a callstack
> 	 * that holds all kinds of filesystem and mm locks.
> 	 *
> 	 * cgroup1 allows disabling the OOM killer and waiting for outside
> 	 * handling until the charge can succeed; remember the context and put
> 	 * the task to sleep at the end of the page fault when all locks are
> 	 * released.
> 	 *
> 	 * On the other hand, in-kernel OOM killer allows for an async victim
> 	 * memory reclaim (oom_reaper) and that means that we are not solely
> 	 * relying on the oom victim to make a forward progress and we can
> 	 * invoke the oom killer here.
> 	 *
> 	 * Please note that mem_cgroup_oom_synchronize might fail to find a
> 	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> 	 * we would fall back to the global oom killer in pagefault_out_of_memory
> 	 */
> 	if (memcg->oom_kill_disable) {
> 		if (!current->memcg_may_oom)
> 			return OOM_SKIPPED;
> 		css_get(&memcg->css);
> 		current->memcg_in_oom = memcg;
> 		current->memcg_oom_gfp_mask = mask;
> 		current->memcg_oom_order = order;
> 
> 		return OOM_ASYNC;
> 	}
> 
> 	if (mem_cgroup_out_of_memory(memcg, mask, order))
> 		return OOM_SUCCESS;
> 
> 	WARN(!current->memcg_may_oom,
> 			"Memory cgroup charge failed because of no reclaimable memory! "
> 			"This looks like a misconfiguration or a kernel bug.");
> 	return OOM_FAILED;

Yep, this looks good IMO.
