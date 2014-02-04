Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 389D66B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:03:39 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l18so13171399wgh.5
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:03:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si12410656wja.155.2014.02.04.08.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:03:37 -0800 (PST)
Date: Tue, 4 Feb 2014 17:03:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/7] memcg, slab: separate memcg vs root cache
 creation paths
Message-ID: <20140204160336.GL4890@dhcp22.suse.cz>
References: <cover.1391441746.git.vdavydov@parallels.com>
 <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Mon 03-02-14 19:54:38, Vladimir Davydov wrote:
> Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
> memcg-only and except-for-memcg calls. To clean this up, let's create a
> separate function handling memcg caches creation. Although this will
> result in the two functions having several hunks of practically the same
> code, I guess this is the case when readability fully covers the cost of
> code duplication.

I don't know. The code is apparently cleaner because calling a function
with NULL memcg just to go via several if (memcg) branches is ugly as
hell. But having a duplicated function like this calls for a problem
later.

Would it be possible to split kmem_cache_create into memcg independant
part and do the rest in a single memcg branch?
 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  include/linux/memcontrol.h |   14 ++---
>  include/linux/slab.h       |    9 ++-
>  mm/memcontrol.c            |   16 ++----
>  mm/slab_common.c           |  130 ++++++++++++++++++++++++++------------------
>  4 files changed, 90 insertions(+), 79 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 84e4801fc36c..de79a9617e09 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
>  
>  char *memcg_create_cache_name(struct mem_cgroup *memcg,
>  			      struct kmem_cache *root_cache);
> -int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
> -			     struct kmem_cache *root_cache);
> +int memcg_alloc_cache_params(struct kmem_cache *s,
> +		struct mem_cgroup *memcg, struct kmem_cache *root_cache);

Why is the parameters ordering changed? It really doesn't help
review the patch. Also what does `s' stand for and can we use a more
descriptive name, please?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
