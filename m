Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 128BD8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 23:39:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so4331076pfb.17
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 20:39:12 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id o27si11682011pgl.53.2019.01.08.20.39.09
        for <linux-mm@kvack.org>;
        Tue, 08 Jan 2019 20:39:10 -0800 (PST)
Date: Wed, 9 Jan 2019 15:39:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190109043906.GF27534@dastard>
References: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org>
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 09, 2019 at 03:31:35AM +0100, Jiri Kosina wrote:
> On Wed, 9 Jan 2019, Dave Chinner wrote:
> 
> > > But mincore is certainly the easiest interface, and the one that
> > > doesn't require much effort or setup.
> > 
> > Off the top of my head, here's a few vectors for reading the page
> > cache residency state without perturbing the page cache residency
> > pattern:
> > 	- mincore
> > 	- preadv2(RWF_NOWAIT)
> > 	- fadvise(POSIX_FADV_RANDOM); timed read(2) syscalls
> > 	- madvise(MADV_RANDOM); timed read of first byte in each page
> 
> While I obviously agree that all those are creating pagecache sidechannel 
> in principle, I think we really should mostly focus on the first two (with 
> mincore() already having been covered).

FWIW, I just realised that the easiest, most reliable way to
invalidate the page cache over a file range is simply to do a
O_DIRECT read on it. IOWs, all three requirements of this
information leak - highly specific, reliable cache invalidation
control, controlled cache instantiation and 3rd-party detection of
cache residency can all be performed with just the read(2)
syscall...

> Rationale has been provided by Daniel Gruss in this thread -- if the 
> attacker is left with cache timing as the only available vector, he's 
> going to be much more successful with mounting hardware cache timing 
> attack anyway.

No, he said:

"Restricting mincore() is sufficient to fix the hardware-agnostic
part."

That's not correct - preadv2(RWF_NOWAIT) is also hardware agnostic
and provides exactly the same information about the page cache as
mincore.  Timed read/mmap access loops for cache observation are
also hardware agnostic, and on fast SSD based storage will only be
marginally slower bandwidth than preadv2(RWF_NOWAIT).

Attackers will pick whatever leak vector we don't fix, so we either
fix them all (which I think is probably impossible without removing
caching altogether) or we start thinking about how we need to
isolate the page cache so that information isn't shared across
important security boundaries (e.g. page cache contents are
per-mount namespace).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
