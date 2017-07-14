Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 960C6440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:14:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l81so8948830wmg.8
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:14:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v12si6287454wrv.47.2017.07.14.05.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:14:23 -0700 (PDT)
Date: Fri, 14 Jul 2017 14:14:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/9] mm, memory_hotplug: remove explicit
 build_all_zonelists from try_online_node
Message-ID: <20170714121421.GL2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714080006.7250-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Kani Toshimitsu <toshi.kani@hpe.com>

[Fixup email to Toshi Kani - the cover is
http://lkml.kernel.org/r/20170714080006.7250-1-mhocko@kernel.org]

On Fri 14-07-17 10:00:02, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> try_online_node calls hotadd_new_pgdat which already calls
> build_all_zonelists. So the additional call is redundant.  Even though
> hotadd_new_pgdat will only initialize zonelists of the new node this is
> the right thing to do because such a node doesn't have any memory so
> other zonelists would ignore all the zones from this node anyway.
> 
> Cc: Toshi Kani <toshi.kani@hp.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 7 -------
>  1 file changed, 7 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 639b8af37c45..0d2f6a11075c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1104,13 +1104,6 @@ int try_online_node(int nid)
>  	node_set_online(nid);
>  	ret = register_one_node(nid);
>  	BUG_ON(ret);
> -
> -	if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
> -		mutex_lock(&zonelists_mutex);
> -		build_all_zonelists(NULL);
> -		mutex_unlock(&zonelists_mutex);
> -	}
> -
>  out:
>  	mem_hotplug_done();
>  	return ret;
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
