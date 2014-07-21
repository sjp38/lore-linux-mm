Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 293F26B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:08 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id b8so4650096lan.19
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx6si27447083wjb.172.2014.07.21.04.47.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 04:47:04 -0700 (PDT)
Date: Mon, 21 Jul 2014 13:46:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140721114655.GB8393@dhcp22.suse.cz>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
 <20140718154443.GM27940@esperanza>
 <20140721090724.GA8393@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140721090724.GA8393@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon 21-07-14 11:07:24, Michal Hocko wrote:
> On Fri 18-07-14 19:44:43, Vladimir Davydov wrote:
> > On Wed, Jul 16, 2014 at 11:58:14AM -0400, Johannes Weiner wrote:
> > > On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
> > > > +#ifdef CONFIG_MEMCG_KMEM
> > > > +	{
> > > > +		.name = "kmem.limit_in_bytes",
> > > > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > > > +		.write = mem_cgroup_write,
> > > > +		.read_u64 = mem_cgroup_read_u64,
> > > > +	},
> > > 
> > > Does it really make sense to have a separate limit for kmem only?
> > > IIRC, the reason we introduced this was that this memory is not
> > > reclaimable and so we need to limit it.
> > > 
> > > But the opposite effect happened: because it's not reclaimable, the
> > > separate kmem limit is actually unusable for any values smaller than
> > > the overall memory limit: because there is no reclaim mechanism for
> > > that limit, once you hit it, it's over, there is nothing you can do
> > > anymore.  The problem isn't so much unreclaimable memory, the problem
> > > is unreclaimable limits.
> > > 
> > > If the global case produces memory pressure through kernel memory
> > > allocations, we reclaim page cache, anonymous pages, inodes, dentries
> > > etc.  I think the same should happen for kmem: kmem should just be
> > > accounted and limited in the overall memory limit of a group, and when
> > > pressure arises, we go after anything that's reclaimable.
> > 
> > Personally, I don't think there's much sense in having a separate knob
> > for kmem limit either. Until we have a user with a sane use case for it,
> > let's not propagate it to the new interface.
> 
> What about fork-bomb forks protection? I thought that was the primary usecase
> for K < U? Or how can we handle that use case with a single limit? A
> special gfp flag to not trigger OOM path when called from some kmem
> charge paths?

Even then, I do not see how would this fork-bomb prevention work without
causing OOMs and killing other processes within the group. The danger
would be still contained in the group and prevent from the system wide
disruption. Do we really want only such a narrow usecase?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
