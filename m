Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 4B6346B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:31:06 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9083283pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:31:05 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:31:01 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 12/16] memcg/sl[au]b Track all the memcg children of
 a kmem_cache.
Message-ID: <20120921203101.GP7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-13-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-13-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Tue, Sep 18, 2012 at 06:12:06PM +0400, Glauber Costa wrote:
> This enables us to remove all the children of a kmem_cache being
> destroyed, if for example the kernel module it's being used in
> gets unloaded. Otherwise, the children will still point to the
> destroyed parent.

I find the terms parent / child / sibling a bit confusing.  It usually
implies proper tree structure.  Maybe we can use better terms which
reflect the single layer structure better?

And, again, in general, please add some comments.  If someone tries to
understand this for the first time and takes a look at
mem_cgroup_cache_params, there's almost nothing to guide that person.
What's the struct for?  What does each field do?  What are the
synchronization rules?

> @@ -626,6 +630,9 @@ void memcg_release_cache(struct kmem_cache *cachep)
>  {
>  	if (cachep->memcg_params.id != -1)
>  		ida_simple_remove(&cache_types, cachep->memcg_params.id);
> +	else
> +		list_del(&cachep->memcg_params.sibling_list);
> +

list_del_init() please.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
