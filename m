Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 63E716B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 16:19:32 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so12832515yhz.22
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 13:19:32 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id q18si40260321qeu.6.2013.12.05.13.19.30
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 13:19:31 -0800 (PST)
Date: Fri, 6 Dec 2013 08:19:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 10/18] memcg,list_lru: add per-memcg LRU list
 infrastructure
Message-ID: <20131205211926.GO10988@dastard>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <73d7942f31ac80dfa53bbdd0f957ce5e9a301958.1385974612.git.vdavydov@parallels.com>
 <20131203111808.GE8803@dastard>
 <529DCE9A.8000802@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529DCE9A.8000802@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 03, 2013 at 04:29:14PM +0400, Vladimir Davydov wrote:
> On 12/03/2013 03:18 PM, Dave Chinner wrote:
> > On Mon, Dec 02, 2013 at 03:19:45PM +0400, Vladimir Davydov wrote:
> >> FS-shrinkers, which shrink dcaches and icaches, keep dentries and inodes
> >> in list_lru structures in order to evict least recently used objects.
> >> With per-memcg kmem shrinking infrastructure introduced, we have to make
> >> those LRU lists per-memcg in order to allow shrinking FS caches that
> >> belong to different memory cgroups independently.
> >>
> >> This patch addresses the issue by introducing struct memcg_list_lru.
> >> This struct aggregates list_lru objects for each kmem-active memcg, and
> >> keeps it uptodate whenever a memcg is created or destroyed. Its
> >> interface is very simple: it only allows to get the pointer to the
> >> appropriate list_lru object from a memcg or a kmem ptr, which should be
> >> further operated with conventional list_lru methods.
> > Basically The idea was that the memcg LRUs hide entirely behind the
> > generic list_lru interface so that any cache that used the list_lru
> > insfrastructure got memcg capabilities for free. memcg's to shrink
> > were to be passed through the shrinker control shrinkers to the list
> > LRU code, and it then did all the "which lru are we using" logic
> > internally.
> >
> > What you've done is driven all the "which LRU are we using" logic
> > into every single caller location. i.e. you've just broken the
> > underlying design principle that Glauber and I had worked towards
> > with this code - that memcg aware LRUs should be completely
> > transparent to list_lru users. Just like NUMA awareness came for
> > free with the list_lru code, so should memcg awareness....
> >
> >> +/*
> >> + * The following structure can be used to reclaim kmem objects accounted to
> >> + * different memory cgroups independently. It aggregates a set of list_lru
> >> + * objects, one for each kmem-enabled memcg, and provides the method to get
> >> + * the lru corresponding to a memcg.
> >> + */
> >> +struct memcg_list_lru {
> >> +	struct list_lru global_lru;
> >> +
> >> +#ifdef CONFIG_MEMCG_KMEM
> >> +	struct list_lru **memcg_lrus;	/* rcu-protected array of per-memcg
> >> +					   lrus, indexed by memcg_cache_id() */
> >> +
> >> +	struct list_head list;		/* list of all memcg-aware lrus */
> >> +
> >> +	/*
> >> +	 * The memcg_lrus array is rcu protected, so we can only free it after
> >> +	 * a call to synchronize_rcu(). To avoid multiple calls to
> >> +	 * synchronize_rcu() when many lrus get updated at the same time, which
> >> +	 * is a typical scenario, we will store the pointer to the previous
> >> +	 * version of the array in the old_lrus variable for each lru, and then
> >> +	 * free them all at once after a single call to synchronize_rcu().
> >> +	 */
> >> +	void *old_lrus;
> >> +#endif
> >> +};
> > Really, this should be embedded in the struct list_lru, not wrapping
> > around the outside. I don't see any changelog to tell me why you
> > changed the code from what was last in Glauber's tree, so can you
> > explain why exposing all this memcg stuff to everyone is a good
> > idea?
> 
> I preferred to move from list_lru to memcg_list_lru, because the
> connection between list_lru and memcgs' turned memcontrol.c and
> list_lru.c into a monolithic structure. When I read comments to the last
> version of this patchset submitted by Glauber (v10), I found that Andrew
> Morton disliked it, that was why I tried to "fix" it the way you observe
> in this patch. Besides, I though that the list_lru may be used w/o memcgs.

Yes, the list_lru can be used without memcgs. That's the point
of having a generic list_lru API - we are able to add more
fucntionality to the list_lru implemenation without needing to
change all the users of the API.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
