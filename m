Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0510F6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:09:49 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id z12so584733wgg.34
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 11:09:49 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id r9si1799596wia.103.2014.04.29.11.09.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 11:09:48 -0700 (PDT)
Date: Tue, 29 Apr 2014 19:09:27 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429180927.GB29606@alpha.arachsys.com>
References: <20140423084942.560ae837@oracle.com>
 <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
 <20140429170639.GA25609@dhcp22.suse.cz>
 <20140429133039.162d9dd7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140429133039.162d9dd7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dwight Engen <dwight.engen@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Tim Hockin <thockin@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Serge Hallyn <serge.hallyn@ubuntu.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Daniel Walsh <dwalsh@redhat.com>

Dwight Engen wrote:
> Michal Hocko wrote:
> > Tim Hockin wrote:
> > > Here's the reason it doesn't work for us: It doesn't work.
> >
> > There is a "simple" solution for that. Help us to fix it.
> >
> > > It was something like 2 YEARS since we first wanted this, and it
> > > STILL does not work.
> >
> > My recollection is that it was primarily Parallels and Google asking
> > for the kmem accounting. The reason why I didn't fight against
> > inclusion although the implementation at the time didn't have a
> > proper slab shrinking implemented was that that would happen later.
> > Well, that later hasn't happened yet and we are slowly getting there.
> >
> > > You're postponing a pretty simple request indefinitely in
> > > favor of a much more complex feature, which still doesn't really
> > > give me what I want.
> >
> > But we cannot simply add a new interface that will have to be
> > maintained for ever just because something else that is supposed to
> > workaround bugs.
> >
> > > What I want is an API that works like rlimit but per-cgroup, rather
> > > than per-UID.
> >
> > You can use an out-of-tree patchset for the time being or help to get
> > kmem into shape. If there are principal reasons why kmem cannot be
> > used then you better articulate them.
>
> Is there a plan to separately account/limit stack pages vs kmem in
> general? Richard would have to verify, but I suspect kmem is not currently
> viable as a process limiter for him because icache/dcache/stack is all
> accounted together.

Certainly I would like to be able to limit container fork-bombs without
limiting the amount of disk IO caching for processes in those containers.

In my testing with of kmem limits, I needed a limit of 256MB or lower to
catch fork bombs early enough. I would definitely like more than 256MB of
disk caching.

So if we go the "working kmem" route, I would like to be able to specify a
limit excluding disk cache.


I am also somewhat worried that normal software use could legitimately go
above 256MB of kmem (even excluding disk cache) - I got to 50MB in testing
just by booting a distro with a few daemons in a container.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
