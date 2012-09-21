Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A207D6B005D
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:40:40 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9099302pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:40:39 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:40:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 15/16] memcg/sl[au]b: shrink dead caches
Message-ID: <20120921204035.GQ7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-16-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-16-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Tue, Sep 18, 2012 at 06:12:09PM +0400, Glauber Costa wrote:
> @@ -764,10 +777,21 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  		goto out;
>  	}
>  
> +	/*
> +	 * Because the cache is expected to duplicate the string,
> +	 * we must make sure it has opportunity to copy its full
> +	 * name. Only now we can remove the dead part from it
> +	 */
> +	name = (char *)new_cachep->name;
> +	if (name)
> +		name[strlen(name) - 4] = '\0';

This is kinda nasty.  Do we really need to do this?  How long would a
dead cache stick around?

> diff --git a/mm/slab.c b/mm/slab.c
> index bd9928f..6cb4abf 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3785,6 +3785,8 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  	}
>  
>  	ac_put_obj(cachep, ac, objp);
> +
> +	kmem_cache_verify_dead(cachep);

Reaping dead caches doesn't exactly sound like a high priority thing
and adding a branch to hot path for that might not be the best way to
do it.  Why not schedule an extremely lazy deferrable delayed_work
which polls for emptiness, say, every miniute or whatever?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
