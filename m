Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E6A2B6B005A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2012 04:17:05 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3476369pad.14
        for <linux-mm@kvack.org>; Sun, 07 Oct 2012 01:17:05 -0700 (PDT)
Date: Sun, 7 Oct 2012 01:14:17 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC] vmevent: Implement pressure attribute
Message-ID: <20121007081414.GA18047@lizard>
References: <20121004110524.GA1821@lizard>
 <20121005092912.GA29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121005092912.GA29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, Colin Cross <ccross@android.com>, Arve Hj?nnev?g <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hello Mel,

Thanks for your comments!

On Fri, Oct 05, 2012 at 10:29:12AM +0100, Mel Gorman wrote:
[...]
> > The implemented approach can notify userland about two things:
> > 
> > - Constantly rising number of scanned pages shows that Linux is busy w/
> >   rehashing pages in general. The more we scan, the more it's obvious that
> >   we're out of unused pages, and we're draining caches. By itself it's not
> >   critical, but for apps that want to maintain caches level (like Android)
> >   it's quite useful. The notifications are ratelimited by a specified
> >   amount of scanned pages.
> > 
> 
> This is tricky but yes, a "constantly rising" increase of scanning can
> be of note. It's important to remember that a stready-streamer such as
> video playback can have a constant rate of scanning, but it's not
> indicative of a problem and it should not necessarily raise an event to
> userspace.
> 
> There should be three distinct stages that we're trying to spot.
> 
> kswapd scanning rate rising, direct reclaim scanning 0
> kswapd scanning rate rising or levelling off, direct reclaim scanning
> kswapd scanning rate levelling, direct reclaim levelling, efficiency dropping
> 
> Detecting all three is not critical for notification to be useful but
> it's probably the ideal.

Speaking of which, currently the factor accounts summed kswapd+direct
scanned/reclaim, i.e. only third case, so far I don't differentiate kswapd
scanning and direct scanning.

We can surely add monitoring for the first two stages, but naming them
"kswapd" or "direct reclaim" would kinda expose MM details, which we try
to avoid exposing in vmevent API. If we can come up with some "generic"
factor as in the third case, then it would be great indeed.

> Either way, I prefer attempting something like this a lot more than
> firing a notification because free memory is low!

Absolutely, I like it more as well.

[...]
> And I like the metric but not the name - mostly because we've used the
[...]
> For your current definition how about "Reclaim inefficiency" or "Reclaim
> wastage"?
> 
> "Reclaim inefficiency is the percentage of scans of pages that were not
> reclaimed"
> 
> "Reclaim wastage refers to the time spent by the kernel uselessly
> scanning pages"

Yeah, your words are all more to the point. Thanks for fixing my loosely
defied terms. :-)

I guess I should put most of your explanations into the documentation.

[...]
> > diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> > index b1c4016..1397ade 100644
> > --- a/include/linux/vmevent.h
> > +++ b/include/linux/vmevent.h
> > @@ -10,6 +10,7 @@ enum {
> >  	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
> >  	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
> >  	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
> > +	VMEVENT_ATTR_PRESSURE		= 4UL,
> >  
> >  	VMEVENT_ATTR_MAX		/* non-ABI */
> >  };
> 
> I don't care about this as such but do you think you'll want high pressure
> and low pressure notifications in the future or is that overkill?
> 
> low, shrink cache
> high, processes consider exiting
> 
> or something, dunno really.

Currently userland can set their own thresholds, i.e. from 0 to 100, and
kernel will only send notification once the value crosses the threshold
(it can be edge-triggered or continuous).

(Down below are just my thoughts, I'm not trying to "convince" you, just
sharing it so maybe you can see some flaws or misconceptions in my
thinking.)

The problem with defining low/high in the kernel (instead of 0..100 range)
is that people will want to tune it anyway. The decision what to consider
low or high pressure is more like user's preference.

Just an example:

x="I mostly single-task, I don't switch tasks often, and I want to run
foreground task as smooth as possible: do not care about the rest"

vs.

y="I want to multi-task everything: try to keep everything running, and
use swap if things do not fit"

The ratio x/y should be the base for setting up the pressure threshold. It
might be noted that it kind of reminds kernel's 'swappiness' -- how much
the user is willing to sacrifice of the "[idling] rest" in favour of
keeping things smooth for "recently used/new" stuff.

And here we just try to let userland to assist, userland can tell "oh,
don't bother with swapping or draining caches, I can just free some
memory".

Quite interesting, this also very much resembles volatile mmap ranges
(i.e. the work that John Stultz is leading in parallel).

And the volatile mmap is one of many techniques for such an assistance.
The downside of per-app volatile ranges though, is that that each app
should manage what is volatile and what is not, but the app itself doesn't
know about the overall system state, and whether the app is "important" at
this moment or not.

And here comes another approach, which Android also implements: activity
manager, it tries to predict what user wants, which apps the user uses the
most, which are running in the background but not necessary needed at the
moment, etc. The manager marks appropriate process to be "killed*" once we
are low on memory.

This is not to be confused w/ "which processes/pages are used the most",
since there's a huge difference between this, and "which apps the user
uses the most". Kernel can predict the former, but not the latter...


* Note that in Android case, all apps, which lowmemory killer is killing,
  have already saved their app state on disk, so swapping them makes
  almost no sense: we'll read everything from the disk anyway. (In
  contrast, if I recall correctly, Windows 8 has a similar function
  nowadays, but it just forcibly/prematurely swaps the apps, i.e. a
  combination of swap-prefetch and activity manager. And if so, I think
  Android is a bit smarter in that regard, it does things a little bit
  more fine-grained.)

[...]
> > +static LIST_HEAD(vmevent_pwatchers);
> > +static DEFINE_SPINLOCK(vmevent_pwatchers_lock);
> > +
> 
> Comment that the lock protects the list of current watchers of pressure
> and is taken during watcher registration and deregisteration.

Sure, will do.

> > +static uint vmevent_scanned;
> > +static uint vmevent_reclaimed;
> > +static uint vmevent_minwin = UINT_MAX; /* Smallest window in the list. */
> > +static DEFINE_SPINLOCK(vmevent_pressure_lock);
> > +
> 
> It's an RFC so do not consider this a slam but it may need fixing.
> 
> The vmevent_pressure_lock protects the vmevent_scanned, vmevent_reclaimed
> etc from concurrent modification but this happens on every
> shrink_inactive_list(). On small machines, this will not be a problem
> but on big machines, this is not going to scale at all. It could in fact
> force all reclaim to globally synchronise on this lock.
> 
> One possibility would be to make these per-cpu and lockless when
> incrementing the counters. When they reach a threshold, take the lock
> and update a central counter. It would introduce the problem that you
> suffer from per-cpu counter drift so it's not perfectly
> straight-forward.
> 
> Another possibility to consider is that you sample the vmstat counters
> in the zone from vmevent_pressure and measure the difference from the
> last read. That might be harder to get accurate figures from though.

Yeah, I'll think how to improve it, thanks for the ideas!

[...]
> > +static void vmevent_match_pressure(struct vmevent_pwatcher *pw)
> > +{
> > +	struct vmevent_watch *watch = pw->watch;
> > +	struct vmevent_attr *attr = pw->attr;
> > +	ulong val;
> > +
> > +	val = vmevent_calc_pressure(pw);
> > +
> > +	/* Next round. */
> > +	pw->scanned = 0;
> > +	pw->reclaimed = 0;
> > +
> > +	if (!vmevent_match_attr(attr, val))
> > +		return;
> > +
> 
> So, it's not commented on but if there is a brief spike in reclaim
> inefficiency due to slow storage then this might prematurely fire
> because there is no attempt to level off spikes.
> 
> To deal with this you would need to smooth out these spikes by
> considering multiple window sizes and only firing when all are hit. This
> does not necessaarily need to be visible to userspace because you could
> select the additional window sizes based on the size of the initial
> window.

Actually, initially I tried to smooth them by root square mean of the
previously calculated value, but I must admit it didn't make things much
better, as I would expect. Although I didn't try to use additional window
sizes, that might work indeed.

But yes, I guess it makes sense to play with it later, as soon as folks
agree on the idea in general, and there are no "design" issues of using
the heuristic.

> I also do not think that this problem needs to be fixed in the initial
> version because I could be wrong about it being a problem. It would be nice
> if it was documented in the comments though so if bug reports reports show
> up about caches shrinking too quickly because the event fires prematurely
> there is an idea in place on how to fix it.
> 
> > +	pw->samp->value = val;
> > +
> > +	atomic_set(&watch->pending, 1);
> > +	wake_up(&watch->waitq);
> > +}
> > +
> > +static void vmevent_pressure_tlet_fn(ulong data)
> > +{
> > +	struct vmevent_pwatcher *pw;
> > +	uint s;
> > +	uint r;
> > +
> > +	if (!vmevent_scanned)
> > +		return;
> > +
> > +	spin_lock(&vmevent_pressure_lock);
> > +	s = vmevent_scanned;
> > +	r = vmevent_reclaimed;
> > +	vmevent_scanned = 0;
> > +	vmevent_reclaimed = 0;
> > +	spin_unlock(&vmevent_pressure_lock);
> > +
> 
> Same as before, the pressure pool and reclaim contend for the same lock
> which is less than ideal.

OK

> > +	rcu_read_lock();
> > +	list_for_each_entry_rcu(pw, &vmevent_pwatchers, node) {
> > +		pw->scanned += s;
> > +		pw->reclaimed += r;
> > +		if (pw->scanned >= pw->window)
> > +			vmevent_match_pressure(pw);
> > +	}
> > +	rcu_read_unlock();
> 
> RCU seems overkill here. Protect it with the normal spinlock but use
> trylock here and abort the poll if the lock cannot be acquired. At worst
> a few polls will be missed while an event notifier is being registered.

Neat, will do.

> > +}
> > +static DECLARE_TASKLET(vmevent_pressure_tlet, vmevent_pressure_tlet_fn, 0);
> > +
> 
> Why a tasklet? What fires it? How often?

It is fired from the __vmevent_pressure, here:

> > +void __vmevent_pressure(struct mem_cgroup *memcg,
> > +			ulong scanned,
> > +			ulong reclaimed)
> > +{
[...]
> > +	vmevent_scanned += scanned;
> > +	vmevent_reclaimed += reclaimed;
> > +
> > +	if (vmevent_scanned >= vmevent_minwin)
> > +		tasklet_schedule(&vmevent_pressure_tlet);

I.e. we fire it every time we gathered enough of data for the next round.

We can't calculate the pressure factor here, since userland may setup
multiple thresholds for the pressure, so updating all the watchers will
not scale in this very hot path, I guess.

Since we're running outside of interrupt context, tasklet_schedule() would
just try to wakeup softirqd. I could use work_struct, it's just that it's
a bit more heavyweight, I think. But using the tasklet is a premature
"optimization", and I can make it work_struct, if that's desired.

[...]
> > +++ b/mm/vmscan.c
> > @@ -20,6 +20,7 @@
> >  #include <linux/init.h>
> >  #include <linux/highmem.h>
> >  #include <linux/vmstat.h>
> > +#include <linux/vmevent.h>
> >  #include <linux/file.h>
> >  #include <linux/writeback.h>
> >  #include <linux/blkdev.h>
> > @@ -1334,6 +1335,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  		nr_scanned, nr_reclaimed,
> >  		sc->priority,
> >  		trace_shrink_flags(file));
> > +
> > +	vmevent_pressure(sc->target_mem_cgroup, nr_scanned, nr_reclaimed);
> > +
> >  	return nr_reclaimed;
> >  }
> >  
> 
> Very broadly speaking I think this will work better in practice than plain
> "low memory notification" which I expect fires too often. There are some
> things that need fixing up, some comments and some clarifications but I
> think they can be addressed. The firing on spikes might be a problem in
> the future but it can be fixed without changing the user-visible API.

So far I only tested in "low memory notification mode", since it was my
primary concern. I surely need to perform more use-case/dogfooding tests,
for example try it on some heavy desktop environment on x86 machine, and
see how precisely it reflects the pressure. My test would be like this:

1. Start web/pdf browsing, with some video playback in background;
2. See if the pressure factor can reliably predict sluggish behaviour,
   i.e. excessive caches draining and swapping/thrashing.

And the prediction part is most important, of course, we should act
beforehand.


Much thanks for the review and ideas!

Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
