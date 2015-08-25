Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id DF2276B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:32:09 -0400 (EDT)
Received: by wijp15 with SMTP id p15so17936836wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:32:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gn12si39140744wjc.137.2015.08.25.07.32.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 07:32:08 -0700 (PDT)
Subject: Re: [PATCH 05/12] mm, page_alloc: Remove unecessary recheck of
 nodemask
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-6-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC7C65.8030006@suse.cz>
Date: Tue, 25 Aug 2015 16:32:05 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-6-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> An allocation request will either use the given nodemask or the cpuset
> current tasks mems_allowed. A cpuset retry will recheck the callers nodemask
> and while it's trivial overhead during an extremely rare operation, also
> unnecessary. This patch fixes it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>   mm/page_alloc.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c1c3bf54d15..32d1cec124bc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3171,7 +3171,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>   	struct alloc_context ac = {
>   		.high_zoneidx = gfp_zone(gfp_mask),
> -		.nodemask = nodemask,
> +		.nodemask = nodemask ? : &cpuset_current_mems_allowed,

Hm this is a functional change for atomic allocations with NULL 
nodemask. ac.nodemask is passed down to __alloc_pages_slowpath() which 
might determine that ALLOC_CPUSET is not to be used (because it's 
atomic). Yet it would use the restricted ac.nodemask in 
get_page_from_freelist() and elsewhere.

>   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>   	};
>
> @@ -3206,8 +3206,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>
>   	/* The preferred zone is used for statistics later */
>   	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
> -				ac.nodemask ? : &cpuset_current_mems_allowed,
> -				&ac.preferred_zone);
> +				ac.nodemask, &ac.preferred_zone);
>   	if (!ac.preferred_zone)
>   		goto out;
>   	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
