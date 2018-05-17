Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72B496B0389
	for <linux-mm@kvack.org>; Thu, 17 May 2018 00:33:45 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f133-v6so1148569lfg.11
        for <linux-mm@kvack.org>; Wed, 16 May 2018 21:33:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c9-v6sor1144612lfb.54.2018.05.16.21.33.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 21:33:43 -0700 (PDT)
Date: Thu, 17 May 2018 07:33:40 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180517043340.wmm43ynodqa3zefq@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
 <20180515054445.nhe4zigtelkois4p@esperanza>
 <fa35589b-0696-e029-4440-d91dc4c9ab2d@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa35589b-0696-e029-4440-d91dc4c9ab2d@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, May 15, 2018 at 01:12:20PM +0300, Kirill Tkhai wrote:
> >> +#define root_mem_cgroup NULL
> > 
> > Let's instead export mem_cgroup_is_root(). In case if MEMCG is disabled
> > it will always return false.
> 
> export == move to header file

That and adding a stub function in case !MEMCG.

> >> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
> >> +			struct mem_cgroup *memcg, int priority)
> >> +{
> >> +	struct memcg_shrinker_map *map;
> >> +	unsigned long freed = 0;
> >> +	int ret, i;
> >> +
> >> +	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
> >> +		return 0;
> >> +
> >> +	if (!down_read_trylock(&shrinker_rwsem))
> >> +		return 0;
> >> +
> >> +	/*
> >> +	 * 1)Caller passes only alive memcg, so map can't be NULL.
> >> +	 * 2)shrinker_rwsem protects from maps expanding.
> > 
> >             ^^
> > Nit: space missing here :-)
> 
> I don't understand what you mean here. Please, clarify...

This is just a trivial remark regarding comment formatting. They usually
put a space between the number and the first word in the sentence, i.e.
between '1)' and 'Caller' in your case.

> 
> >> +	 */
> >> +	map = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
> >> +	BUG_ON(!map);
> >> +
> >> +	for_each_set_bit(i, map->map, memcg_shrinker_nr_max) {
> >> +		struct shrink_control sc = {
> >> +			.gfp_mask = gfp_mask,
> >> +			.nid = nid,
> >> +			.memcg = memcg,
> >> +		};
> >> +		struct shrinker *shrinker;
> >> +
> >> +		shrinker = idr_find(&shrinker_idr, i);
> >> +		if (!shrinker) {
> >> +			clear_bit(i, map->map);
> >> +			continue;
> >> +		}
> >> +		if (list_empty(&shrinker->list))
> >> +			continue;
> > 
> > I don't like using shrinker->list as an indicator that the shrinker has
> > been initialized. IMO if you do need such a check, you should split
> > shrinker_idr registration in two steps - allocate a slot in 'prealloc'
> > and set the pointer in 'register'. However, can we really encounter an
> > unregistered shrinker here? AFAIU a bit can be set in the shrinker map
> > only after the corresponding shrinker has been initialized, no?
> 
> 1)No, it's not so. Here is a race:
> cpu#0                        cpu#1                                   cpu#2
> prealloc_shrinker()
>                              prealloc_shrinker()
>                                memcg_expand_shrinker_maps()
>                                  memcg_expand_one_shrinker_map()
>                                    memset(&new->map, 0xff);          
>                                                                      do_shrink_slab() (on uninitialized LRUs)
> init LRUs
> register_shrinker_prepared()
> 
> So, the check is needed.

OK, I see.

> 
> 2)Assigning NULL pointer can't be used here, since NULL pointer is already used
> to clear unregistered shrinkers from the map. See the check right after idr_find().

But it won't break anything if we clear bit for prealloc-ed, but not yet
registered shrinkers, will it?

> 
> list_empty() is used since it's the already existing indicator, which does not
> require additional member in struct shrinker.

It just looks rather counter-intuitive to me to use shrinker->list to
differentiate between registered and unregistered shrinkers. May be, I'm
wrong. If you are sure that this is OK, I'm fine with it, but then
please add a comment here explaining what this check is needed for.

Thanks.
