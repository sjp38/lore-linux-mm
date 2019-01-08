Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB6088E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 23:43:42 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so1372048pgc.3
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 20:43:42 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id f7si10866365pga.87.2019.01.07.20.43.39
        for <linux-mm@kvack.org>;
        Mon, 07 Jan 2019 20:43:41 -0800 (PST)
Date: Tue, 8 Jan 2019 15:43:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190108044336.GB27534@dastard>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org>
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sun, Jan 06, 2019 at 01:46:37PM -0800, Linus Torvalds wrote:
> On Sat, Jan 5, 2019 at 5:50 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Slightly updated patch in case somebody wants to try things out.
> 
> I decided to just apply that patch. It is *not* marked for stable,
> very intentionally, because I expect that we will need to wait and see
> if there are issues with it, and whether we might have to do something
> entirely different (more like the traditional behavior with some extra
> "only for owner" logic).

So, I read the paper and before I was half way through it I figured
there are a bunch of other similar page cache invalidation attacks
we can perform without needing mincore. i.e. Focussing on mmap() and
mincore() misses the wider issues we have with global shared caches.

My first thought:

	fd = open(some_file, O_RDONLY);
	iov[0].iov_base = buf;
	iov[0].iov_len = 1;
	ret = preadv2(fd, iov, 1, off, RWF_NOWAIT);
	switch (ret) {
	case -EAGAIN:
		/* page not resident in page cache */
		break;
	case 1:
		/* page resident in page cache */
		break;
	default:
		/* beyond EOF or some other error */
		break;
	}

This is "as documented" in the man page for preadv2:

RWF_NOWAIT (since Linux 4.14)
      Do  not  wait  for  data which is not immediately available.
      If this flag is specified, the preadv2() system call will
      return instantly if it would have to read data from the
      backing storage or wait for a lock.  If some data was
      successfully read, it will return the number of bytes read.
      If no bytes were read, it will return  -1 and set errno to
      EAGAIN.  Currently, this flag is meaningful only for
      preadv2().

IOWs, we've explicitly designed interfaces to communicate whether
data is "immediately accessible" or not to the application so they
can make sensible decisions about IO scheduling. i.e. IO won't
block the main application processing loop and so can be scheduled in
the background by the app and the data processed when that IO
returns.  That just so happens to be exactly the same information
about the page cache that mincore is making available to userspace.

If we "remove" this information from the interfaces like it has been
done for mincore(), it doesn't mean userspace can't get it in other
ways. e.g. it now just has to time the read(2) syscall duration and
infer whether the data came from the page cache or disk from the
timing information.

IMO, there's nothing new or novel about this page cache information
leak - it was just a matter of time before some researcher put 2 and
2 together and realised that sharing the page cache across a
security boundary is little different from sharing deduplicated
pages across those same security boundaries.  i.e. As long as we
shared caches across security boundaries and userspace can control
both cache invalidation and instantiation, we cannot prevent
userspace from constructing these invalidate+read information
exfiltration scenarios.

And then there is overlayfs. Overlay is really just a way to
efficiently share the page cache of the same underlying read-only
directory tree across all containers on a host. i.e.  we have been
specifically designing our container hosting systems to share the
underlying read-only page cache across all security boundaries on
the host. If overlay is vulnerable to these shared page cache
attacks (seems extremely likely) then we've got much bigger problems
than mincore to think about....

> But doing a test patch during the merge window (which is about to
> close) sounds like the right thing to do.

IMO it seems like the wrong thing to do. It's just a hacky band-aid
over a specific extraction method and does nothing to reduce the
actual scope of the information leak. Focussing on the band-aid
means you've missed all the other avenues that the same information
is exposed and all the infrastructure we've build on the core
concept of sharing kernel side pages across security boundaries.

And that's even without considering whether the change breaks
userspace. Which it does. e.g. vmtouch is fairly widely used to
manage page cache instantiation for rapid bring-up and migration of
guest VMs and containers. They save the hot page cache information
from a running container and then using that to instantiate the page
cache in new instances running the same workload so they run at full
speed right from the start. This use case calls mincore() to pull
the page cache information from the running container.

If anyone else proposed merging a syscall implementation change that
was extremely likely to break userspace you'd be shouting at them
that "we don't break userspace"....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
