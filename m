Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3E416B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:50:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u130-v6so1419570pgc.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:50:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l196-v6si1710444pga.38.2018.07.03.13.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 13:50:06 -0700 (PDT)
Date: Tue, 3 Jul 2018 13:50:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 05/17] mm: Assign memcg-aware shrinkers bitmap to
 memcg
Message-Id: <20180703135000.b2322ae0e514f028e7941d3c@linux-foundation.org>
In-Reply-To: <153063056619.1818.12550500883688681076.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
	<153063056619.1818.12550500883688681076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, 03 Jul 2018 18:09:26 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> Imagine a big node with many cpus, memory cgroups and containers.
> Let we have 200 containers, every container has 10 mounts,
> and 10 cgroups. All container tasks don't touch foreign
> containers mounts. If there is intensive pages write,
> and global reclaim happens, a writing task has to iterate
> over all memcgs to shrink slab, before it's able to go
> to shrink_page_list().
> 
> Iteration over all the memcg slabs is very expensive:
> the task has to visit 200 * 10 = 2000 shrinkers
> for every memcg, and since there are 2000 memcgs,
> the total calls are 2000 * 2000 = 4000000.
> 
> So, the shrinker makes 4 million do_shrink_slab() calls
> just to try to isolate SWAP_CLUSTER_MAX pages in one
> of the actively writing memcg via shrink_page_list().
> I've observed a node spending almost 100% in kernel,
> making useless iteration over already shrinked slab.
> 
> This patch adds bitmap of memcg-aware shrinkers to memcg.
> The size of the bitmap depends on bitmap_nr_ids, and during
> memcg life it's maintained to be enough to fit bitmap_nr_ids
> shrinkers. Every bit in the map is related to corresponding
> shrinker id.
> 
> Next patches will maintain set bit only for really charged
> memcg. This will allow shrink_slab() to increase its
> performance in significant way. See the last patch for
> the numbers.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -182,6 +182,11 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>  	if (id < 0)
>  		goto unlock;
>  
> +	if (memcg_expand_shrinker_maps(id)) {
> +		idr_remove(&shrinker_idr, id);
> +		goto unlock;
> +	}
> +
>  	if (id >= shrinker_nr_max)
>  		shrinker_nr_max = id + 1;
>  	shrinker->id = id;

This function ends up being a rather sad little thing.

: static int prealloc_memcg_shrinker(struct shrinker *shrinker)
: {
: 	int id, ret = -ENOMEM;
: 
: 	down_write(&shrinker_rwsem);
: 	id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
: 	if (id < 0)
: 		goto unlock;
: 
: 	if (memcg_expand_shrinker_maps(id)) {
: 		idr_remove(&shrinker_idr, id);
: 		goto unlock;
: 	}
: 
: 	if (id >= shrinker_nr_max)
: 		shrinker_nr_max = id + 1;
: 	shrinker->id = id;
: 	ret = 0;
: unlock:
: 	up_write(&shrinker_rwsem);
: 	return ret;
: }

- there's no need to call memcg_expand_shrinker_maps() unless id >=
  shrinker_nr_max so why not move the code and avoid calling
  memcg_expand_shrinker_maps() in most cases.

- why aren't we decreasing shrinker_nr_max in
  unregister_memcg_shrinker()?  That's easy to do, avoids pointless
  work in shrink_slab_memcg() and avoids memory waste in future
  prealloc_memcg_shrinker() calls.

  It should be possible to find the highest ID in an IDR tree with a
  straightforward descent of the underlying radix tree, but I doubt if
  that has been wired up.  Otherwise a simple loop in
  unregister_memcg_shrinker() would be needed.
