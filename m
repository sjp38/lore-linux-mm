From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Date: Thu, 20 Dec 2007 10:40:28 +1100
References: <20071218211539.250334036@redhat.com> <1198083218.5333.48.camel@localhost> <1198092503.6484.21.camel@twins>
In-Reply-To: <1198092503.6484.21.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712201040.29040.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 20 December 2007 06:28, Peter Zijlstra wrote:
> On Wed, 2007-12-19 at 11:53 -0500, Lee Schermerhorn wrote:
> > On Wed, 2007-12-19 at 11:31 -0500, Rik van Riel wrote:
> > > On Wed, 19 Dec 2007 10:52:09 -0500
> > >
> > > Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > > I keep these patches up to date for testing.  I don't have conclusive
> > > > evidence whether they alleviate or exacerbate the problem nor by how
> > > > much.
> > >
> > > When the queued locking from Ingo's x86 tree hits mainline,
> > > I suspect that spinlocks may end up behaving a lot nicer.
> >
> > That would be worth testing with our problematic workloads...
> >
> > > Should I drop the rwlock patches from my tree for now and
> > > focus on just the page reclaim stuff?
> >
> > That's fine with me.  They're out there is anyone is interested.  I'll
> > keep them up to date in my tree [and hope they don't conflict with split
> > lru and noreclaim patches too much] for occasional testing.
>
> Of course, someone would need to implement ticket locks for ia64 -
> preferably without the 256 cpu limit.

Yep. Wouldn't be hard at all -- ia64 has a "fetchadd" with acquire
semantics.

The only reason the x86 ticket locks have the 256 CPu limit is that
if they go any bigger, we can't use the partial registers so would
have to have a few more instructions.


> Nick, growing spinlock_t to 64 bits would yield space for 64k cpus
> right? I'm guessing that would be enough for a while, even for SGI.

A 32 bit spinlock would allow 64K cpus (ticket lock has 2 counters,
each would be 16 bits). And it would actually shrink the spinlock in
the case of preempt kernels too (because it would no longer have the
lockbreak field).

And yes, I'll go out on a limb and say that 64k CPUs ought to be
enough for anyone ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
