Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0EF8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 20:15:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y88so6534676pfi.9
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:15:38 -0800 (PST)
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id u6si54042116pfb.92.2019.01.09.17.15.35
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 17:15:36 -0800 (PST)
Date: Thu, 10 Jan 2019 12:15:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110011533.GI27534@dastard>
References: <20190106001138.GW6310@bombadil.infradead.org>
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <nycvar.YFH.7.76.1901091050560.16954@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901091050560.16954@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 09, 2019 at 11:08:57AM +0100, Jiri Kosina wrote:
> On Wed, 9 Jan 2019, Dave Chinner wrote:
> 
> > FWIW, I just realised that the easiest, most reliable way to invalidate 
> > the page cache over a file range is simply to do a O_DIRECT read on it. 
> 
> Neat, good catch indeed. Still, it's only the invalidation part, but the 
> residency check is the crucial one.
> 
> > > Rationale has been provided by Daniel Gruss in this thread -- if the 
> > > attacker is left with cache timing as the only available vector, he's 
> > > going to be much more successful with mounting hardware cache timing 
> > > attack anyway.
> > 
> > No, he said:
> > 
> > "Restricting mincore() is sufficient to fix the hardware-agnostic
> > part."
> > 
> > That's not correct - preadv2(RWF_NOWAIT) is also hardware agnostic and 
> > provides exactly the same information about the page cache as mincore.  
> 
> Yeah, preadv2(RWF_NOWAIT) is in the same teritory as mincore(), it has 
> "just" been overlooked. I can't speak for Daniel, but I believe he might 
> be ok with rephrasing the above as "Restricting mincore() and RWF_NOWAIT 
> is sufficient ...".

Good luck with restricting RWF_NOWAIT. I eagerly await all the
fstests that exercise both the existing and new behaviours to
demonstrate they work correctly.

> > Timed read/mmap access loops for cache observation are also hardware 
> > agnostic, and on fast SSD based storage will only be marginally slower 
> > bandwidth than preadv2(RWF_NOWAIT).
> > 
> > Attackers will pick whatever leak vector we don't fix, so we either fix 
> > them all (which I think is probably impossible without removing caching 
> > altogether) 
> 
> We can't really fix the fact that it's possible to do the timing on the HW 
> caches though.

We can't really fix the fact that it's possible to do the timing on
the page cache, either.

> > or we start thinking about how we need to isolate the page cache so that 
> > information isn't shared across important security boundaries (e.g. page 
> > cache contents are per-mount namespace).
> 
> Umm, sorry for being dense, but how would that help that particular attack 
> scenario on a system that doesn't really employ any namespacing?

What's your security boundary?

The "detect what code an app is running" exploit is based on
invalidating and then observing how shared, non-user-owned files
mapped with execute privileges change cache residency.

If the security boundary is within the local container, should users
inside that container be allowed to invalidate the cache of
executable files and libraries they don't own? In this case, we
can't stop observation, because that only require read permissions
and high precision timing, hence the only thing that can be done
here is prevent non-owners from invalidating the page cache.

If the security boundary is a namespace or guest VM, then permission
checks don't work - the user may own the file within that container.
This problem now is that the page cache is observable and
controllable from both sides of the fence. Hence the only way to
prevent observation of the code being run in a different namespace
is to prevent the page being shared across both containers.

The exfiltration exploit requires the page cache to be observable
and controllable on both sides of the security boundary. Should
users be able to observe and control the cached pages accessed by a
different container? KSM page deduplication lessons say no. This is
an even harder problem, because page cache residency can be observed
from remote machines....

What scares me is that new features being proposed could make our
exposure a whole lot worse. e.g. the recent virtio-pmem ("fake-dax")
proposal will directly share host page cache pages into guest VMs w/
DAX capability. i.e. the guest directly accesses the host page
cache.  This opens up the potential for host page cache timing
attacks from the guest VMs, and potential guest to guest
observation/exploitation is possible if the same files are mapped
into multiple guests....

IOws the two questions here are simply: "What's your security
boundary?" and "Is the page cache visible and controllable on both
sides?".

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
