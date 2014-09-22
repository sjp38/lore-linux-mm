Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B54166B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 03:05:03 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id et14so3954122pad.6
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 00:05:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y7si14209737pdm.70.2014.09.22.00.05.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 00:05:02 -0700 (PDT)
Date: Mon, 22 Sep 2014 11:04:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 00/14] Per memcg slab shrinkers
Message-ID: <20140922070446.GD32416@esperanza>
References: <cover.1411301245.git.vdavydov@parallels.com>
 <20140921160012.GA996@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140921160012.GA996@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi Tejun,

On Sun, Sep 21, 2014 at 12:00:12PM -0400, Tejun Heo wrote:
> On Sun, Sep 21, 2014 at 07:14:32PM +0400, Vladimir Davydov wrote:
> ...
> > list. This is really important, because this allows us to release
> > memcg_cache_id used for indexing in per-memcg arrays. If we don't do
> > this, the arrays will grow uncontrollably, which is really bad. Note, in
> > comparison to user memory reparenting, which Johannes is going to get
> 
> I don't know the code well and haven't read the patches and could
> easilya be completely off the mark, but, if the size of slab array is
> the only issue, wouldn't it be easier to separate that part out?  The
> indexing is only necessary for allocating new items, right?  Can't
> that part be shutdown and the index freed on offline and the rest stay
> till release?  

That's exactly what I did in this set. I release the cache index on css
offline, but I don't reparent kmem charges, or merge kmem slabs, or
whatever, because we only need to index caches on allocations. So kmem
caches corresponding to a dead memory cgroup will be hanging around
until the last object is freed. And they will be holding a css reference
just like swap charges do and user memory charges will after Johannes'
rework.

However, we still need the cache index for list_lru, which is made
per-memcg in this patch set. The point is the objects accounted to a
memory cgroup can be added/removed from lru lists even after the cgroup
death. If we just set the cache index of a dead cgroup to its parent's,
the objects will be added/removed from an active list_lru, but there
still might be some objects left on the list_lru of the dead cgroup. We
have to move them in order to release the cache index.

> Things like reparenting tends to add fair amount of complexity and hot
> path overheads which aren't necessary otherwise.

There is no overhead added to hot paths *due to reparenting* in this set
AFAIU. And the code is way simpler than that of the user charges
reparenting, because the usage scenario of list_lru is much simpler than
that of lruvec. E.g. we don't have to retry, we are guaranteed to
succeed after the first scan. Just look at the two function doing the
stuff - memcg_reparent_all_list_lrus and reparent_memcg_lru in patch 13
- ain't they complex?

I'd like to emphasize this once again - the reparenting I'm talking
about is not about charges, we're not waiting until kmem res drops to 0.
I just move list_lru items from one list to another on css offline, w/o
retries, waiting, or some weird checks here and there.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
