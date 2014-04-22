Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 60EBF6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:30:58 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so4498780eei.0
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:30:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si59045942eef.352.2014.04.22.03.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:30:56 -0700 (PDT)
Date: Tue, 22 Apr 2014 12:30:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + slub-fix-memcg_propagate_slab_attrs.patch added to -mm tree
Message-ID: <20140422103051.GH29311@dhcp22.suse.cz>
References: <53518631.cuNCoAbpOk1NRWDf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53518631.cuNCoAbpOk1NRWDf%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mm-commits@vger.kernel.org, penberg@kernel.org, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri 18-04-14 13:08:17, Andrew Morton wrote:
[...]
> From: Vladimir Davydov <vdavydov@parallels.com>
> Subject: slub: fix memcg_propagate_slab_attrs
> 
> After creating a cache for a memcg we should initialize its sysfs attrs
> with the values from its parent.  That's what memcg_propagate_slab_attrs
> is for.  Currently it's broken - we clearly muddled root-vs-memcg caches
> there.  Let's fix it up.

Andrew didn't so I'll do. What is the effect of the mismatch? I am
really drowning in that code...

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/slub.c |   11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff -puN mm/slub.c~slub-fix-memcg_propagate_slab_attrs mm/slub.c
> --- a/mm/slub.c~slub-fix-memcg_propagate_slab_attrs
> +++ a/mm/slub.c
> @@ -5071,15 +5071,18 @@ static void memcg_propagate_slab_attrs(s
>  #ifdef CONFIG_MEMCG_KMEM
>  	int i;
>  	char *buffer = NULL;
> +	struct kmem_cache *root_cache;
>  
> -	if (!is_root_cache(s))
> +	if (is_root_cache(s))
>  		return;
>  
> +	root_cache = s->memcg_params->root_cache;
> +
>  	/*
>  	 * This mean this cache had no attribute written. Therefore, no point
>  	 * in copying default values around
>  	 */
> -	if (!s->max_attr_size)
> +	if (!root_cache->max_attr_size)
>  		return;
>  
>  	for (i = 0; i < ARRAY_SIZE(slab_attrs); i++) {
> @@ -5101,7 +5104,7 @@ static void memcg_propagate_slab_attrs(s
>  		 */
>  		if (buffer)
>  			buf = buffer;
> -		else if (s->max_attr_size < ARRAY_SIZE(mbuf))
> +		else if (root_cache->max_attr_size < ARRAY_SIZE(mbuf))
>  			buf = mbuf;
>  		else {
>  			buffer = (char *) get_zeroed_page(GFP_KERNEL);
> @@ -5110,7 +5113,7 @@ static void memcg_propagate_slab_attrs(s
>  			buf = buffer;
>  		}
>  
> -		attr->show(s->memcg_params->root_cache, buf);
> +		attr->show(root_cache, buf);
>  		attr->store(s, buf, strlen(buf));
>  	}
>  
> _
> 
> Patches currently in -mm which might be from vdavydov@parallels.com are
> 
> slub-fix-memcg_propagate_slab_attrs.patch
> slb-charge-slabs-to-kmemcg-explicitly.patch
> mm-get-rid-of-__gfp_kmemcg.patch
> mm-get-rid-of-__gfp_kmemcg-fix.patch
> slab-document-kmalloc_order.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
