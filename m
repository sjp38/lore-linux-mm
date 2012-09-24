Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 815B26B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 13:58:06 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so382709pbb.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:58:05 -0700 (PDT)
Date: Mon, 24 Sep 2012 10:58:01 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
Message-ID: <20120924175801.GE7694@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-7-git-send-email-glommer@parallels.com>
 <20120921205236.GT7264@google.com>
 <50601721.6040805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50601721.6040805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Sep 24, 2012 at 12:17:37PM +0400, Glauber Costa wrote:
> On 09/22/2012 12:52 AM, Tejun Heo wrote:
> > Missed some stuff.
> > 
> > On Tue, Sep 18, 2012 at 06:12:00PM +0400, Glauber Costa wrote:
> >> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >> +						  struct kmem_cache *cachep)
> >> +{
> > ...
> >> +	memcg->slabs[idx] = new_cachep;
> > ...
> >> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
> >> +					  gfp_t gfp)
> >> +{
> > ...
> >> +	return memcg->slabs[idx];
> > 
> > I think you need memory barriers for the above pair.
> > 
> > Thanks.
> > 
> 
> Why is that?
> 
> We'll either see a value, or NULL. If we see NULL, we assume the cache
> is not yet created. Not a big deal.

Because when you see !NULL cache pointer you want to be able to see
the cache fully initialized.  You need wmb between cache creation and
pointer assignment and at least read_barrier_depends() between
fetching the cache pointer and dereferencing it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
