Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80BC96B18A2
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:41:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g15-v6so5750265edm.11
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:41:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15-v6si3839054edk.25.2018.08.20.03.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 03:41:41 -0700 (PDT)
Date: Mon, 20 Aug 2018 12:41:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: actually ignore mempolicies for high
 priority allocations
Message-ID: <20180820104139.GH29735@dhcp22.suse.cz>
References: <20180612122624.8045-1-vbabka@suse.cz>
 <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
 <20180816100317.GV32645@dhcp22.suse.cz>
 <6680ec46-8a73-bc70-5dff-eb3cf49482a2@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6680ec46-8a73-bc70-5dff-eb3cf49482a2@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>

On Sat 18-08-18 22:02:14, Tetsuo Handa wrote:
> On 2018/08/16 19:03, Michal Hocko wrote:
> > The code is quite subtle and we have a bad history of copying stuff
> > without rethinking whether the code still is needed. Which is sad and a
> > clear sign that the code is too complex. I cannot say this change
> > doesn't have any subtle side effects but it makes the intention clear at
> > least so I _think_ it is good to go. If we find some unintended side
> > effects we should simply rethink the whole reset zonelist thing.
> 
> Does this change affect
> 
>         /*
>          * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
>          * the page allocator means a mempolicy is in effect.  Cpuset policy
>          * is enforced in get_page_from_freelist().
>          */
>         if (oc->nodemask &&
>             !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
>                 oc->totalpages = total_swap_pages;
>                 for_each_node_mask(nid, *oc->nodemask)
>                         oc->totalpages += node_spanned_pages(nid);
>                 return CONSTRAINT_MEMORY_POLICY;
>         }
> 
> in constrained_alloc() called from
> 
>         /*
>          * Check if there were limitations on the allocation (only relevant for
>          * NUMA and memcg) that may require different handling.
>          */
>         constraint = constrained_alloc(oc);
>         if (constraint != CONSTRAINT_MEMORY_POLICY)
>                 oc->nodemask = NULL;
> 
> in out_of_memory() ?

No practical difference AFAICS. We are losing the nodemask for oom
victims but their mere existance should make oom decisions void
and so the constrain shouldn't really matter.
-- 
Michal Hocko
SUSE Labs
