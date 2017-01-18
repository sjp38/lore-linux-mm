Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5D436B025E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:31:34 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so1390624wjb.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:31:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 69si28460262wrl.88.2017.01.18.01.31.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:31:33 -0800 (PST)
Date: Wed, 18 Jan 2017 10:31:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/4] mm, page_alloc: fix check for NULL preferred_zone
Message-ID: <20170118093131.GH7015@dhcp22.suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 23:16:07, Vlastimil Babka wrote:
> Since commit c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in
> a zonelist twice") we have a wrong check for NULL preferred_zone, which can
> theoretically happen due to concurrent cpuset modification. We check the
> zoneref pointer which is never NULL and we should check the zone pointer.
> 
> Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 34ada718ef47..593a11d8bc6b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3763,7 +3763,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
>  					ac.high_zoneidx, ac.nodemask);
> -	if (!ac.preferred_zoneref) {
> +	if (!ac.preferred_zoneref->zone) {

When can the ->zone be NULL?

>  		page = NULL;
>  		goto no_zone;
>  	}
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
