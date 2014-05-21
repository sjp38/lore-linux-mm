Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 789226B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 20:06:59 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so807789pbc.4
        for <linux-mm@kvack.org>; Tue, 20 May 2014 17:06:59 -0700 (PDT)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id ff3si3862622pbd.167.2014.05.20.17.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 17:06:58 -0700 (PDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so805166pbc.18
        for <linux-mm@kvack.org>; Tue, 20 May 2014 17:06:58 -0700 (PDT)
Date: Tue, 20 May 2014 17:06:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: page_alloc: Calculate classzone_idx once from the
 zonelist ref
In-Reply-To: <20140520124302.GN23991@suse.de>
Message-ID: <alpine.DEB.2.02.1405201705200.24551@chino.kir.corp.google.com>
References: <20140520111753.GA22262@mwanda> <20140520124302.GN23991@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, 20 May 2014, Mel Gorman wrote:

> Dan Carpenter reported the following bug
> 
> 	The patch a486e00b8283: "mm: page_alloc: calculate classzone_idx
> 	once from the zonelist ref" from May 17, 2014, leads to the
> 	following static checker warning:
> 
>         mm/page_alloc.c:2543 __alloc_pages_slowpath()
>         warn: we tested 'nodemask' before and it was 'false'
> 
> mm/page_alloc.c
>   2537           * Find the true preferred zone if the allocation is unconstrained by
>   2538           * cpusets.
>   2539           */
>   2540          if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
>                                                      ^^^^^^^^^
> Patch introduces this test.
> 
>   2541                  struct zoneref *preferred_zoneref;
>   2542                  preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
>   2543                                  nodemask ? : &cpuset_current_mems_allowed,
>                                         ^^^^^^^^
> Patch introduces this test as well.
> 
>   2544                                  &preferred_zone);
>   2545                  classzone_idx = zonelist_zone_idx(preferred_zoneref);
>   2546          }
> 
> This patch should resolve it and is a fix to the mmotm patch
> mm-page_alloc-calculate-classzone_idx-once-from-the-zonelist-ref
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/page_alloc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0959b09..ebb947d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2590,8 +2590,7 @@ restart:
>  	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
>  		struct zoneref *preferred_zoneref;
>  		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
> -				nodemask ? : &cpuset_current_mems_allowed,
> -				&preferred_zone);
> +				NULL, &preferred_zone);
>  		classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  	}
>  

The switch from "nodemask : &cpuset_current_mems_allowed" to NULL isn't 
described in the changelog but makes sense as well because of
!(alloc_flags & ALLOC_CPUSET).

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
