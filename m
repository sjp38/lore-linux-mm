Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFEF36B0006
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:18:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so5094456eds.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:18:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2-v6si771783ejx.251.2018.11.05.02.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 02:18:07 -0800 (PST)
Subject: Re: [PATCH] mm, slab: remove unnecessary unlikely()
References: <20181104125028.3572-1-tiny.windzz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2c42ba08-f78a-36f6-5a5d-21dd00861872@suse.cz>
Date: Mon, 5 Nov 2018 11:18:05 +0100
MIME-Version: 1.0
In-Reply-To: <20181104125028.3572-1-tiny.windzz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yangtao Li <tiny.windzz@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

+CC Dmitry

On 11/4/18 1:50 PM, Yangtao Li wrote:
> WARN_ON() already contains an unlikely(), so it's not necessary to use
> unlikely.
> 
> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Maybe also change it back to WARN_ON_ONCE? I already considered it while
reviewing Dmitry's patch and wasn't sure. Now I think that what can
happen is that either a kernel bug is introduced that _ONCE is enough to
catch (two separate bugs introduced to both hit this would be rare, and
in that case the second one will be reported after the first one is
fixed), or this gets called with a user-supplied value, and then we want
to avoid spamming dmesg with multiple warnings that the user could
trigger at will.

> ---
>  mm/slab_common.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 7eb8dc136c1c..4f54684f5435 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1029,10 +1029,8 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>  
>  		index = size_index[size_index_elem(size)];
>  	} else {
> -		if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
> -			WARN_ON(1);
> +		if (WARN_ON(size > KMALLOC_MAX_CACHE_SIZE))
>  			return NULL;
> -		}
>  		index = fls(size - 1);
>  	}
>  
> 
