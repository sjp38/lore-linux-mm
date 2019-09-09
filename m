Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E673C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:07:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060372086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:07:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060372086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4766B0005; Mon,  9 Sep 2019 11:07:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4FA6B0008; Mon,  9 Sep 2019 11:07:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76D366B000A; Mon,  9 Sep 2019 11:07:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id 588E46B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:07:08 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E3EB0181AC9B6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:07:07 +0000 (UTC)
X-FDA: 75915710094.13.brake91_5b544ead7b458
X-HE-Tag: brake91_5b544ead7b458
X-Filterd-Recvd-Size: 3709
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:07:07 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 279F4B67D;
	Mon,  9 Sep 2019 15:07:06 +0000 (UTC)
Subject: Re: [PATCH 3/5] mm, slab: Remove unused kmalloc_size()
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190903160430.1368-1-lpf.vector@gmail.com>
 <20190903160430.1368-4-lpf.vector@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d76b1486-78de-7f58-8cf1-a96689472932@suse.cz>
Date: Mon, 9 Sep 2019 17:07:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903160430.1368-4-lpf.vector@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/3/19 6:04 PM, Pengfei Li wrote:
> The size of kmalloc can be obtained from kmalloc_info[],
> so remove kmalloc_size() that will not be used anymore.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/slab.h | 20 --------------------
>   mm/slab.c            |  5 +++--
>   mm/slab_common.c     |  5 ++---
>   3 files changed, 5 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 56c9c7eed34e..e773e5764b7b 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -557,26 +557,6 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
>   	return __kmalloc(size, flags);
>   }
>   
> -/*
> - * Determine size used for the nth kmalloc cache.
> - * return size or 0 if a kmalloc cache for that
> - * size does not exist
> - */
> -static __always_inline unsigned int kmalloc_size(unsigned int n)
> -{
> -#ifndef CONFIG_SLOB
> -	if (n > 2)
> -		return 1U << n;
> -
> -	if (n == 1 && KMALLOC_MIN_SIZE <= 32)
> -		return 96;
> -
> -	if (n == 2 && KMALLOC_MIN_SIZE <= 64)
> -		return 192;
> -#endif
> -	return 0;
> -}
> -
>   static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>   {
>   #ifndef CONFIG_SLOB
> diff --git a/mm/slab.c b/mm/slab.c
> index c42b6211f42e..7bc4e90e1147 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1248,8 +1248,9 @@ void __init kmem_cache_init(void)
>   	 */
>   	kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE] = create_kmalloc_cache(
>   				kmalloc_info[INDEX_NODE].name[KMALLOC_NORMAL],
> -				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
> -				0, kmalloc_size(INDEX_NODE));
> +				kmalloc_info[INDEX_NODE].size,
> +				ARCH_KMALLOC_FLAGS, 0,
> +				kmalloc_info[INDEX_NODE].size);
>   	slab_state = PARTIAL_NODE;
>   	setup_kmalloc_cache_index_table();
>   
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 002e16673581..8b542cfcc4f2 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1239,11 +1239,10 @@ void __init create_kmalloc_caches(slab_flags_t flags)
>   		struct kmem_cache *s = kmalloc_caches[KMALLOC_NORMAL][i];
>   
>   		if (s) {
> -			unsigned int size = kmalloc_size(i);
> -
>   			kmalloc_caches[KMALLOC_DMA][i] = create_kmalloc_cache(
>   				kmalloc_info[i].name[KMALLOC_DMA],
> -				size, SLAB_CACHE_DMA | flags, 0, 0);
> +				kmalloc_info[i].size,
> +				SLAB_CACHE_DMA | flags, 0, 0);
>   		}
>   	}
>   #endif
> 


