Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id F1CB06B0256
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 11:38:22 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so27629345pac.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 08:38:22 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id to8si4872185pab.230.2015.09.04.08.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 08:38:21 -0700 (PDT)
Date: Fri, 4 Sep 2015 18:38:10 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150904153810.GD13699@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150904133038.GC8220@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Sep 04, 2015 at 03:30:38PM +0200, Michal Hocko wrote:
> On Tue 01-09-15 14:51:57, Tejun Heo wrote:
> > Hello,
> > 
> > On Tue, Sep 01, 2015 at 02:44:59PM +0200, Michal Hocko wrote:
> > > The runtime overhead is not negligible and I do not see why everybody
> > > should be paying that price by default. I can definitely see the reason why
> > > somebody would want to enable the kmem accounting but many users will
> > > probably never care because the kernel footprint would be in the noise
> > > wrt. user memory.
> > 
> > We said the same thing about hierarchy support.  Sure, it's not the
> > same but I think it's wiser to keep the architectural decisions at a
> > higher level.  I don't think kmem overhead is that high but if this
> > actually is a problem we'd need a per-cgroup knob anyway.
> 
> The overhead was around 4% for the basic kbuild test without ever
> triggering the [k]memcg limit last time I checked. This was quite some
> time ago and things might have changed since then. Even when this got
> better there will still be _some_ overhead because we have to track that
> memory and that is not free.

Just like there is some overhead if a process is placed in memcg w/o
kmem accounting enabled.

> 
> The question really is whether kmem accounting is so generally useful
> that the overhead is acceptable and it is should be enabled by
> default. From my POV it is a useful mitigation of untrusted users but
> many loads simply do not care because they only care about a certain
> level of isolation.

FWIW, I've seen a useful workload that generated tons of negative
dentries for some reason (if my memory doesn't fail, it was nginx web
server). If one starts such a workload inside a container w/o kmem
accounting, it might evict useful data from other containers. So, even
if a container is trusted, it might be still worth having kmem
accounting enabled.

> 
> I might be wrong here of course but if the default should be switched it
> would deserve a better justification with some numbers so that people
> can see the possible drawbacks.

Personally, I'd prefer to have it switched on by default, because it
would force people test it and report bugs and performance degradation.
If one finds it really crappy, he/she should be able to disable it.

> 
> I agree that the per-cgroup knob is better than the global one. We

Not that sure :-/

> should also find consensus whether the legacy semantic of k < u limit
> should be preserved. It made sense to me at the time it was introduced
> but I recall that Vladimir found it not really helpful when we discussed
> that at LSF. I found it interesting e.g. for the rough task count
> limiting use case which people were asking for.

There is the pids cgroup, which suits this purpose much better.

K < U adds a lot of complexity to reclaim, while it's not clear whether
we really need it. For instance, when you hit K you should reclaim kmem
only, but there is kmem that is pinned by umem, e.g. radix tree nodes or
buffer heads. What should we do with them? Reclaim umem on hitting kmem
limit? IMO ugly.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
