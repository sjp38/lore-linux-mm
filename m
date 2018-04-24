Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9D186B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:28:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k76-v6so4401840lfg.9
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 04:28:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189-v6sor3262734lfa.98.2018.04.24.04.28.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 04:28:48 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:28:44 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 04/12] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180424112844.626madzs4cwoz5gh@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399121146.3456.5459546288565589098.stgit@localhost.localdomain>
 <20180422175900.dsjmm7gt2nsqj3er@esperanza>
 <14ebcccf-3ea8-59f4-d7ea-793aaba632c0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14ebcccf-3ea8-59f4-d7ea-793aaba632c0@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, Apr 23, 2018 at 01:54:50PM +0300, Kirill Tkhai wrote:
> >> @@ -1200,6 +1206,8 @@ extern int memcg_nr_cache_ids;
> >>  void memcg_get_cache_ids(void);
> >>  void memcg_put_cache_ids(void);
> >>  
> >> +extern int shrinkers_max_nr;
> >> +
> > 
> > memcg_shrinker_id_max?
> 
> memcg_shrinker_id_max sounds like an includive value, doesn't it?
> While shrinker->id < shrinker_max_nr.
> 
> Let's better use memcg_shrinker_nr_max.

or memcg_nr_shrinker_ids (to match memcg_nr_cache_ids), not sure...

Come to think of it, this variable is kinda awkward: it is defined in
vmscan.c but declared in memcontrol.h; it is used by vmscan.c for max
shrinker id and by memcontrol.c for shrinker map capacity. Just a raw
idea: what about splitting it in two: one is private to vmscan.c, used
as max id, say we call it shrinker_id_max; the other is defined in
memcontrol.c and is used for shrinker map capacity, say we call it
memcg_shrinker_map_capacity. What do you think?

> >> +int expand_shrinker_maps(int old_nr, int nr)
> >> +{
> >> +	int id, size, old_size, node, ret;
> >> +	struct mem_cgroup *memcg;
> >> +
> >> +	old_size = old_nr / BITS_PER_BYTE;
> >> +	size = nr / BITS_PER_BYTE;
> >> +
> >> +	down_write(&shrinkers_max_nr_rwsem);
> >> +	for_each_node(node) {
> > 
> > Iterating over cgroups first, numa nodes second seems like a better idea
> > to me. I think you should fold for_each_node in memcg_expand_maps.
> >
> >> +		idr_for_each_entry(&mem_cgroup_idr, memcg, id) {
> > 
> > Iterating over mem_cgroup_idr looks strange. Why don't you use
> > for_each_mem_cgroup?
> 
> We want to allocate shrinkers maps in mem_cgroup_css_alloc(), since
> mem_cgroup_css_online() mustn't fail (it's a requirement of currently
> existing design of memcg_cgroup::id).
> 
> A new memcg is added to parent's list between two of these calls:
> 
> css_create()
>   ss->css_alloc()
>   list_add_tail_rcu(&css->sibling, &parent_css->children)
>   ss->css_online()
> 
> for_each_mem_cgroup() does not see allocated, but not linked children.

Why don't we move shrinker map allocation to css_online then?

>  
> >> +			if (id == 1)
> >> +				memcg = NULL;
> >> +			ret = memcg_expand_maps(memcg, node, size, old_size);
> >> +			if (ret)
> >> +				goto unlock;
> >> +		}
> >> +
> >> +		/* root_mem_cgroup is not initialized yet */
> >> +		if (id == 0)
> >> +			ret = memcg_expand_maps(NULL, node, size, old_size);
> >> +	}
> >> +unlock:
> >> +	up_write(&shrinkers_max_nr_rwsem);
> >> +	return ret;
> >> +}
