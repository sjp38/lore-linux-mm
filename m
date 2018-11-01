Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6CC76B0010
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:24:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x1-v6so11855923edh.8
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:24:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14-v6si7907753edc.260.2018.11.01.03.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:24:06 -0700 (PDT)
Date: Thu, 1 Nov 2018 11:24:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
Message-ID: <20181101102405.GE23921@dhcp22.suse.cz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154106695670.898059.5301435081426064314.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 01-11-18 13:09:16, Konstantin Khlebnikov wrote:
> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.

I would go on and say that allocations with sizes too large can actually
trigger a warning (once you have posted in the previous version outside
of the changelog area) because that might be interesting to people -
there are deployments to panic on warning and then a warning is much
more important.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/util.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..f5f04fa22814 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -392,6 +392,9 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	gfp_t kmalloc_flags = flags;
>  	void *ret;
>  
> +	if (size > KMALLOC_MAX_SIZE)
> +		goto fallback;
> +
>  	/*
>  	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>  	 * so the given set of flags has to be compatible.
> @@ -422,6 +425,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
>  
> +fallback:
>  	return __vmalloc_node_flags_caller(size, node, flags,
>  			__builtin_return_address(0));
>  }
> 

-- 
Michal Hocko
SUSE Labs
