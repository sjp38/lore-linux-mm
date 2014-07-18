Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id B1F8B6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 12:13:44 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so3616198wev.13
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 09:13:44 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id eu4si12211260wjd.51.2014.07.18.09.13.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 09:13:42 -0700 (PDT)
Date: Fri, 18 Jul 2014 12:13:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140718161331.GJ29639@cmpxchg.org>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
 <20140718154443.GM27940@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140718154443.GM27940@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Jul 18, 2014 at 07:44:43PM +0400, Vladimir Davydov wrote:
> On Wed, Jul 16, 2014 at 11:58:14AM -0400, Johannes Weiner wrote:
> > On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
> > > +#ifdef CONFIG_MEMCG_KMEM
> > > +	{
> > > +		.name = "kmem.limit_in_bytes",
> > > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > > +		.write = mem_cgroup_write,
> > > +		.read_u64 = mem_cgroup_read_u64,
> > > +	},
> > 
> > Does it really make sense to have a separate limit for kmem only?
> > IIRC, the reason we introduced this was that this memory is not
> > reclaimable and so we need to limit it.
> > 
> > But the opposite effect happened: because it's not reclaimable, the
> > separate kmem limit is actually unusable for any values smaller than
> > the overall memory limit: because there is no reclaim mechanism for
> > that limit, once you hit it, it's over, there is nothing you can do
> > anymore.  The problem isn't so much unreclaimable memory, the problem
> > is unreclaimable limits.
> > 
> > If the global case produces memory pressure through kernel memory
> > allocations, we reclaim page cache, anonymous pages, inodes, dentries
> > etc.  I think the same should happen for kmem: kmem should just be
> > accounted and limited in the overall memory limit of a group, and when
> > pressure arises, we go after anything that's reclaimable.
> 
> Personally, I don't think there's much sense in having a separate knob
> for kmem limit either. Until we have a user with a sane use case for it,
> let's not propagate it to the new interface.
> 
> Furthermore, even when we introduce kmem shrinking, the kmem-only limit
> alone won't be very useful, because there are plenty of GFP_NOFS kmem
> allocations, which make most of slab shrinkers useless. To avoid
> ENOMEM's in such situation, we would have to introduce either a soft
> kmem limit (watermark) or a kind of kmem precharges. This means if we
> decided to introduce kmem-only limit, we'd eventually have to add more
> knobs and write more code to make it usable w/o even knowing if anyone
> would really benefit from it.
> 
> However, there might be users that only want user memory limiting and
> don't want to pay the price of kmem accounting, which is pretty
> expensive. Even if we implement percpu stocks for kmem, there still will
> be noticeable overhead due to touching more cache lines on
> kmalloc/kfree.

Yes, we should not force everybody do take that cost in general, but
once you're using it, how much overhead is it really?  Charging
already happens in the slow path and we can batch it as you said.

I wonder if it would be enough to have the same granularity as the
swap controller; a config option and a global runtime toggle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
