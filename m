Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27E676B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 13:56:45 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u2-v6so5755818lfu.18
        for <linux-mm@kvack.org>; Mon, 21 May 2018 10:56:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2-v6sor3370947lfg.58.2018.05.21.10.56.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 10:56:43 -0700 (PDT)
Date: Mon, 21 May 2018 20:56:40 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v6 14/17] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180521175640.twrlrqkg7bxoqowa@esperanza>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663304128.5308.12840831728812876902.stgit@localhost.localdomain>
 <20180520080003.gfygtb6rloqpjaol@esperanza>
 <9eae0da6-5981-1ab2-af86-0a62ee31ba17@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9eae0da6-5981-1ab2-af86-0a62ee31ba17@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, May 21, 2018 at 12:17:07PM +0300, Kirill Tkhai wrote:
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
> >> +	 * 1) Caller passes only alive memcg, so map can't be NULL.
> >> +	 * 2) shrinker_rwsem protects from maps expanding.
> >> +	 */
> >> +	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
> >> +					true);
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
> >> +		if (unlikely(!shrinker)) {
> > 
> > Nit: I don't think 'unlikely' is required here as this is definitely not
> > a hot path.
> 
> In case of big machines with many containers and overcommit, shrink_slab()
> in general is very hot path. See the patchset description. There are configurations,
> when only shrink_slab() is executing and occupies cpu for 100%, it's the reason
> of this patchset is made for.
> 
> Here is the place we are absolutely sure shrinker is NULL in case if race with parallel
> registering, so I don't see anything wrong to give compiler some information about branch
> prediction.

OK. If you're confident this 'unlikely' is useful, let's leave it as is.
