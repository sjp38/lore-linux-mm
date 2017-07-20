Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF5DD6B02F4
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:13:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k71so11712552wrc.15
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:13:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w20si1650193wrc.519.2017.07.19.23.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 23:13:17 -0700 (PDT)
Subject: Re: [PATCH 5/9] mm, memory_hotplug: remove explicit
 build_all_zonelists from try_online_node
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-6-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9f525686-0cad-0c8b-78a2-31d705d68828@suse.cz>
Date: Thu, 20 Jul 2017 08:13:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-6-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hp.com>

On 07/14/2017 10:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> try_online_node calls hotadd_new_pgdat which already calls
> build_all_zonelists. So the additional call is redundant.  Even though
> hotadd_new_pgdat will only initialize zonelists of the new node this is
> the right thing to do because such a node doesn't have any memory so
> other zonelists would ignore all the zones from this node anyway.

Doesn't the "if (pgdat<...>zone == NULL) in fact mean, that this is just
always dead code? Even more reason to remove it.

> Cc: Toshi Kani <toshi.kani@hp.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
