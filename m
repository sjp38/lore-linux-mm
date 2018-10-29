Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3F66B0360
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 04:07:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x1-v6so6956437eds.16
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 01:07:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15-v6si1962025ejx.192.2018.10.29.01.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 01:07:10 -0700 (PDT)
Date: Mon, 29 Oct 2018 09:07:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
Message-ID: <20181029080708.GA32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Mon 29-10-18 13:16:16, miles.chen@mediatek.com wrote:
> From: Miles Chen <miles.chen@mediatek.com>
> 
> The kbuf used by page owner is allocated by kmalloc(), which means it
> can use only normal memory and there might be a "out of memory"
> issue when we're out of normal memory.
> 
> To solve this problem, use kvmalloc() to allocate kbuf
> from normal/highmem. But there is one problem here: kvmalloc()
> does not fallback to vmalloc for sub page allocations. So sub
> page allocation fails due to out of normal memory cannot fallback
> to vmalloc.
> 
> Modify kvmalloc() to allow sub page allocations fallback to
> vmalloc when CONFIG_HIGHMEM=y and use kvmalloc() to allocate
> kbuf.
> 
> Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation.
> 
> Change since v2:
>   - improve kvmalloc, allow sub page allocations fallback to
>     vmalloc when CONFIG_HIGHMEM=y

Matthew has suggested a much more viable way to go around this. We do
not really want to allow an unbound kernel allocation - even if the
interface is root only.

Besides that, the following doesn't make much sense to me. It simply
makes no sense to use vmalloc for sub page allocation regardless of
HIGHMEM.

> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..7b1c59b9bfbf 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -416,10 +416,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	ret = kmalloc_node(size, kmalloc_flags, node);
>  
>  	/*
> -	 * It doesn't really make sense to fallback to vmalloc for sub page
> -	 * requests
> +	 * It only makes sense to fallback to vmalloc for sub page
> +	 * requests if we might be able to allocate highmem pages.
>  	 */
> -	if (ret || size <= PAGE_SIZE)
> +	if (ret || (!IS_ENABLED(CONFIG_HIGHMEM) && size <= PAGE_SIZE))
>  		return ret;
>  
>  	return __vmalloc_node_flags_caller(size, node, flags,
> -- 
> 2.18.0
> 

-- 
Michal Hocko
SUSE Labs
