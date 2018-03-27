Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9D2A6B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:58:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g13so11353646wrh.23
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 03:58:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si710901wri.535.2018.03.27.03.58.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 03:58:23 -0700 (PDT)
Date: Tue, 27 Mar 2018 12:58:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-ID: <20180327105821.GF5652@dhcp22.suse.cz>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180327035707.84113-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Tue 27-03-18 11:57:07, Wei Yang wrote:
> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
> node. The memblock_region in memblock_type are already ordered, which means
> the first hit in iteration is the minimum pfn.

I haven't looked at the code yet but the changelog should contain the
motivation why it exists. It seems like this is an optimization. If so,
what is the impact?

> This patch returns the fist hit instead of iterating the whole regions.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_alloc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 635d7dd29d7f..a65de1ec4b91 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6365,14 +6365,14 @@ unsigned long __init node_map_pfn_alignment(void)
>  /* Find the lowest pfn for a node */
>  static unsigned long __init find_min_pfn_for_node(int nid)
>  {
> -	unsigned long min_pfn = ULONG_MAX;
> -	unsigned long start_pfn;
> +	unsigned long min_pfn;
>  	int i;
>  
> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
> -		min_pfn = min(min_pfn, start_pfn);
> +	for_each_mem_pfn_range(i, nid, &min_pfn, NULL, NULL) {
> +		break;
> +	}
>  
> -	if (min_pfn == ULONG_MAX) {
> +	if (i == -1) {
>  		pr_warn("Could not find start_pfn for node %d\n", nid);
>  		return 0;
>  	}
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
