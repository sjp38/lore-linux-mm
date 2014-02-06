Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id B4C6D6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 19:32:25 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id t61so1784041wes.8
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 16:32:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si1265234wij.24.2014.02.06.07.29.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 07:30:15 -0800 (PST)
Date: Thu, 6 Feb 2014 16:29:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
Message-ID: <20140206152944.GG20269@dhcp22.suse.cz>
References: <cover.1391356789.git.vdavydov@parallels.com>
 <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com>
 <20140204145210.GH4890@dhcp22.suse.cz>
 <52F1004B.90307@parallels.com>
 <20140204151145.GI4890@dhcp22.suse.cz>
 <52F106D7.3060802@parallels.com>
 <20140206140707.GF20269@dhcp22.suse.cz>
 <52F39916.2040603@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F39916.2040603@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Thu 06-02-14 18:15:50, Vladimir Davydov wrote:
> On 02/06/2014 06:07 PM, Michal Hocko wrote:
> > On Tue 04-02-14 19:27:19, Vladimir Davydov wrote:
> > [...]
> >> What does this patch change? Actually, it introduces no functional
> >> changes - it only remove the code trying to find an alias for a memcg
> >> cache, because it will fail anyway. So this is rather a cleanup.
> > But this also means that two different memcgs might share the same cache
> > and so the pages for that cache, no?
> 
> No, because in this patch I explicitly forbid to merge memcg caches by
> this hunk:
> 
> @@ -200,9 +200,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg,
> const char *name, size_t size,
>       */
>      flags &= CACHE_CREATE_MASK;
>  
> -    s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
> -    if (s)
> -        goto out_unlock;
> +    if (!memcg) {
> +        s = __kmem_cache_alias(name, size, align, flags, ctor);
> +        if (s)
> +            goto out_unlock;
> +    }

Ohh, that was the missing part. Thanks and sorry I have missed it. Maybe
it is worth mentioning in the changelog?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
