Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 34A336B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:39:44 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id b13so635090wgh.31
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 11:39:43 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id eu7si1842257wic.108.2014.04.29.11.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 11:39:42 -0700 (PDT)
Date: Tue, 29 Apr 2014 19:39:28 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429183928.GF29606@alpha.arachsys.com>
References: <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
 <20140429170639.GA25609@dhcp22.suse.cz>
 <20140429133039.162d9dd7@oracle.com>
 <20140429180927.GB29606@alpha.arachsys.com>
 <20140429182742.GB25609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140429182742.GB25609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dwight Engen <dwight.engen@oracle.com>, Tim Hockin <thockin@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Serge Hallyn <serge.hallyn@ubuntu.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Daniel Walsh <dwalsh@redhat.com>

Michal Hocko wrote:
> Richard Davies wrote:
> > Dwight Engen wrote:
> > > Is there a plan to separately account/limit stack pages vs kmem in
> > > general? Richard would have to verify, but I suspect kmem is not
> > > currently viable as a process limiter for him because
> > > icache/dcache/stack is all accounted together.
> >
> > Certainly I would like to be able to limit container fork-bombs without
> > limiting the amount of disk IO caching for processes in those containers.
> >
> > In my testing with of kmem limits, I needed a limit of 256MB or lower to
> > catch fork bombs early enough. I would definitely like more than 256MB of
> > disk caching.
> >
> > So if we go the "working kmem" route, I would like to be able to specify a
> > limit excluding disk cache.
>
> Page cache (which is what you mean by disk cache probably) is a
> userspace accounted memory with the memory cgroup controller. And you
> do not have to limit that one.

OK, that's helpful - thanks.

As an aside, with the normal (non-kmem) cgroup controller, is there a way
for me to exclude page cache and only limit the equivalent of the rss line
in memory.stat?

e.g. say I have a 256GB physical machine, running 200 containers, each with
1GB normal-mem limit (for running software) and 256MB kmem limit (to stop
fork-bombs).

The physical disk IO bandwidth is a shared resource between all the
containers, so ideally I would like the kernel to used the 56GB of RAM as
shared page cache however it best reduces physical IOPs, rather than having
a per-container limit.

Thanks,

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
