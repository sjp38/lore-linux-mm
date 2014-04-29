Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 31B3C6B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:27:49 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so442673lbi.21
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 11:27:48 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id j7si7988389lae.10.2014.04.29.11.27.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 11:27:47 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so444215lbi.7
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 11:27:46 -0700 (PDT)
Date: Tue, 29 Apr 2014 20:27:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429182742.GB25609@dhcp22.suse.cz>
References: <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
 <20140429170639.GA25609@dhcp22.suse.cz>
 <20140429133039.162d9dd7@oracle.com>
 <20140429180927.GB29606@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140429180927.GB29606@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Tim Hockin <thockin@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Serge Hallyn <serge.hallyn@ubuntu.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Daniel Walsh <dwalsh@redhat.com>

On Tue 29-04-14 19:09:27, Richard Davies wrote:
> Dwight Engen wrote:
> > Michal Hocko wrote:
> > > Tim Hockin wrote:
> > > > Here's the reason it doesn't work for us: It doesn't work.
> > >
> > > There is a "simple" solution for that. Help us to fix it.
> > >
> > > > It was something like 2 YEARS since we first wanted this, and it
> > > > STILL does not work.
> > >
> > > My recollection is that it was primarily Parallels and Google asking
> > > for the kmem accounting. The reason why I didn't fight against
> > > inclusion although the implementation at the time didn't have a
> > > proper slab shrinking implemented was that that would happen later.
> > > Well, that later hasn't happened yet and we are slowly getting there.
> > >
> > > > You're postponing a pretty simple request indefinitely in
> > > > favor of a much more complex feature, which still doesn't really
> > > > give me what I want.
> > >
> > > But we cannot simply add a new interface that will have to be
> > > maintained for ever just because something else that is supposed to
> > > workaround bugs.
> > >
> > > > What I want is an API that works like rlimit but per-cgroup, rather
> > > > than per-UID.
> > >
> > > You can use an out-of-tree patchset for the time being or help to get
> > > kmem into shape. If there are principal reasons why kmem cannot be
> > > used then you better articulate them.
> >
> > Is there a plan to separately account/limit stack pages vs kmem in
> > general? Richard would have to verify, but I suspect kmem is not currently
> > viable as a process limiter for him because icache/dcache/stack is all
> > accounted together.
> 
> Certainly I would like to be able to limit container fork-bombs without
> limiting the amount of disk IO caching for processes in those containers.
> 
> In my testing with of kmem limits, I needed a limit of 256MB or lower to
> catch fork bombs early enough. I would definitely like more than 256MB of
> disk caching.
> 
> So if we go the "working kmem" route, I would like to be able to specify a
> limit excluding disk cache.

Page cache (which is what you mean by disk cache probably) is a
userspace accounted memory with the memory cgroup controller. And you
do not have to limit that one. Kmem accounting refers to kernel internal
allocations - slab memory and per process kernel stack. You can see how
much memory is allocated per container by memory.kmem.usage_in_bytes or
have a look at /proc/slabinfo to see what kind of memory kernel
allocates globally and might be accounted for a container as well.

The primary problem with the kmem accounting right now is that such a
memory is not "reclaimed" and so if the kmem limit is reached all the
further kmem allocations fail. The biggest user of the kmem allocations
on many systems is dentry and inode chache which is reclaimable easily.
When this is implemented the kmem limit will be usable to both prevent
forkbombs but also other DOS scenarios when the kernel is pushed to
allocate a huge amount of memory.

HTH

> I am also somewhat worried that normal software use could legitimately go
> above 256MB of kmem (even excluding disk cache) - I got to 50MB in testing
> just by booting a distro with a few daemons in a container.
> 
> Richard.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
