Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A235A6B006C
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 15:23:41 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so2324528pad.2
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:23:40 -0800 (PST)
Date: Thu, 20 Dec 2012 12:23:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/sparse: don't check return value of alloc_bootmem
 calls
In-Reply-To: <1356030701-16284-30-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.00.1212201218590.29839@chino.kir.corp.google.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com> <1356030701-16284-30-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Dec 2012, Sasha Levin wrote:

> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6b5fb76..ae64d6e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -403,15 +403,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  	size = PAGE_ALIGN(size);
>  	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
>  					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> -	if (map) {
> -		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> -			if (!present_section_nr(pnum))
> -				continue;
> -			map_map[pnum] = map;
> -			map += size;
> -		}
> -		return;
> +	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +		if (!present_section_nr(pnum))
> +			continue;
> +		map_map[pnum] = map;
> +		map += size;
>  	}
> +	return;
>  
>  	/* fallback */
>  	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {

That's not true when slab_is_available() and why would you possibly add a 
return statement right before fallback code in such cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
