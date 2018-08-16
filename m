Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD5C6B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:03:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y8-v6so1611840edr.12
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:03:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q30-v6si573366edi.5.2018.08.16.03.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:03:19 -0700 (PDT)
Date: Thu, 16 Aug 2018 12:03:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: actually ignore mempolicies for high
 priority allocations
Message-ID: <20180816100317.GV32645@dhcp22.suse.cz>
References: <20180612122624.8045-1-vbabka@suse.cz>
 <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Wed 15-08-18 15:16:52, Andrew Morton wrote:
[...]
> From: Vlastimil Babka <vbabka@suse.cz>
> Subject: mm, page_alloc: actually ignore mempolicies for high priority allocations
> 
> The __alloc_pages_slowpath() function has for a long time contained code
> to ignore node restrictions from memory policies for high priority
> allocations.  The current code that resets the zonelist iterator however
> does effectively nothing after commit 7810e6781e0f ("mm, page_alloc: do
> not break __GFP_THISNODE by zonelist reset") removed a buggy zonelist
> reset.  Even before that commit, mempolicy restrictions were still not
> ignored, as they are passed in ac->nodemask which is untouched by the
> code.
> 
> We can either remove the code, or make it work as intended.  Since
> ac->nodemask can be set from task's mempolicy via alloc_pages_current()
> and thus also alloc_pages(), it may indeed affect kernel allocations, and
> it makes sense to ignore it to allow progress for high priority
> allocations.
> 
> Thus, this patch resets ac->nodemask to NULL in such cases.  This assumes
> all callers can handle it (i.e.  there are no guarantees as in the case of
> __GFP_THISNODE) which seems to be the case.  The same assumption is
> already present in check_retry_cpuset() for some time.
> 
> The expected effect is that high priority kernel allocations in the
> context of userspace tasks (e.g.  OOM victims) restricted by mempolicies
> will have higher chance to succeed if they are restricted to nodes with
> depleted memory, while there are other nodes with free memory left.
> 
> 
> Ot's not a new intention, but for the first time the code will match the
> intention, AFAICS.  It was intended by commit 183f6371aac2 ("mm: ignore
> mempolicies when using ALLOC_NO_WATERMARK") in v3.6 but I think it never
> really worked, as mempolicy restriction was already encoded in nodemask,
> not zonelist, at that time.
> 
> So originally that was for ALLOC_NO_WATERMARK only.  Then it was adjusted
> by e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the
> context can ignore memory policies") and cd04ae1e2dc8 ("mm, oom: do not
> rely on TIF_MEMDIE for memory reserves access") to the current state.  So
> even GFP_ATOMIC would now ignore mempolicies after the initial attempts
> fail - if the code worked as people thought it does.
> 
> Link: http://lkml.kernel.org/r/20180612122624.8045-1-vbabka@suse.cz
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

The code is quite subtle and we have a bad history of copying stuff
without rethinking whether the code still is needed. Which is sad and a
clear sign that the code is too complex. I cannot say this change
doesn't have any subtle side effects but it makes the intention clear at
least so I _think_ it is good to go. If we find some unintended side
effects we should simply rethink the whole reset zonelist thing.

That being said
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  mm/page_alloc.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> --- a/mm/page_alloc.c~mm-page_alloc-actually-ignore-mempolicies-for-high-priority-allocations
> +++ a/mm/page_alloc.c
> @@ -4165,11 +4165,12 @@ retry:
>  		alloc_flags = reserve_flags;
>  
>  	/*
> -	 * Reset the zonelist iterators if memory policies can be ignored.
> -	 * These allocations are high priority and system rather than user
> -	 * orientated.
> +	 * Reset the nodemask and zonelist iterators if memory policies can be
> +	 * ignored. These allocations are high priority and system rather than
> +	 * user oriented.
>  	 */
>  	if (!(alloc_flags & ALLOC_CPUSET) || reserve_flags) {
> +		ac->nodemask = NULL;
>  		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
>  					ac->high_zoneidx, ac->nodemask);
>  	}
> _
> 

-- 
Michal Hocko
SUSE Labs
