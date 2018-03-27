Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F76D6B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 18:47:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id n15-v6so302594plp.22
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 15:47:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 135si1703486pfc.21.2018.03.27.15.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 15:47:42 -0700 (PDT)
Date: Tue, 27 Mar 2018 15:47:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-Id: <20180327154740.9a7713a74a383254b51f4d1a@linux-foundation.org>
In-Reply-To: <20180327035707.84113-1-richard.weiyang@gmail.com>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, tj@kernel.org, linux-mm@kvack.org

On Tue, 27 Mar 2018 11:57:07 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
> node. The memblock_region in memblock_type are already ordered, which means
> the first hit in iteration is the minimum pfn.
> 
> This patch returns the fist hit instead of iterating the whole regions.
> 
> ...
>
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

That would be the weirdest-looking code snippet in mm/!

Can't we just use a single and simple call to __next_mem_pfn_range(),
or something like that?

>
> ...
>
