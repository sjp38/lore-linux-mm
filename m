Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EB0D56B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:54:09 -0400 (EDT)
Date: Fri, 7 Jun 2013 17:54:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not account memory used for cache creation
Message-ID: <20130607155406.GL8117@dhcp22.suse.cz>
References: <1370355059-24968-1-git-send-email-glommer@openvz.org>
 <20130607092132.GE8117@dhcp22.suse.cz>
 <51B1B1E9.1020701@parallels.com>
 <20130607141204.GG8117@dhcp22.suse.cz>
 <51B1F1FD.7000002@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B1F1FD.7000002@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Fri 07-06-13 18:45:17, Glauber Costa wrote:
> On 06/07/2013 06:12 PM, Michal Hocko wrote:
> >On Fri 07-06-13 14:11:53, Glauber Costa wrote:
> >>On 06/07/2013 01:21 PM, Michal Hocko wrote:
> >>>On Tue 04-06-13 18:10:59, Glauber Costa wrote:
> >>>>The memory we used to hold the memcg arrays is currently accounted to
> >>>>the current memcg.
> >>>
> >>>Maybe I have missed a train but I thought that only some caches are
> >>>tracked and those have to be enabled explicitly by using __GFP_KMEMCG in
> >>>gfp flags.
> >>
> >>No, all caches are tracked. This was set a long time ago, and only a
> >>very few initial versions differed from this. This barely changed over
> >>the lifetime of the memcg patchset.
> >>
> >>You probably got confused, due to the fact that only some *allocations*
> >
> >OK, I was really imprecise. Of course any type of cache might be tracked
> >should the allocation (which takes gfp) say so. What I have missed is
> >that not only stack allocations say so but also kmalloc itself enforces
> >that rather than the actual caller of kmalloc. This is definitely new
> >to me. And it is quite confusing that the flag is set only for large
> >allocations (kmalloc_order) or am I just missing other parts where
> >__GFP_KMEMCG is set unconditionally?
> >
> >I really have to go and dive into the code.
> >
> 
> Here is where you are getting your confusion: we don't track caches,
> we track *pages*.
> 
> Everytime you pass GFP_KMEMCG to a *page* allocation, it gets tracked.
> Every memcg cache - IOW, a memcg copy of a slab cache, sets
> GFP_KMEMCG for all its allocations.

yes that is clear to me.

> Now, the slub - and this is really an implementation detail -
> doesn't have caches for high order kmalloc caches. Instead, it gets
> pages directly from the page allocator. So we have to mark them
> explicitly. (they are a cache, they are just not implemented as
> such)

I am still confused. If kmalloc_large_node is called because the size of
the object is larger than SLUB_MAX_SIZE then __GFP_KMEMCG is added
automatically regardless what _caller_ of kmalloc said. What am I
missing?
 
> The slab doesn't do that, so all kmalloc caches are just normal caches.
> 
> Also note that kmalloc is a *kind* of cache, but not *the caches*.
> Here we are talking dentries, inodes, everything.

> We track *pages* allocated for all those caches.

Yes, that is clear.
 
> >>are tracked, but in particular, all cache + stack ones are. All child
> >>caches that are created set the __GFP_KMEMCG flag, because those pages
> >>should all belong to a cgroup.
> >>
> >>>
> >>>But d79923fa "sl[au]b: allocate objects from memcg cache" seems to be
> >>>setting gfp unconditionally for large caches. The changelog doesn't
> >>>explain why, though? This is really confusing.
> >>For all caches.
> >>
> >>Again, not all *allocations* are market, but all cache allocations are.
> >>All pages that belong to a memcg cache should obviously be accounted.
> >
> >What is memcg cache?
> >
> 
> A memcg-local copy of a slab cache.

OK
 
> >Sorry about the offtopic question but why only large allocations are
> >marked for tracking? The changelog doesn't mention that.
> >
> 
> Don't worry about the question. As for the large allocations, I hope
> the answer I provided below addresses it. If you are still not
> getting it, let me know.
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
