Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB498D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 18:05:58 -0400 (EDT)
Date: Wed, 30 Mar 2011 15:05:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix setup_zone_pageset section mismatch
Message-Id: <20110330150510.bc02d041.akpm@linux-foundation.org>
In-Reply-To: <20110324132435.4ee9694e.randy.dunlap@oracle.com>
References: <20110324132435.4ee9694e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>

On Thu, 24 Mar 2011 13:24:35 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix section mismatch warning:
> setup_zone_pageset() is called from build_all_zonelists(),
> which can be called at any time by NUMA sysctl handler
> numa_zonelist_order_handler(),
> so it should not be marked as __meminit.
> 
> WARNING: mm/built-in.o(.text+0xab17): Section mismatch in reference from the function build_all_zonelists() to the function .meminit.text:setup_zone_pageset()
> The function build_all_zonelists() references
> the function __meminit setup_zone_pageset().
> This is often because build_all_zonelists lacks a __meminit 
> annotation or the annotation of setup_zone_pageset is wrong.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.38-git13.orig/mm/page_alloc.c
> +++ linux-2.6.38-git13/mm/page_alloc.c
> @@ -3511,7 +3511,7 @@ static void setup_pagelist_highmark(stru
>  		pcp->batch = PAGE_SHIFT * 8;
>  }
>  
> -static __meminit void setup_zone_pageset(struct zone *zone)
> +static void setup_zone_pageset(struct zone *zone)
>  {
>  	int cpu;
>  

I already merged Paul Mundt's patch whcih marks build_all_zonelists()
as __ref.  That seems a better solution?

I'm rather wondering if we did all this the right way anyway.  The call
from build_all_zonelists() into setup_zone_pageset() is inside #ifdef
CONFIG_MEMORY_HOTPLUG, so there is clearly no bug here.  But the build
system generated a warning anyway.  Why'd it do that?

If we'd handled the section via

#ifdef CONFIG_MEMORY_HOTPLUG
#define __meminit
#else
#define __meminit __init
#endif

of similar then that would fix things.  iirc we used to do it that
way...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
