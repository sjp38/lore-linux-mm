Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFBDB8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 04:32:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so33542119edb.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 01:32:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g51si1645993edg.7.2019.01.03.01.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 01:32:03 -0800 (PST)
Date: Thu, 3 Jan 2019 10:32:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] kmemleak: survive in a low-memory situation
Message-ID: <20190103093201.GB31793@dhcp22.suse.cz>
References: <20190102165931.GB6584@arrakis.emea.arm.com>
 <20190102180619.12392-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102180619.12392-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-01-19 13:06:19, Qian Cai wrote:
[...]
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index f9d9dc250428..9e1aa3b7df75 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>  	struct rb_node **link, *rb_parent;
>  
>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> +#ifdef CONFIG_PREEMPT_COUNT
> +	if (!object) {
> +		/* last-ditch effort in a low-memory situation */
> +		if (irqs_disabled() || is_idle_task(current) || in_atomic())
> +			gfp = GFP_ATOMIC;
> +		else
> +			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> +		object = kmem_cache_alloc(object_cache, gfp);
> +	}
> +#endif

I do not get it. How can this possibly help when gfp_kmemleak_mask()
adds __GFP_NOFAIL modifier to the given gfp mask? Or is this not the
case anymore in some tree?
-- 
Michal Hocko
SUSE Labs
