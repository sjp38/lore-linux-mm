Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCF56B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:45:06 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so3022783lbi.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:45:05 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g1si9899331lab.32.2014.07.18.08.45.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jul 2014 08:45:04 -0700 (PDT)
Date: Fri, 18 Jul 2014 19:44:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140718154443.GM27940@esperanza>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140716155814.GZ29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, Jul 16, 2014 at 11:58:14AM -0400, Johannes Weiner wrote:
> On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
> > +#ifdef CONFIG_MEMCG_KMEM
> > +	{
> > +		.name = "kmem.limit_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > +		.write = mem_cgroup_write,
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> Does it really make sense to have a separate limit for kmem only?
> IIRC, the reason we introduced this was that this memory is not
> reclaimable and so we need to limit it.
> 
> But the opposite effect happened: because it's not reclaimable, the
> separate kmem limit is actually unusable for any values smaller than
> the overall memory limit: because there is no reclaim mechanism for
> that limit, once you hit it, it's over, there is nothing you can do
> anymore.  The problem isn't so much unreclaimable memory, the problem
> is unreclaimable limits.
> 
> If the global case produces memory pressure through kernel memory
> allocations, we reclaim page cache, anonymous pages, inodes, dentries
> etc.  I think the same should happen for kmem: kmem should just be
> accounted and limited in the overall memory limit of a group, and when
> pressure arises, we go after anything that's reclaimable.

Personally, I don't think there's much sense in having a separate knob
for kmem limit either. Until we have a user with a sane use case for it,
let's not propagate it to the new interface.

Furthermore, even when we introduce kmem shrinking, the kmem-only limit
alone won't be very useful, because there are plenty of GFP_NOFS kmem
allocations, which make most of slab shrinkers useless. To avoid
ENOMEM's in such situation, we would have to introduce either a soft
kmem limit (watermark) or a kind of kmem precharges. This means if we
decided to introduce kmem-only limit, we'd eventually have to add more
knobs and write more code to make it usable w/o even knowing if anyone
would really benefit from it.

However, there might be users that only want user memory limiting and
don't want to pay the price of kmem accounting, which is pretty
expensive. Even if we implement percpu stocks for kmem, there still will
be noticeable overhead due to touching more cache lines on
kmalloc/kfree.

So I guess there should be a tunable, which will allow to toggle memcg
features. May be, a bitmask for future extensibility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
