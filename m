Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 570D46B003D
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 08:04:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so9551513pab.19
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 05:04:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tf1si14047921pbc.15.2014.07.21.05.04.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 05:04:07 -0700 (PDT)
Date: Mon, 21 Jul 2014 16:03:32 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140721120332.GB11848@esperanza>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
 <20140718154443.GM27940@esperanza>
 <20140721090724.GA8393@dhcp22.suse.cz>
 <20140721114655.GB8393@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140721114655.GB8393@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Jul 21, 2014 at 01:46:55PM +0200, Michal Hocko wrote:
> On Mon 21-07-14 11:07:24, Michal Hocko wrote:
> > On Fri 18-07-14 19:44:43, Vladimir Davydov wrote:
> > > On Wed, Jul 16, 2014 at 11:58:14AM -0400, Johannes Weiner wrote:
> > > > On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
> > > > > +#ifdef CONFIG_MEMCG_KMEM
> > > > > +	{
> > > > > +		.name = "kmem.limit_in_bytes",
> > > > > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > > > > +		.write = mem_cgroup_write,
> > > > > +		.read_u64 = mem_cgroup_read_u64,
> > > > > +	},
> > > > 
> > > > Does it really make sense to have a separate limit for kmem only?
> > > > IIRC, the reason we introduced this was that this memory is not
> > > > reclaimable and so we need to limit it.
> > > > 
> > > > But the opposite effect happened: because it's not reclaimable, the
> > > > separate kmem limit is actually unusable for any values smaller than
> > > > the overall memory limit: because there is no reclaim mechanism for
> > > > that limit, once you hit it, it's over, there is nothing you can do
> > > > anymore.  The problem isn't so much unreclaimable memory, the problem
> > > > is unreclaimable limits.
> > > > 
> > > > If the global case produces memory pressure through kernel memory
> > > > allocations, we reclaim page cache, anonymous pages, inodes, dentries
> > > > etc.  I think the same should happen for kmem: kmem should just be
> > > > accounted and limited in the overall memory limit of a group, and when
> > > > pressure arises, we go after anything that's reclaimable.
> > > 
> > > Personally, I don't think there's much sense in having a separate knob
> > > for kmem limit either. Until we have a user with a sane use case for it,
> > > let's not propagate it to the new interface.
> > 
> > What about fork-bomb forks protection? I thought that was the primary usecase
> > for K < U? Or how can we handle that use case with a single limit? A
> > special gfp flag to not trigger OOM path when called from some kmem
> > charge paths?
> 
> Even then, I do not see how would this fork-bomb prevention work without
> causing OOMs and killing other processes within the group. The danger
> would be still contained in the group and prevent from the system wide
> disruption. Do we really want only such a narrow usecase?

I think it's all about how we're going to use memory cgroups. If we're
going to use them for application containers, there's simply no such
problem, because we only want to isolate a potentially dangerous process
group from the rest of the system. If we want to start a fully
virtualized OS inside a container, then we certainly need a kind of
numproc and/or kmem limiter to prevent processes inside a cgroup from
being OOM killed by a fork-bomb. IMHO, the latter will always be better
done by VMs, so it isn't a must-have for cgroups. I may be mistaken
though.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
