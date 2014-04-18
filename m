Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 772016B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:45:01 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so1632399eek.36
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 06:45:00 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 49si40381403een.35.2014.04.18.06.44.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 06:44:59 -0700 (PDT)
Date: Fri, 18 Apr 2014 09:44:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC -mm v2 2/3] memcg, slab: merge
 memcg_{bind,release}_pages to memcg_{un}charge_slab
Message-ID: <20140418134453.GC26283@cmpxchg.org>
References: <cover.1397804745.git.vdavydov@parallels.com>
 <49f7f2d048e56fac4d29dd5b39f6f76c7bdd6bec.1397804745.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49f7f2d048e56fac4d29dd5b39f6f76c7bdd6bec.1397804745.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Fri, Apr 18, 2014 at 12:04:48PM +0400, Vladimir Davydov wrote:
> Currently we have two pairs of kmemcg-related functions that are called
> on slab alloc/free. The first is memcg_{bind,release}_pages that count
> the total number of pages allocated on a kmem cache. The second is
> memcg_{un}charge_slab that {un}charge slab pages to kmemcg resource
> counter. Let's just merge them to keep the code clean.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  include/linux/memcontrol.h |    4 ++--
>  mm/memcontrol.c            |   22 ++++++++++++++++++++--
>  mm/slab.c                  |    2 --
>  mm/slab.h                  |   25 ++-----------------------
>  mm/slub.c                  |    2 --
>  5 files changed, 24 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 087a45314181..d38d190f4cec 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -506,8 +506,8 @@ void memcg_update_array_size(int num_groups);
>  struct kmem_cache *
>  __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
>  
> -int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
> -void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
> +int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
> +void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);

I like the patch overall, but why the __prefix and not just
memcg_charge_slab() and memcg_uncharge_slab()?

Not a show stopper, though:
Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
