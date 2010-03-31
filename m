Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCAD66B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 06:34:20 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o2VAYEdW032563
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:34:16 +0200
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz17.hot.corp.google.com with ESMTP id o2VAYB4Q016423
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:34:12 -0700
Received: by pwj8 with SMTP id 8so10083501pwj.15
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:34:11 -0700 (PDT)
Date: Wed, 31 Mar 2010 03:34:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
In-Reply-To: <4BB31BDA.8080203@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003310324550.17661@chino.kir.corp.google.com>
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop> <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop>
 <4BB31BDA.8080203@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Miao Xie wrote:

> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index f5b7d17..43ac21b 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -58,6 +58,7 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					nodemask_t *nodes,
>  					struct zone **zone)
>  {
> +	nodemask_t tmp_nodes;
>  	/*
>  	 * Find the next suitable zone to use for the allocation.
>  	 * Only filter based on nodemask if it's set
> @@ -65,10 +66,16 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>  	if (likely(nodes == NULL))
>  		while (zonelist_zone_idx(z) > highest_zoneidx)
>  			z++;
> -	else
> -		while (zonelist_zone_idx(z) > highest_zoneidx ||
> -				(z->zone && !zref_in_nodemask(z, nodes)))
> -			z++;
> +	else {
> +		tmp_nodes = *nodes;
> +		if (nodes_empty(tmp_nodes))
> +			while (zonelist_zone_idx(z) > highest_zoneidx)
> +				z++;
> +		else
> +			while (zonelist_zone_idx(z) > highest_zoneidx ||
> +				(z->zone && !zref_in_nodemask(z, &tmp_nodes)))
> +				z++;
> +	}
>  
>  	*zone = zonelist_zone(z);
>  	return z;

Unfortunately, you can't allocate a nodemask_t on the stack here because 
this is used in the iteration for get_page_from_freelist() which can occur 
very deep in the stack already and there's a probability of overflow.  
Dynamically allocating a nodemask_t simply wouldn't scale here, either, 
since it would allocate on every iteration of a zonelist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
