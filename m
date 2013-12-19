Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 82FBB6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 03:19:43 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hk11so11290215igb.0
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 00:19:43 -0800 (PST)
Received: from relay.sw.ru (mailhub.sw.ru. [195.214.232.25])
        by mx.google.com with ESMTPS id jw1si2905557icc.127.2013.12.19.00.19.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 00:19:42 -0800 (PST)
Message-ID: <52B2AB7C.1010803@parallels.com>
Date: Thu, 19 Dec 2013 12:17:00 +0400
From: Vasily Averin <vvs@parallels.com>
MIME-Version: 1.0
Subject: Re: [Devel] [PATCH 1/6] slab: cleanup kmem_cache_create_memcg()
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
In-Reply-To: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org

On 12/18/2013 05:16 PM, Vladimir Davydov wrote:
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -176,8 +176,9 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  	get_online_cpus();
>  	mutex_lock(&slab_mutex);
>  
> -	if (!kmem_cache_sanity_check(memcg, name, size) == 0)
> -		goto out_locked;
> +	err = kmem_cache_sanity_check(memcg, name, size);
> +	if (err)
> +		goto out_unlock;
>  
>  	/*
>  	 * Some allocators will constraint the set of valid flags to a subset

Theoretically in future kmem_cache_sanity_check() can return positive value.
Probably it's better to check (err < 0) in caller ?

Thank you,
	Vasily Averin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
