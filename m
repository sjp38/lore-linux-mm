Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E674C6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 08:03:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id g16-v6so3416252eds.20
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 05:03:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2-v6si701114ejh.114.2018.11.05.05.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 05:03:09 -0800 (PST)
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <80074d2a-2f8d-a9db-892b-105c0ad7cd47@suse.cz>
Date: Mon, 5 Nov 2018 14:03:07 +0100
MIME-Version: 1.0
In-Reply-To: <154106695670.898059.5301435081426064314.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org

On 11/1/18 11:09 AM, Konstantin Khlebnikov wrote:
> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Makes sense regardless of warnings stuff.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But it must be moved below the GFP_KERNEL check!

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
