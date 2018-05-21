Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 061406B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:40:47 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p124-v6so1458527lfp.22
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:40:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor3206897ljj.1.2018.05.21.11.40.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 11:40:44 -0700 (PDT)
Date: Mon, 21 May 2018 21:40:41 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v6 05/17] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180521184041.5p2zyhzu45eeihmi@esperanza>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663295709.5308.12103481076537943325.stgit@localhost.localdomain>
 <20180520072702.5ivoc5qxdbcus4td@esperanza>
 <7a5c644d-625e-a01e-a9a7-304eea13d225@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a5c644d-625e-a01e-a9a7-304eea13d225@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, May 21, 2018 at 01:16:40PM +0300, Kirill Tkhai wrote:
> >> +static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg,
> >> +					 int size, int old_size)
> > 
> > Nit: No point in passing old_size here. You can instead use
> > memcg_shrinker_map_size directly.
> 
> This is made for the readability. All the actions with global variable
> is made in the same function -- memcg_expand_shrinker_maps(), all
> the actions with local variables are also in the same -- memcg_expand_one_shrinker_map().
> Accessing memcg_shrinker_map_size in memcg_expand_one_shrinker_map()
> looks not intuitive and breaks modularity. 

I guess it depends on how you look at it. Anyway, it's nitpicking so I
won't mind if you leave it as is.

> >> +static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
> >> +{
> >> +	struct memcg_shrinker_map *map;
> >> +	int nid, size, ret = 0;
> >> +
> >> +	if (mem_cgroup_is_root(memcg))
> >> +		return 0;
> >> +
> >> +	mutex_lock(&memcg_shrinker_map_mutex);
> >> +	size = memcg_shrinker_map_size;
> >> +	for_each_node(nid) {
> >> +		map = kvzalloc(sizeof(*map) + size, GFP_KERNEL);
> >> +		if (!map) {
> > 
> >> +			memcg_free_shrinker_maps(memcg);
> > 
> > Nit: Please don't call this function under the mutex as it isn't
> > necessary. Set 'ret', break the loop, then check 'ret' after releasing
> > the mutex, and call memcg_free_shrinker_maps() if it's not 0.
> 
> No, it must be called under the mutex. See the race with memcg_expand_one_shrinker_map().
> NULL maps are not expanded, and this is the indicator we use to differ memcg, which is
> not completely online. If the allocations in memcg_alloc_shrinker_maps() fail at nid == 1,
> then freeing of nid == 0 can race with expanding.

Ah, I see, you're right.

> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 3de12a9bdf85..f09ea20d7270 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -171,6 +171,7 @@ static DECLARE_RWSEM(shrinker_rwsem);
> >>  
> >>  #ifdef CONFIG_MEMCG_KMEM
> >>  static DEFINE_IDR(shrinker_idr);
> > 
> >> +static int memcg_shrinker_nr_max;
> > 
> > Nit: Please rename it to shrinker_id_max and make it store max shrinker
> > id, not the max number shrinkers that have ever been allocated. This
> > will make it easier to understand IMO.
> >
> > Also, this variable doesn't belong to this patch as you don't really
> > need it to expaned mem cgroup maps. Let's please move it to patch 3
> > (the one that introduces shrinker_idr).
> > 
> >>  
> >>  static int prealloc_memcg_shrinker(struct shrinker *shrinker)
> >>  {
> >> @@ -181,6 +182,15 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
> >>  	ret = id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
> >>  	if (ret < 0)
> >>  		goto unlock;
> > 
> >> +
> >> +	if (id >= memcg_shrinker_nr_max) {
> >> +		if (memcg_expand_shrinker_maps(id + 1)) {
> >> +			idr_remove(&shrinker_idr, id);
> >> +			goto unlock;
> >> +		}
> >> +		memcg_shrinker_nr_max = id + 1;
> >> +	}
> >> +
> > 
> > Then we'll have here:
> > 
> > 	if (memcg_expaned_shrinker_maps(id)) {
> > 		idr_remove(shrinker_idr, id);
> > 		goto unlock;
> > 	}
> > 
> > and from patch 3:
> > 
> > 	shrinker_id_max = MAX(shrinker_id_max, id);
> 
> So, shrinker_id_max contains "the max number shrinkers that have ever been allocated" minus 1.
> The only difference to existing logic is "minus 1", which will be needed to reflect in
> shrink_slab_memcg()->for_each_set_bit()...
> 
> To have "minus 1" instead of "not to have minus 1" looks a little subjective.

OK, leave 'nr' then, but please consider my other comments:

 - rename memcg_shrinker_nr_max to shrinker_nr_max so that the variable
   name is consistent with shrinker_idr

 - move shrinker_nr_max to patch 3 as you don't need it for expanding
   memcg shrinker maps

 - don't use shrinker_nr_max to check whether we need to expand memcg
   maps - simply call memcg_expand_shrinker_maps() and let it decide -
   this will neatly isolate all the logic related to memcg shrinker map
   allocation in memcontrol.c
