Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 864706B0258
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 05:39:09 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so82107080wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 02:39:09 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id bd6si19868778wib.116.2015.09.07.02.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 02:39:08 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so81983940wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 02:39:07 -0700 (PDT)
Date: Mon, 7 Sep 2015 11:39:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150907093905.GD6022@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
 <20150904153810.GD13699@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904153810.GD13699@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri 04-09-15 18:38:10, Vladimir Davydov wrote:
> On Fri, Sep 04, 2015 at 03:30:38PM +0200, Michal Hocko wrote:
> > On Tue 01-09-15 14:51:57, Tejun Heo wrote:
> > > Hello,
> > > 
> > > On Tue, Sep 01, 2015 at 02:44:59PM +0200, Michal Hocko wrote:
> > > > The runtime overhead is not negligible and I do not see why everybody
> > > > should be paying that price by default. I can definitely see the reason why
> > > > somebody would want to enable the kmem accounting but many users will
> > > > probably never care because the kernel footprint would be in the noise
> > > > wrt. user memory.
> > > 
> > > We said the same thing about hierarchy support.  Sure, it's not the
> > > same but I think it's wiser to keep the architectural decisions at a
> > > higher level.  I don't think kmem overhead is that high but if this
> > > actually is a problem we'd need a per-cgroup knob anyway.
> > 
> > The overhead was around 4% for the basic kbuild test without ever
> > triggering the [k]memcg limit last time I checked. This was quite some
> > time ago and things might have changed since then. Even when this got
> > better there will still be _some_ overhead because we have to track that
> > memory and that is not free.
> 
> Just like there is some overhead if a process is placed in memcg w/o
> kmem accounting enabled.

Sure I am not questioning that.

> > The question really is whether kmem accounting is so generally useful
> > that the overhead is acceptable and it is should be enabled by
> > default. From my POV it is a useful mitigation of untrusted users but
> > many loads simply do not care because they only care about a certain
> > level of isolation.
> 
> FWIW, I've seen a useful workload that generated tons of negative
> dentries for some reason (if my memory doesn't fail, it was nginx web
> server). If one starts such a workload inside a container w/o kmem
> accounting, it might evict useful data from other containers. So, even
> if a container is trusted, it might be still worth having kmem
> accounting enabled.

OK, then this is a clear usecase for using kmem mem. I was merely
pointing out that many others will not care about kmem. Is it majority?
I dunno. But I haven't heard any convincing argument that those that
need kmem would form a majority either.

> > I might be wrong here of course but if the default should be switched it
> > would deserve a better justification with some numbers so that people
> > can see the possible drawbacks.
> 
> Personally, I'd prefer to have it switched on by default, because it
> would force people test it and report bugs and performance degradation.
> If one finds it really crappy, he/she should be able to disable it.

I do not think this is the way of introducing new functionality. You do
not want to force users to debug your code and go let it disable if it
is too crappy.

> > I agree that the per-cgroup knob is better than the global one. We
> 
> Not that sure :-/

Why?

> > should also find consensus whether the legacy semantic of k < u limit
> > should be preserved. It made sense to me at the time it was introduced
> > but I recall that Vladimir found it not really helpful when we discussed
> > that at LSF. I found it interesting e.g. for the rough task count
> > limiting use case which people were asking for.
> 
> There is the pids cgroup, which suits this purpose much better.

I am not familiar with this controller. I am not following cgroup
mailing list too closely but I vaguely remember somebody proposing this
controller but I am not sure what is the current status. The last time
this has been discussed there was a general pushback to use kmem
accounting for process count restriction.

> K < U adds a lot of complexity to reclaim, while it's not clear whether
> we really need it. For instance, when you hit K you should reclaim kmem
> only, but there is kmem that is pinned by umem, e.g. radix tree nodes or
> buffer heads. What should we do with them? Reclaim umem on hitting kmem
> limit? IMO ugly.

kmem as a hard limit could simply reclaim slab objects and fail if it
doesn't succeed. Sure many objects might be pinned by other resources
which are not reclaimable but that is possible with the global case as
well.
I can see your argument that the configuration might be quite tricky,
though. If there is a general consensus that kernel memory bound to
resources which need to be controllable will get its own way of
controlling then a separate K limit would indeed be not needed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
