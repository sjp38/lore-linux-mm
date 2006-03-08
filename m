From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 12:12:02 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081151.13942.kernel@kolivas.org> <20060307171134.59288092.akpm@osdl.org>
In-Reply-To: <20060307171134.59288092.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081212.03223.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2006 12:11 pm, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> > On Wed, 8 Mar 2006 11:05 am, Andrew Morton wrote:
> > > Con Kolivas <kernel@kolivas.org> wrote:
> > > > > yield() really sucks if there are a lot of runnable tasks.  And the
> > > > > amount of CPU which that thread uses isn't likely to matter anyway.
> > > > >
> > > > > I think it'd be better to just not do this.  Perhaps alter the
> > > > > thread's static priority instead?  Does the scheduler have a knob
> > > > > which can be used to disable a tasks's dynamic priority boost
> > > > > heuristic?
> > > >
> > > > We do have SCHED_BATCH but even that doesn't really have the desired
> > > > effect. I know how much yield sucks and I actually want it to suck as
> > > > much as yield does.
> > >
> > > Why do you want that?
> > >
> > > If prefetch is doing its job then it will save the machine from a pile
> > > of major faults in the near future.  The fact that the machine happens
> > > to be running a number of busy tasks doesn't alter that.  It's _worth_
> > > stealing a few cycles from those tasks now to avoid lengthy D-state
> > > sleeps in the near future?
> >
> > The test case is the 3d (gaming) app that uses 100% cpu. It never sets
> > delay swap prefetch in any way so swap prefetching starts working. Once
> > swap prefetching starts reading it is mostly in uninterruptible sleep and
> > always wakes up on the active array ready for cpu, never expiring even
> > with its miniscule timeslice. The 3d app is always expiring and landing
> > on the expired array behind kprefetchd even though kprefetchd is nice 19.
> > The practical upshot of all this is that kprefetchd does a lot of
> > prefetching with 3d gaming going on, and no amount of priority fiddling
> > stops it doing this. The disk access is noticeable during 3d gaming
> > unfortunately. Yielding regularly means a heck of a lot less prefetching
> > occurs and is no longer noticeable. When idle, yield()ing doesn't seem to
> > adversely affect the effectiveness of the prefetching.
>
> but, but.  If prefetching is prefetching stuff which that game will soon
> use then it'll be an aggregate improvement.  If prefetch is prefetching
> stuff which that game _won't_ use then prefetch is busted.  Using yield()
> to artificially cripple kprefetchd is a rather sad workaround isn't it?

It's not the stuff that it prefetches that's the problem; it's the disk 
access.

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
