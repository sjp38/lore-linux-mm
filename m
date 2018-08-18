Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26D856B0DED
	for <linux-mm@kvack.org>; Sat, 18 Aug 2018 09:02:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g36-v6so6593046plb.5
        for <linux-mm@kvack.org>; Sat, 18 Aug 2018 06:02:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x66-v6si4645026pfx.129.2018.08.18.06.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Aug 2018 06:02:23 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: actually ignore mempolicies for high
 priority allocations
References: <20180612122624.8045-1-vbabka@suse.cz>
 <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
 <20180816100317.GV32645@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <6680ec46-8a73-bc70-5dff-eb3cf49482a2@I-love.SAKURA.ne.jp>
Date: Sat, 18 Aug 2018 22:02:14 +0900
MIME-Version: 1.0
In-Reply-To: <20180816100317.GV32645@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

On 2018/08/16 19:03, Michal Hocko wrote:
> The code is quite subtle and we have a bad history of copying stuff
> without rethinking whether the code still is needed. Which is sad and a
> clear sign that the code is too complex. I cannot say this change
> doesn't have any subtle side effects but it makes the intention clear at
> least so I _think_ it is good to go. If we find some unintended side
> effects we should simply rethink the whole reset zonelist thing.

Does this change affect

        /*
         * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
         * the page allocator means a mempolicy is in effect.  Cpuset policy
         * is enforced in get_page_from_freelist().
         */
        if (oc->nodemask &&
            !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
                oc->totalpages = total_swap_pages;
                for_each_node_mask(nid, *oc->nodemask)
                        oc->totalpages += node_spanned_pages(nid);
                return CONSTRAINT_MEMORY_POLICY;
        }

in constrained_alloc() called from

        /*
         * Check if there were limitations on the allocation (only relevant for
         * NUMA and memcg) that may require different handling.
         */
        constraint = constrained_alloc(oc);
        if (constraint != CONSTRAINT_MEMORY_POLICY)
                oc->nodemask = NULL;

in out_of_memory() ?
