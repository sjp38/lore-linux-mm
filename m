Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 04DD16B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:40:29 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so5761513yhz.8
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:29 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id q66si14739214yhm.79.2013.12.11.17.40.27
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 17:40:29 -0800 (PST)
Date: Thu, 12 Dec 2013 12:40:23 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v13 11/16] mm: list_lru: add per-memcg lists
Message-ID: <20131212014023.GG31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
 <0ca62dbfbf545edb22b86bd11c50e9017a3dc4db.1386571280.git.vdavydov@parallels.com>
 <20131210050005.GC31386@dastard>
 <52A6E77B.3090106@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A6E77B.3090106@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 10, 2013 at 02:05:47PM +0400, Vladimir Davydov wrote:
> Hi, David
> 
> First of all, let me thank you for such a thorough review. It is really
> helpful. As usual, I can't help agreeing with most of your comments, but
> there are a couple of things I'd like to clarify. Please, see comments
> inline.

No worries - I just want ot make sure that we integrate this as
cleanly as possible ;)

> I agree that such a setup would not only reduce memory consumption, but
> also make the code look much clearer removing these ugly "list_lru_one"
> and "olru" I had to introduce. However, it would also make us scan memcg
> LRUs more aggressively than usual NUMA-aware LRUs on global pressure (I
> mean kswapd's would scan them on each node). I don't think it's much of
> concern though, because this is what we had for all shrinkers before
> NUMA-awareness was introduced. Besides, prioritizing memcg LRUs reclaim
> over global LRUs sounds sane. That said I like this idea. Thanks.

Right, and given that in most cases where these memcg LRUs are going
to be important are containerised systems where they are typically
small, the scalability of per-node LRU lists is not really needed.
And, as such, having a single LRU for them means that reclaim will
be slightly more predictable within the memcg....

> >> +int list_lru_init(struct list_lru *lru)
> >> +{
> >> +	int err;
> >> +
> >> +	err = list_lru_init_one(&lru->global);
> >> +	if (err)
> >> +		goto fail;
> >> +
> >> +	err = memcg_list_lru_init(lru);
> >> +	if (err)
> >> +		goto fail;
> >> +
> >> +	return 0;
> >> +fail:
> >> +	list_lru_destroy_one(&lru->global);
> >> +	lru->global.node = NULL; /* see list_lru_destroy() */
> >> +	return err;
> >> +}
> > I suspect we have users of list_lru that don't want memcg bits added
> > to them. Hence I think we want to leave list_lru_init() alone and
> > add a list_lru_init_memcg() variant that makes the LRU memcg aware.
> > i.e. if the shrinker is not going to be memcg aware, then we don't
> > want the LRU to be memcg aware, either....
> 
> I though that we want to make all LRUs per-memcg automatically, just
> like it was with NUMA awareness. After your explanation about some
> FS-specific caches (gfs2/xfs dquot), I admit I was wrong, and not all
> caches require per-memcg shrinking. I'll add a flag to list_lru_init()
> specifying if we want memcg awareness.

Keep in mind that this may extend to the declaration of slab caches.
For example, XFS has a huge number of internal caches (see
xfs_init_zones()) and in reality, no allocation to any of these
other than the xfs inode slab should be accounted to a memcg. i.e.
the objects allocated out of them are filesystem objects that have
global scope and so shouldn't be owned/accounted to a memcg as
such...


> >> +int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size)
> >> +{
> >> +	int i;
> >> +	struct list_lru_one **memcg_lrus;
> >> +
> >> +	memcg_lrus = kcalloc(new_array_size, sizeof(*memcg_lrus), GFP_KERNEL);
> >> +	if (!memcg_lrus)
> >> +		return -ENOMEM;
> >> +
> >> +	if (lru->memcg) {
> >> +		for_each_memcg_cache_index(i) {
> >> +			if (lru->memcg[i])
> >> +				memcg_lrus[i] = lru->memcg[i];
> >> +		}
> >> +	}
> > Um, krealloc()?
> 
> Not exactly. We have to keep the old version until we call sync_rcu.

Ah, of course. Could you add a big comment explaining this so that
the next reader doesn't suggest replacing it with krealloc(), too?

> >> +int memcg_list_lru_init(struct list_lru *lru)
> >> +{
> >> +	int err = 0;
> >> +	int i;
> >> +	struct mem_cgroup *memcg;
> >> +
> >> +	lru->memcg = NULL;
> >> +	lru->memcg_old = NULL;
> >> +
> >> +	mutex_lock(&memcg_create_mutex);
> >> +	if (!memcg_kmem_enabled())
> >> +		goto out_list_add;
> >> +
> >> +	lru->memcg = kcalloc(memcg_limited_groups_array_size,
> >> +			     sizeof(*lru->memcg), GFP_KERNEL);
> >> +	if (!lru->memcg) {
> >> +		err = -ENOMEM;
> >> +		goto out;
> >> +	}
> >> +
> >> +	for_each_mem_cgroup(memcg) {
> >> +		int memcg_id;
> >> +
> >> +		memcg_id = memcg_cache_id(memcg);
> >> +		if (memcg_id < 0)
> >> +			continue;
> >> +
> >> +		err = list_lru_memcg_alloc(lru, memcg_id);
> >> +		if (err) {
> >> +			mem_cgroup_iter_break(NULL, memcg);
> >> +			goto out_free_lru_memcg;
> >> +		}
> >> +	}
> >> +out_list_add:
> >> +	list_add(&lru->list, &all_memcg_lrus);
> >> +out:
> >> +	mutex_unlock(&memcg_create_mutex);
> >> +	return err;
> >> +
> >> +out_free_lru_memcg:
> >> +	for (i = 0; i < memcg_limited_groups_array_size; i++)
> >> +		list_lru_memcg_free(lru, i);
> >> +	kfree(lru->memcg);
> >> +	goto out;
> >> +}
> > That will probably scale even worse. Think about what happens when we
> > try to mount a bunch of filesystems in parallel - they will now
> > serialise completely on this memcg_create_mutex instantiating memcg
> > lists inside list_lru_init().
> 
> Yes, the scalability seems to be the main problem here. I have a couple
> of thoughts on how it could be improved. Here they go:
> 
> 1) We can turn memcg_create_mutex to rw-semaphore (or introduce an
> rw-semaphore, which we would take for modifying list_lru's) and take it
> for reading in memcg_list_lru_init() and for writing when we create a
> new memcg (memcg_init_all_lrus()).
> This would remove the bottleneck from the mount path, but every memcg
> creation would still iterate over all LRUs under a memcg mutex. So I
> guess it is not an option, isn't it?

Right - it's not so much that there is a mutex to protect the init,
it's how long it's held that will be the issue. I mean, we don't
need to hold the memcg_create_mutex until we've completely
initialised the lru structure and are ready to add it to the
all_memcg_lrus list, right?

i.e. restructing it so that you don't need to hold the mutex until
you make the LRU list globally visible would solve the problem just
as well. if we can iterate the memcgs lists without holding a lock,
then we can init the per-memcg lru lists without holding a lock
because nobody will access them through the list_lru structure
because it's not yet been published.

That keeps the locking simple, and we get scalability because we've
reduced the lock's scope to just a few instructures instead of a
memcg iteration and a heap of memory allocation....

> 2) We could use cmpxchg() instead of a mutex in list_lru_init_memcg()
> and memcg_init_all_lrus() to assure a memcg LRU is initialized only
> once. But again, this would not remove iteration over all LRUs from
> memcg_init_all_lrus().
> 
> 3) We can try to initialize per-memcg LRUs lazily only when we actually
> need them, similar to how we now handle per-memcg kmem caches creation.
> If list_lru_add() cannot find appropriate LRU, it will schedule a
> background worker for its initialization.

I'd prefer not to add complexity to the list_lru_add() path here.
It's frequently called, so it's a code hot path and so we should
keep it as simply as possible.

> The benefits of this approach are clear: we do not introduce any
> bottlenecks, and we lower memory consumption in case different memcgs
> use different mounts exclusively.
> However, there is one thing that bothers me. Some objects accounted to a
> memcg will go into the global LRU, which will postpone actual memcg
> destruction until global reclaim.

Yeah, that's messy. best to avoid it by doing the work at list init
time, IMO.

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
