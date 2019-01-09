Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 602078E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:24:35 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m13so3295280pls.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:24:35 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 80si34142088pfz.11.2019.01.08.18.24.32
        for <linux-mm@kvack.org>;
        Tue, 08 Jan 2019 18:24:34 -0800 (PST)
Date: Wed, 9 Jan 2019 13:24:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190109022430.GE27534@dastard>
References: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org>
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Jan 08, 2019 at 09:57:49AM -0800, Linus Torvalds wrote:
> On Mon, Jan 7, 2019 at 8:43 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > So, I read the paper and before I was half way through it I figured
> > there are a bunch of other similar page cache invalidation attacks
> > we can perform without needing mincore. i.e. Focussing on mmap() and
> > mincore() misses the wider issues we have with global shared caches.
> 
> Oh, agreed, and that was discussed in the original report too.
> 
> The thing is, you can also depend on our pre-faulting of pages in the
> page fault handler, and use that to get the cached status of nearby
> pages. So do something like "fault one page, then do mincore() to see
> how many pages near it were mapped". See our "do_fault_around()"
> logic.

Observing fault-around could help you detect what code an application is
running, but it's not necessary (and can be turned off). Also, such
an it observation is not dependent on using mincore. neither
fault-around nor mincore are required functionality to exploit the
information leaks.

And, FWIW, fault-around actually destroys the information in the
exfiltration channel described in the paper because it perturbs the
carefully constructed page cache residency pattern that encodes the
message.

> But mincore is certainly the easiest interface, and the one that
> doesn't require much effort or setup.

Off the top of my head, here's a few vectors for reading the page
cache residency state without perturbing the page cache residency
pattern:
	- mincore
	- preadv2(RWF_NOWAIT)
	- fadvise(POSIX_FADV_RANDOM); timed read(2) syscalls
	- madvise(MADV_RANDOM); timed read of first byte in each page

i.e. mincore is a messenger, but it's not the only trivial
observation technique available. The only difference between mincore
and the others will be the observation latency and hence channel
bandwidth.

IOWs, the question we need to focus on now is not "does breaking
mincore affect anyone", it is "how the hell do we mitigate and
isolate an information leak exposed by fundamental OS functionality
that *everything* depends on for performance"?

> It's also the one where our old
> behavior was actually arguably simply stupid and actively wrong (ie
> "in caches" isn't even strictly speaking a valid question, since the
> caches in question may be invalid).

This is irrelevant to the problem reported. Sure, mincore may be
an awful interface, but it's semantics are not the cause of the
information leak. You're just shooting the messenger...

> I do think that the RWF_NOWAIT case might also be interesting to look at.

As are all the other mechanisms you can use to observer page cache
residency without perturbing it's state.

Keep in mind that the researchers documented a remote observation
technique that leaked the information across the network to a remote
host, so this leak has much, much wider scope than changing mincore
can address...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
