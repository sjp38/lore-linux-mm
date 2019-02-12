Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3E17C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:57:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB7AC2184E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:57:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB7AC2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C6788E0003; Tue, 12 Feb 2019 10:57:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44EE58E0001; Tue, 12 Feb 2019 10:57:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 317AC8E0003; Tue, 12 Feb 2019 10:57:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C97C28E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:57:05 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so2636702edi.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:57:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cm83j0NN2K9ELBvH1msDS9f0zRnM765gc3HBo8Dbkes=;
        b=o+7FqL6XXhxnK9W4xxcLEzXiTUpsMht+ADEhZCaUE6G3c7fiYb7HWwXaRPRYMh3pPg
         EvqAyPLm4EgFInokDPlVAx3pJ1bhh60Icol/+QnVrAQOpLLJwu6d8WHviVwATwhj7TPh
         SixibX6mdLNVW4/Az0bvh6hiEacnIsb9UPu/cLar3jmdKJCeDsai0by+IJ2CTFkyRn7d
         e4LOwkIFCZPgk0/VzwX+wT3S4xloOphPOTiY4w6CfYHeK0V4aXWVzKRj6hUd0t1KvhHM
         IJmWvhDardBcgIvxRueSbECmzQ6sCB99O+C1XYQYX8NuLElT2GZot+YT4wXPqbx+BG3K
         TJDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: AHQUAuYV/najohvr+LmNFBIo1ibNjgGptLo/707PnthGTtfUJoG8YCPH
	sAQc26pc1XkxHHk2+TUBxiGok/aGQwWp+/wmkHh2WxJB9Cd9dJIE1cCzlnf8nCL3KJlyJmkEmKJ
	nJp1/YHxB4DTj22E7ava7av09WMsJCB8aWU1BaWeCTW9zKkVfuhRlKOaxASHLmbXRlA==
X-Received: by 2002:a17:906:11d5:: with SMTP id o21mr3238001eja.85.1549987025365;
        Tue, 12 Feb 2019 07:57:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwknC3smeBIAXFcoJ0M30vBCz+KkKz9Co+wEj264z1S/j3cBOksaRufOd+HsO1M0e7VFwd
X-Received: by 2002:a17:906:11d5:: with SMTP id o21mr3237942eja.85.1549987024330;
        Tue, 12 Feb 2019 07:57:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549987024; cv=none;
        d=google.com; s=arc-20160816;
        b=ImvwDeb/odrg7NxJuCyUACadKp37jiAl50Y4vzwNxLfGduWJAme5rCqYZscSxOnZSk
         Kk01ogZJE+t/VoRQpcEKm5JQ6gtUdayL4Haz0iyFE1gXsDJEm1aQjcmKkTDMCiKy1zOq
         vjaAlrorILByf8p03mSMoOm9B4G6GsNMG+3SSCu0syzHWT8hWENG3kUmLRuu2j+GJCNS
         4AGFfXVwSPPGW6X6BC4hmfc8bwPv432kd55tuDPbAUGMQoo2yR2rMniGSWHeBcU9SWgS
         obH8sp1YD0FEx3ubRTV6NHAFVmx8Hm6yL3CWKpSDRxardfEzJJZCv85NtzeBM7j+3w+n
         xCgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cm83j0NN2K9ELBvH1msDS9f0zRnM765gc3HBo8Dbkes=;
        b=heoL3F3yhbALOSo/XXLocTkUCIVlmm3srejupgwp5x38fvRhZ2Ftq77Xndy3qLpjeC
         x4OOd/0NV1wbVh9inpBK5zOoMteLjIznzlUSH7Yy39SYVFIIc9ohsG/i3hQqnnQVrffO
         T04qZ8SRbHtzQg8RT/t/lkiNFpcLc+2WdaUGX2w6BLqhwWZtmG+ysz/v43QT2jexUoMq
         DkZ/R0JapjVcoJ7XFGPVbrfaGkKrWWbZK9Ju2H6BP4Uv3Ntyjw2iXeDzXyRVUX2kVf7b
         Vs/9kiouagcIIEfa0uw03Hvl5BvEcAw9mndcuAW0gGU03FHXsEzEkFrFshBwyNg/MlD3
         95BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x67si6525432ede.100.2019.02.12.07.57.04
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 07:57:04 -0800 (PST)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 155C280D;
	Tue, 12 Feb 2019 07:57:03 -0800 (PST)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7401F3F557;
	Tue, 12 Feb 2019 07:57:00 -0800 (PST)
Subject: Re: [PATCH 2/5] kasan, kmemleak: pass tagged pointers to kmemleak
To: Andrey Konovalov <andreyknvl@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <cd825aa4897b0fc37d3316838993881daccbe9f5.1549921721.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <f57831be-c57a-4a9e-992e-1f193866467b@arm.com>
Date: Tue, 12 Feb 2019 15:56:58 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cd825aa4897b0fc37d3316838993881daccbe9f5.1549921721.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/02/2019 21:59, Andrey Konovalov wrote:
> Right now we call kmemleak hooks before assigning tags to pointers in
> KASAN hooks. As a result, when an objects gets allocated, kmemleak sees
> a differently tagged pointer, compared to the one it sees when the object
> gets freed. Fix it by calling KASAN hooks before kmemleak's ones.
>

Nit: Could you please add comments to the the code? It should prevent that the
code gets refactored in future, reintroducing the same issue.

> Reported-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/slab.h        | 6 ++----
>  mm/slab_common.c | 2 +-
>  mm/slub.c        | 3 ++-
>  3 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 4190c24ef0e9..638ea1b25d39 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -437,11 +437,9 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
>  
>  	flags &= gfp_allowed_mask;
>  	for (i = 0; i < size; i++) {
> -		void *object = p[i];
> -
> -		kmemleak_alloc_recursive(object, s->object_size, 1,
> +		p[i] = kasan_slab_alloc(s, p[i], flags);
> +		kmemleak_alloc_recursive(p[i], s->object_size, 1,
>  					 s->flags, flags);
> -		p[i] = kasan_slab_alloc(s, object, flags);
>  	}
>  
>  	if (memcg_kmem_enabled())
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 81732d05e74a..fe524c8d0246 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1228,8 +1228,8 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>  	flags |= __GFP_COMP;
>  	page = alloc_pages(flags, order);
>  	ret = page ? page_address(page) : NULL;
> -	kmemleak_alloc(ret, size, 1, flags);
>  	ret = kasan_kmalloc_large(ret, size, flags);
> +	kmemleak_alloc(ret, size, 1, flags);
>  	return ret;
>  }
>  EXPORT_SYMBOL(kmalloc_order);
> diff --git a/mm/slub.c b/mm/slub.c
> index 1e3d0ec4e200..4a3d7686902f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1374,8 +1374,9 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
>   */
>  static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
>  {
> +	ptr = kasan_kmalloc_large(ptr, size, flags);
>  	kmemleak_alloc(ptr, size, 1, flags);
> -	return kasan_kmalloc_large(ptr, size, flags);
> +	return ptr;
>  }
>  
>  static __always_inline void kfree_hook(void *x)
> 

-- 
Regards,
Vincenzo

