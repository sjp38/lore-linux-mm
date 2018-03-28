Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA476B002D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:58:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z83so1029600wmc.2
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:58:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y45si326699wrd.424.2018.03.28.04.58.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 04:58:54 -0700 (PDT)
Date: Wed, 28 Mar 2018 13:58:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: optimize find_min_pfn_for_node() by
 geting the minimal pfn directly
Message-ID: <20180328115853.GI9275@dhcp22.suse.cz>
References: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
 <20180328034752.96146-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328034752.96146-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed 28-03-18 11:47:52, Wei Yang wrote:
[...]
> +/**
> + * first_mem_pfn - get the first memory pfn
> + * @i: an integer used as an indicator
> + * @nid: node selector, %MAX_NUMNODES for all nodes
> + * @p_first: ptr to ulong for first pfn of the range, can be %NULL
> + */
> +#define first_mem_pfn(i, nid, p_first)				\
> +	__next_mem_pfn_range(&i, nid, p_first, NULL, NULL)
> +

Is this really something that we want to export to all users? And if
that is the case is the documenation really telling user how to use it?

>  /**
>   * for_each_mem_pfn_range - early memory pfn range iterator
>   * @i: an integer used as loop variable
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 635d7dd29d7f..8c964dcc3a9e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6365,14 +6365,16 @@ unsigned long __init node_map_pfn_alignment(void)
>  /* Find the lowest pfn for a node */
>  static unsigned long __init find_min_pfn_for_node(int nid)
>  {
> -	unsigned long min_pfn = ULONG_MAX;
> -	unsigned long start_pfn;
> -	int i;
> +	unsigned long min_pfn;
> +	int i = -1;
>  
> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
> -		min_pfn = min(min_pfn, start_pfn);
> +	/*
> +	 * The first pfn on nid node is the minimal one, as the pfn's are
> +	 * stored in ascending order.
> +	 */
> +	first_mem_pfn(i, nid, &min_pfn);
>  
> -	if (min_pfn == ULONG_MAX) {
> +	if (i == -1) {
>  		pr_warn("Could not find start_pfn for node %d\n", nid);
>  		return 0;
>  	}

I would just open code it. Other than that I strongly suspect this will
not have any measurable impact becauser we usually only have handfull of
memory ranges but why not. Just make the new implementation less ugly
than it is cuurrently - e.g. opencode first_mem_pfn and you can add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
