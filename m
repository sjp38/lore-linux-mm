Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEF46B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:03:12 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id 10so475906lbg.37
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:03:11 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id sn7si11157253lbb.109.2014.04.29.12.03.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 12:03:10 -0700 (PDT)
Received: by mail-la0-f48.google.com with SMTP id gf5so481471lab.35
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:03:10 -0700 (PDT)
Date: Tue, 29 Apr 2014 21:03:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429190306.GC25609@dhcp22.suse.cz>
References: <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
 <20140429170639.GA25609@dhcp22.suse.cz>
 <20140429133039.162d9dd7@oracle.com>
 <20140429180927.GB29606@alpha.arachsys.com>
 <20140429182742.GB25609@dhcp22.suse.cz>
 <20140429183928.GF29606@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140429183928.GF29606@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Tim Hockin <thockin@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Serge Hallyn <serge.hallyn@ubuntu.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Daniel Walsh <dwalsh@redhat.com>

On Tue 29-04-14 19:39:28, Richard Davies wrote:
> Michal Hocko wrote:
> > Richard Davies wrote:
> > > Dwight Engen wrote:
> > > > Is there a plan to separately account/limit stack pages vs kmem in
> > > > general? Richard would have to verify, but I suspect kmem is not
> > > > currently viable as a process limiter for him because
> > > > icache/dcache/stack is all accounted together.
> > >
> > > Certainly I would like to be able to limit container fork-bombs without
> > > limiting the amount of disk IO caching for processes in those containers.
> > >
> > > In my testing with of kmem limits, I needed a limit of 256MB or lower to
> > > catch fork bombs early enough. I would definitely like more than 256MB of
> > > disk caching.
> > >
> > > So if we go the "working kmem" route, I would like to be able to specify a
> > > limit excluding disk cache.
> >
> > Page cache (which is what you mean by disk cache probably) is a
> > userspace accounted memory with the memory cgroup controller. And you
> > do not have to limit that one.
> 
> OK, that's helpful - thanks.
> 
> As an aside, with the normal (non-kmem) cgroup controller, is there a way
> for me to exclude page cache and only limit the equivalent of the rss line
> in memory.stat?

No

> e.g. say I have a 256GB physical machine, running 200 containers, each with
> 1GB normal-mem limit (for running software) and 256MB kmem limit (to stop
> fork-bombs).
> 
> The physical disk IO bandwidth is a shared resource between all the
> containers, so ideally I would like the kernel to used the 56GB of RAM as
> shared page cache however it best reduces physical IOPs, rather than having
> a per-container limit.

Then do not use any memory.limit_in_bytes and if there is a memory
pressure then the global reclaim will shrink all the containers
proportionally and the page cache will be the #1 target for the
reclaim (but we are getting off-topic here I am afraid).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
