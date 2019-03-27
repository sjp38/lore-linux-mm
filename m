Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA04C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6E222177E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6E222177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3078C6B0288; Wed, 27 Mar 2019 14:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2948E6B028A; Wed, 27 Mar 2019 14:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F36946B028B; Wed, 27 Mar 2019 14:17:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9576A6B0288
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:17:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x13so7010810edq.11
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:17:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OTWYbYe2Q/M3WJ4IR/QJrkJ5ajzzsFDhK9Xd8IYSGEc=;
        b=ZyBArCfCwVD3hGgve/PJEu4Ea29yCyv6N93W0ZWKXHEK5P7xJ1qEYAGLyx8zS/lkxM
         p/+pikyBq/tLKwbdal5p+t+4c84Lkyj7nIFcvZa/JrLEzzBlheFitubX8LJ4SpC2HYrq
         PBmVlgoPzXBUHzoQ3NJ8j8CDlqQjuBPfveMaWCA1EFSRWuLmTkkwrE54aO3cPmZ6+dRF
         T00lhbAQJLi/34L/4a/LYkLGreh9Wj80NOV/ZMTwQ5T9D8lO5i4ahj0jCV+XARkD7A/c
         Fgp3ka8oV97Oaa5QpM+a1ceyz336jLMHJK0mohpFVUSaAws4OEqUyE/SwDshAt1WHDPH
         l6XA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVUhIXj/KBbOFwSqWKVypVyzg7X9DuRmrvs0gBC36CuYFs0ukbL
	ESEkqhpx5PbVuzSFb3tYuvUMqiTL9KGihAjHlzxX7wlYoy3bNdq7pmYFgD/ZwSX0X+ZiVRqDNq+
	N5kGM8yPemIIQpdpmn3MAQ6nXQeceBrmJCeQWdaaUCWHHIiw+qgG8buNqS0sfyQ4=
X-Received: by 2002:a50:93a6:: with SMTP id o35mr24513993eda.245.1553710624146;
        Wed, 27 Mar 2019 11:17:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR9W9dxTnQT4vfta1yHwalu/iYpRk0mttgEDqW2a1iB7k809xObiFdYOAlEF54U7iYnAZP
X-Received: by 2002:a50:93a6:: with SMTP id o35mr24513952eda.245.1553710623354;
        Wed, 27 Mar 2019 11:17:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710623; cv=none;
        d=google.com; s=arc-20160816;
        b=BLtHh7PX2G86N30SFB/MQ7hl4FA/ntp8O0XMXEJ8bQKejsSveEMS6UcbQMnK81Wn5m
         OxaSLTMCiltZLFHQIkf3wWX38EYETn3QuCoEDpco9oeN41V4qoKwecdCCOsPydkwCamh
         vzXEt+uVaX9BHyfTqSbak8wAz/dJm4D6Vf/Kj02T7aEZwI4BqTa0Ye06//DmW53cPeNR
         uikI2fyIP5d8zfJPJrc1P1/rCbHbVFaMVm1wqzjLQRZZbMyIpJLH29jNNXD5CdbWn4UO
         B0XtJ3QdB/7EXMaETQ3swUZhh/vdV13jZf22luAnkTHre13tczprsLGmsN4SHQs5n2an
         4O8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OTWYbYe2Q/M3WJ4IR/QJrkJ5ajzzsFDhK9Xd8IYSGEc=;
        b=FpwbMOoMAGTYu8zj/BAAgg7SB+ttC3/nYXla83t+oRjNedbQP+ehGLOyIQitwh2xLe
         pNHxB1tGpM9FUX5CpaXYXuhuJ5soinfWg3+2H2N2YpAnHxmaR2yqxC4SNbdzV9DzEpdk
         /8uPx5RTu19PJ5DgjInXvLv/Gcw1zdSLL3AQTyF6J2i3O8d+ljVRE/UXqGu3LcK0ho64
         C/y+P/QnkDxp6SoMeqFKups99E/9Nj1uhSxGjakRc3vWeXovExxMVj+xGg8/PC98Rbpe
         ufPqP7myvYVIF+2adxX6jvUA8gQ3u2F+f4yLCHKrGJj0BiKr6vUhLv4QDOJ5wU9HLyXO
         hNXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si1179364edf.247.2019.03.27.11.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:17:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9ED1AAD73;
	Wed, 27 Mar 2019 18:17:02 +0000 (UTC)
Date: Wed, 27 Mar 2019 19:17:00 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com,
	willy@infradead.org, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190327181700.GO11927@dhcp22.suse.cz>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327172955.GB17247@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 17:29:57, Catalin Marinas wrote:
[...]
> Quick attempt below and it needs some more testing (pretty random pick
> of the EMERGENCY_POOL_SIZE value). Also, with __GFP_NOFAIL removed, are
> the other flags safe or we should trim them further?

I would be still careful about __GFP_NORETRY. I pressume that the
primary purpose is to prevent from the OOM killer but this makes the
allocation failure much more likely. So if anything __GFP_RETRY_MAYFAIL
would suite better for that purpose. But I am not really sure that this
is worth bothering.

> ---------------8<-------------------------------
> >From dc4194539f8191bb754901cea74c86e7960886f8 Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Wed, 27 Mar 2019 17:20:57 +0000
> Subject: [PATCH] mm: kmemleak: Add an emergency allocation pool for kmemleak
>  objects
> 
> This patch adds an emergency pool for struct kmemleak_object in case the
> normal kmem_cache_alloc() fails under the gfp constraints passed by the
> slab allocation caller. The patch also removes __GFP_NOFAIL which does
> not play well with other gfp flags (introduced by commit d9570ee3bd1d,
> "kmemleak: allow to coexist with fault injection").

Thank you! This is definitely a step into the right direction. Maybe the
pool allocation logic will need some tuning - e.g. does it make sense to
allocate into the pool from sleepable allocations - or is it sufficient
to refill on free. Something for the real workloads to tell, I guess.

> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  mm/kmemleak.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 57 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 6c318f5ac234..366a680cff7c 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -127,7 +127,7 @@
>  /* GFP bitmask for kmemleak internal allocations */
>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN)
>  
>  /* scanning area inside a memory block */
>  struct kmemleak_scan_area {
> @@ -191,11 +191,16 @@ struct kmemleak_object {
>  #define HEX_ASCII		1
>  /* max number of lines to be printed */
>  #define HEX_MAX_LINES		2
> +/* minimum emergency pool size */
> +#define EMERGENCY_POOL_SIZE	(NR_CPUS * 4)
>  
>  /* the list of all allocated objects */
>  static LIST_HEAD(object_list);
>  /* the list of gray-colored objects (see color_gray comment below) */
>  static LIST_HEAD(gray_list);
> +/* emergency pool allocation */
> +static LIST_HEAD(emergency_list);
> +static int emergency_pool_size;
>  /* search tree for object boundaries */
>  static struct rb_root object_tree_root = RB_ROOT;
>  /* rw_lock protecting the access to object_list and object_tree_root */
> @@ -467,6 +472,43 @@ static int get_object(struct kmemleak_object *object)
>  	return atomic_inc_not_zero(&object->use_count);
>  }
>  
> +/*
> + * Emergency pool allocation and freeing. kmemleak_lock must not be held.
> + */
> +static struct kmemleak_object *emergency_alloc(void)
> +{
> +	unsigned long flags;
> +	struct kmemleak_object *object;
> +
> +	write_lock_irqsave(&kmemleak_lock, flags);
> +	object = list_first_entry_or_null(&emergency_list, typeof(*object), object_list);
> +	if (object) {
> +		list_del(&object->object_list);
> +		emergency_pool_size--;
> +	}
> +	write_unlock_irqrestore(&kmemleak_lock, flags);
> +
> +	return object;
> +}
> +
> +/*
> + * Return true if object added to the emergency pool, false otherwise.
> + */
> +static bool emergency_free(struct kmemleak_object *object)
> +{
> +	unsigned long flags;
> +
> +	if (emergency_pool_size >= EMERGENCY_POOL_SIZE)
> +		return false;
> +
> +	write_lock_irqsave(&kmemleak_lock, flags);
> +	list_add(&object->object_list, &emergency_list);
> +	emergency_pool_size++;
> +	write_unlock_irqrestore(&kmemleak_lock, flags);
> +
> +	return true;
> +}
> +
>  /*
>   * RCU callback to free a kmemleak_object.
>   */
> @@ -485,7 +527,8 @@ static void free_object_rcu(struct rcu_head *rcu)
>  		hlist_del(&area->node);
>  		kmem_cache_free(scan_area_cache, area);
>  	}
> -	kmem_cache_free(object_cache, object);
> +	if (!emergency_free(object))
> +		kmem_cache_free(object_cache, object);
>  }
>  
>  /*
> @@ -577,6 +620,8 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>  	unsigned long untagged_ptr;
>  
>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> +	if (!object)
> +		object = emergency_alloc();
>  	if (!object) {
>  		pr_warn("Cannot allocate a kmemleak_object structure\n");
>  		kmemleak_disable();
> @@ -2127,6 +2172,16 @@ void __init kmemleak_init(void)
>  			kmemleak_warning = 0;
>  		}
>  	}
> +
> +	/* populate the emergency allocation pool */
> +	while (emergency_pool_size < EMERGENCY_POOL_SIZE) {
> +		struct kmemleak_object *object;
> +
> +		object = kmem_cache_alloc(object_cache, GFP_KERNEL);
> +		if (!object)
> +			break;
> +		emergency_free(object);
> +	}
>  }
>  
>  /*

-- 
Michal Hocko
SUSE Labs

