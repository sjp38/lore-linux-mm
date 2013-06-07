Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 87C466B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:12:07 -0400 (EDT)
Date: Fri, 7 Jun 2013 16:12:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not account memory used for cache creation
Message-ID: <20130607141204.GG8117@dhcp22.suse.cz>
References: <1370355059-24968-1-git-send-email-glommer@openvz.org>
 <20130607092132.GE8117@dhcp22.suse.cz>
 <51B1B1E9.1020701@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B1B1E9.1020701@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Fri 07-06-13 14:11:53, Glauber Costa wrote:
> On 06/07/2013 01:21 PM, Michal Hocko wrote:
> > On Tue 04-06-13 18:10:59, Glauber Costa wrote:
> >> The memory we used to hold the memcg arrays is currently accounted to
> >> the current memcg.
> > 
> > Maybe I have missed a train but I thought that only some caches are
> > tracked and those have to be enabled explicitly by using __GFP_KMEMCG in
> > gfp flags.
> 
> No, all caches are tracked. This was set a long time ago, and only a
> very few initial versions differed from this. This barely changed over
> the lifetime of the memcg patchset.
> 
> You probably got confused, due to the fact that only some *allocations*

OK, I was really imprecise. Of course any type of cache might be tracked
should the allocation (which takes gfp) say so. What I have missed is
that not only stack allocations say so but also kmalloc itself enforces
that rather than the actual caller of kmalloc. This is definitely new
to me. And it is quite confusing that the flag is set only for large
allocations (kmalloc_order) or am I just missing other parts where
__GFP_KMEMCG is set unconditionally?

I really have to go and dive into the code.

> are tracked, but in particular, all cache + stack ones are. All child
> caches that are created set the __GFP_KMEMCG flag, because those pages
> should all belong to a cgroup.
> 
> > 
> > But d79923fa "sl[au]b: allocate objects from memcg cache" seems to be
> > setting gfp unconditionally for large caches. The changelog doesn't
> > explain why, though? This is really confusing.
> For all caches.
> 
> Again, not all *allocations* are market, but all cache allocations are.
> All pages that belong to a memcg cache should obviously be accounted.

What is memcg cache?

Sorry about the offtopic question but why only large allocations are
marked for tracking? The changelog doesn't mention that.
 
> >> But that creates a problem, because that memory can
> >> only be freed after the last user is gone. Our only way to know which is
> >> the last user, is to hook up to freeing time, but the fact that we still
> >> have some in flight kmallocs will prevent freeing to happen. I believe
> >> therefore to be just easier to account this memory as global overhead.
> > 
> > No internal allocations for memcg can be tracked otherwise we call for a
> > problem. How do we know that others are safe?
> > 
> 
> We really need to inspect that. But in particular, all memory that is
> allocated before kmemcg becomes active is safe. Which means that struct
> memcg and all the memory it uses is safe (it will be likely billed to
> the parent, but that is perfectly fine).

Or the creator of the group which might be an admin. This sounds it
should be safe as well.

> It is also not correct to state that no memcg memory should be tracked.
> All memory allocated on behalf of a process, in particular, memcg
> memory, should in general be tracked. It is just memory, after all. The
> problem is not so much the fact that it is memcg memory, but it's lifetime.
> 
> For the record, using the memory.dangling debug file, I see all memcgs
> successfully going away after this patch + global pressure to force all
> objects to go away.
> 
> 
> >> Signed-off-by: Glauber Costa <glommer@openvz.org>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Michal Hocko <mhocko@suse.cz>
> >> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> ---
> >> I noticed this while testing nuances of the shrinker patches. The
> >> caches would basically stay present forever, even if we managed to
> >> flush all of the actual memory being used. With this patch applied,
> >> they would go away all right.
> >> ---
> >>  mm/memcontrol.c | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 5d8b93a..aa1cbd4 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -5642,7 +5642,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
> >>  	static_key_slow_inc(&memcg_kmem_enabled_key);
> >>  
> >>  	mutex_lock(&set_limit_mutex);
> >> +	memcg_stop_kmem_account();
> >>  	ret = memcg_update_cache_sizes(memcg);
> >> +	memcg_resume_kmem_account();
> >>  	mutex_unlock(&set_limit_mutex);
> >>  out:
> >>  	return ret;
> >> -- 
> >> 1.8.1.4
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
