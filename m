Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B03AB6B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 14:08:28 -0400 (EDT)
Received: by mail-qe0-f53.google.com with SMTP id cz11so2919790qeb.12
        for <linux-mm@kvack.org>; Fri, 17 May 2013 11:08:27 -0700 (PDT)
Date: Fri, 17 May 2013 11:08:22 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 5/9] memcg: use css_get/put when charging/uncharging kmem
Message-ID: <20130517180822.GC12632@mtj.dyndns.org>
References: <5195D5F8.7000609@huawei.com>
 <5195D666.6030408@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5195D666.6030408@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hey,

On Fri, May 17, 2013 at 03:04:06PM +0800, Li Zefan wrote:
> +	/*
> +	 * Releases a reference taken in kmem_cgroup_css_offline in case
> +	 * this last uncharge is racing with the offlining code or it is
> +	 * outliving the memcg existence.
> +	 *
> +	 * The memory barrier imposed by test&clear is paired with the
> +	 * explicit one in kmem_cgroup_css_offline.

Paired with the wmb to achieve what?

> +	 */
>  	if (memcg_kmem_test_and_clear_dead(memcg))
> -		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);

The other side is wmb, so there gotta be something which wants to read
which were written before wmb here but the only thing after the
barrier is css_put() which doesn't need such thing, so I'm lost on
what the barrier pair is achieving here.

In general, please be *very* explicit about what's going on whenever
something is depending on barrier pairs.  It'll make it easier for
both the author and reviewers to actually understand what's going on
and why it's necessary.

...
> @@ -5858,23 +5856,39 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return mem_cgroup_sockets_init(memcg, ss);
>  }
>  
> -static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
> +static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  {
> -	mem_cgroup_sockets_destroy(memcg);
> +	if (!memcg_kmem_is_active(memcg))
> +		return;
>  
> +	/*
> +	 * kmem charges can outlive the cgroup. In the case of slab
> +	 * pages, for instance, a page contain objects from various
> +	 * processes. As we prevent from taking a reference for every
> +	 * such allocation we have to be careful when doing uncharge
> +	 * (see memcg_uncharge_kmem) and here during offlining.
> +	 *
> +	 * The idea is that that only the _last_ uncharge which sees
> +	 * the dead memcg will drop the last reference. An additional
> +	 * reference is taken here before the group is marked dead
> +	 * which is then paired with css_put during uncharge resp. here.
> +	 *
> +	 * Although this might sound strange as this path is called when
> +	 * the reference has already dropped down to 0 and shouldn't be
> +	 * incremented anymore (css_tryget would fail) we do not have

Hmmm?  offline is called on cgroup destruction regardless of css
refcnt.  The above comment seems a bit misleading.

> +	 * other options because of the kmem allocations lifetime.
> +	 */
> +	css_get(&memcg->css);
> +
> +	/* see comment in memcg_uncharge_kmem() */
> +	wmb();
>  	memcg_kmem_mark_dead(memcg);

Is the wmb() trying to prevent reordering between css_get() and
memcg_kmem_mark_dead()?  If so, it isn't necessary - the compiler
isn't allowed to reorder two atomic ops (they're all asm volatiles)
and the visibility order is guaranteed by the nature of the two
operations going on here - both perform modify-and-test on one end of
the operations.

It could be argued that having memory barriers is better for
completeness of mark/test interface but then those barriers should
really moved into memcg_kmem_mark_dead() and its clearing counterpart.

While it's all clever and dandy, my recommendation would be just using
a lock for synchronization.  It isn't a hot path.  Why be clever?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
