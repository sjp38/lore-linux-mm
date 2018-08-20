Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD4E6B18B2
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:53:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v9-v6so7684595pff.4
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:53:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y9-v6si9788466pll.291.2018.08.20.03.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 03:53:11 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: actually ignore mempolicies for high
 priority allocations
References: <20180612122624.8045-1-vbabka@suse.cz>
 <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
 <20180816100317.GV32645@dhcp22.suse.cz>
 <6680ec46-8a73-bc70-5dff-eb3cf49482a2@I-love.SAKURA.ne.jp>
 <20180820104139.GH29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b235c21a-a237-f9a9-1b12-203a11d89ce8@i-love.sakura.ne.jp>
Date: Mon, 20 Aug 2018 19:52:59 +0900
MIME-Version: 1.0
In-Reply-To: <20180820104139.GH29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

On 2018/08/20 19:41, Michal Hocko wrote:
> On Sat 18-08-18 22:02:14, Tetsuo Handa wrote:
>> On 2018/08/16 19:03, Michal Hocko wrote:
>>> The code is quite subtle and we have a bad history of copying stuff
>>> without rethinking whether the code still is needed. Which is sad and a
>>> clear sign that the code is too complex. I cannot say this change
>>> doesn't have any subtle side effects but it makes the intention clear at
>>> least so I _think_ it is good to go. If we find some unintended side
>>> effects we should simply rethink the whole reset zonelist thing.
>>
>> Does this change affect
>>
>>         /*
>>          * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
>>          * the page allocator means a mempolicy is in effect.  Cpuset policy
>>          * is enforced in get_page_from_freelist().
>>          */
>>         if (oc->nodemask &&
>>             !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
>>                 oc->totalpages = total_swap_pages;
>>                 for_each_node_mask(nid, *oc->nodemask)
>>                         oc->totalpages += node_spanned_pages(nid);
>>                 return CONSTRAINT_MEMORY_POLICY;
>>         }
>>
>> in constrained_alloc() called from
>>
>>         /*
>>          * Check if there were limitations on the allocation (only relevant for
>>          * NUMA and memcg) that may require different handling.
>>          */
>>         constraint = constrained_alloc(oc);
>>         if (constraint != CONSTRAINT_MEMORY_POLICY)
>>                 oc->nodemask = NULL;
>>
>> in out_of_memory() ?
> 
> No practical difference AFAICS. We are losing the nodemask for oom
> victims but their mere existance should make oom decisions void
> and so the constrain shouldn't really matter.
> 

If my guess that whether oc->nodemask is NULL affects whether oom_unkillable_task()
(effectively has_intersects_mems_allowed()) returns true is correct, I worried that
OOM victims select next OOM victim from wider targets if MMF_OOM_SKIP was already set
on the OOM victim's mm. That might be an unexpected behavior...
