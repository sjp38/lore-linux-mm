Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 5C68A6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 18:04:17 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so310700pbb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 15:04:16 -0700 (PDT)
Date: Tue, 15 May 2012 15:04:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 01/29] slab: dup name string
In-Reply-To: <1336758272-24284-2-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1205151502000.18595@chino.kir.corp.google.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 11 May 2012, Glauber Costa wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index e901a36..91b9c13 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2118,6 +2118,7 @@ static void __kmem_cache_destroy(struct kmem_cache *cachep)
>  			kfree(l3);
>  		}
>  	}
> +	kfree(cachep->name);
>  	kmem_cache_free(&cache_cache, cachep);
>  }
>  
> @@ -2526,7 +2527,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
>  		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
>  	}
>  	cachep->ctor = ctor;
> -	cachep->name = name;
> +	cachep->name = kstrdup(name, GFP_KERNEL);
>  
>  	if (setup_cpu_cache(cachep, gfp)) {
>  		__kmem_cache_destroy(cachep);

Couple problems:

 - allocating memory for a string of an unknown, unchecked size, and

 - could potentially return NULL which I suspect will cause problems 
   later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
