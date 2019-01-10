Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5EA8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 19:44:31 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so6489245pfj.4
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 16:44:31 -0800 (PST)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id w12si71125745pfn.212.2019.01.09.16.44.28
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 16:44:29 -0800 (PST)
Date: Thu, 10 Jan 2019 11:44:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110004424.GH27534@dastard>
References: <20190106001138.GW6310@bombadil.infradead.org>
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 09, 2019 at 10:25:43AM -0800, Linus Torvalds wrote:
> On Tue, Jan 8, 2019 at 8:39 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > FWIW, I just realised that the easiest, most reliable way to
> > invalidate the page cache over a file range is simply to do a
> > O_DIRECT read on it.
> 
> If that's the case, that's actually an O_DIRECT bug.
>
> It should only invalidate the caches on write.

Sounds nice from a theoretical POV, but reality has taught us
very different lessons.

FWIW, a quick check of XFS's history so you understand how long this
behaviour has been around. It was introduced in the linux port in
2001 as direct IO support was being added:

commit e837eac23662afae603aaaef7c94bc839c1b8f67
Author: Steve Lord <lord@sgi.com>
Date:   Mon Mar 5 16:47:52 2001 +0000

    Add bounds checking for direct I/O, do the cache invalidation for
    data coherency on direct I/O.

This was basically a direct port of the flush+invalidation code in
the Irix direct IO path, which was introduced in 1995:

    > revision 1.149
    > date: 1995/08/11 20:09:44;  author: ajs;  state: Exp;  lines: +70 -2
    > 280514 Adding page cache flusing calls to make direct
    > I/O coherent with buffered I/O.

IOWs, history tells us that invalidation for direct IO reads has
been done on XFS for almost 25 years.  I know for certain that there
have been applications out there that depend on this
invalidation-on-read behaviour (another of those "reality bites"
lessons) so we can't just remove it because you *think* it is a bug.

i.e. we *could* remove the invalidation on read, but this we have a
major behavioural change to the XFS direct IO path. This means we
need to determine if we've just awoken sleeping data corruption
krakens as well as determine if there are any performance
regressions that result from the behavioural change.

Which brings me to validation.  If the recent
clone/dedupe/copy_file_range() debacle has taught me anything, it's
that validating a "simple" IO path mechanism is going to take months
worth of machine time before we have any confidence that the change
is not going to expose users to new data corruption problems.

That's the difficulty here - it only takes 5 minutes to change
the code, but there's months of machine time needed to determine if
it's really safe to make that code change. Testing has a nasty habit
of finding invalid assumptions; when those are assumptions about
data coherency and integrity we can't test them on our users.

And, really, this would be just another band-aid over a symptom of
the information leak - it doesn't prevent users from being able to
control page cache invalidation. It just removes one method, just
like hacking mincore only removes one method of observing the page
cache.  And, like mincore(), there's every chance it impacts on
userspace in a negative manner and so we need to be very careful
here.

> On reads, it wants to either _flush_ any direct caches before the
> read, or just take the data from the caches. At no point is
> "invalidate" a valid model.
> 
> Of course, I'm not in the least bit shocked if O_DIRECT is buggy like
> this. But looking at least at the ext4 routine, the read just does
> 
>         ret = filemap_write_and_wait_range(mapping, iocb->ki_pos,
> 
> and I don't see any invalidation.

I wouldn't look at ext4 as an example of a reliable, problem free
direct IO implementation because, historically speaking, it's been a
series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
been far worse than XFS from data integrity, performance and
reliability perspectives.

IMO, "because ext4" has been a poor reason for justifying anything
for a long time, not the least when talking about features that
didn't even originate in extN....

> Can you actually point to such a thing? Let's get that fixed, because
> it's completely wrong regardless of this whole mincore issue.

The biggest problem that remains today is that we have no mechanism
for serialising page faults against DIO. If we leave pages cached in
memory while we have a AIO+DIO read (or write!) in progress, we can
dirty the page and run a buffered read before the AIO+DIO read
returns. This now leaves us in the state where where the AIO+DIO
read returns different (stale) data to a buffered read that has
already completed because it hit the dirty page cache.  i.e. we
still have nasty page cache vs direct IO coherency problems, and
they are largely unsolvable because of the limitations of the core
kernel infrastructure architecture.

Yes, you can argue that userspace is doing an insane thing, but
every so often we come across coherency issues like this that are
out of a user's control (e.g. backup scan vs app accesses) and we do
our best to ensure that they don't cause problems given the
constraints we have.  Invalidating the page cache on dio reads
mostly mitigates these coherency race conditions and that's why it's
still there in the XFS code paths...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
