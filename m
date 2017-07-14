Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62554440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:56:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so11212205wrc.2
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:56:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h87si2299465wmi.137.2017.07.14.05.56.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:56:18 -0700 (PDT)
Date: Fri, 14 Jul 2017 13:56:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170714125616.clbp4ezgtoon6cmk@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
 <20170714093650.l67vbem2g4typkta@suse.de>
 <20170714104756.GD2618@dhcp22.suse.cz>
 <20170714111633.gk5rpu2d5ghkbrrd@suse.de>
 <20170714113840.GI2618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714113840.GI2618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri, Jul 14, 2017 at 01:38:40PM +0200, Michal Hocko wrote:
> On Fri 14-07-17 12:16:33, Mel Gorman wrote:
> > On Fri, Jul 14, 2017 at 12:47:57PM +0200, Michal Hocko wrote:
> > > > That should to be "default" because the original code would have the proc
> > > > entry display "default" unless it was set at runtime. Pretty weird I
> > > > know but it's always possible someone is parsing the original default
> > > > and not handling it properly.
> > > 
> > > Ohh, right! That is indeed strange. Then I guess it would be probably
> > > better to simply return Node to make it clear what the default is. What
> > > do you think?
> > > 
> > 
> > That would work too. The casing still matches.
> 
> This folded in?
> ---
> From c7c36f011590680b254813be00ed791ddbc1bf1c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 14 Jul 2017 13:36:05 +0200
> Subject: [PATCH] fold me "mm, page_alloc: rip out ZONELIST_ORDER_ZONE"
> 
> - do not print Default in sysctl handler because our behavior was rather
> inconsistent in the past numa_zonelist_order was lowecase while
> zonelist_order_name was uppercase so boot time unchanged value woul
> print lowercase while updated value could be uppercase. Print "Node"
> which is the default instead - Mel
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd4c96edcec3..49bade7ff049 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4828,8 +4828,8 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
>  	int ret;
>  
>  	if (!write) {
> -		int len = sizeof("Default");
> -		if (copy_to_user(buffer, "Default", len))
> +		int len = sizeof("Node");
> +		if (copy_to_user(buffer, "Node", len))
>  			return -EFAULT;

Ok for the name. But what's with using sizeof? The type is char * so it
just happens to work for Default, but not for Node. Also strongly suggest
you continue using proc_dostring because it catches all the corner-cases
that can occur.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
