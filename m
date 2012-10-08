Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9844B6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 05:46:54 -0400 (EDT)
Date: Mon, 8 Oct 2012 10:46:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] vmevent: Implement pressure attribute
Message-ID: <20121008094646.GI29125@suse.de>
References: <20121004110524.GA1821@lizard>
 <20121005092912.GA29125@suse.de>
 <20121007081414.GA18047@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121007081414.GA18047@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, Colin Cross <ccross@android.com>, Arve Hj?nnev?g <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Sun, Oct 07, 2012 at 01:14:17AM -0700, Anton Vorontsov wrote:
> 
> On Fri, Oct 05, 2012 at 10:29:12AM +0100, Mel Gorman wrote:
> [...]
> > > The implemented approach can notify userland about two things:
> > > 
> > > - Constantly rising number of scanned pages shows that Linux is busy w/
> > >   rehashing pages in general. The more we scan, the more it's obvious that
> > >   we're out of unused pages, and we're draining caches. By itself it's not
> > >   critical, but for apps that want to maintain caches level (like Android)
> > >   it's quite useful. The notifications are ratelimited by a specified
> > >   amount of scanned pages.
> > > 
> > 
> > This is tricky but yes, a "constantly rising" increase of scanning can
> > be of note. It's important to remember that a stready-streamer such as
> > video playback can have a constant rate of scanning, but it's not
> > indicative of a problem and it should not necessarily raise an event to
> > userspace.
> > 
> > There should be three distinct stages that we're trying to spot.
> > 
> > kswapd scanning rate rising, direct reclaim scanning 0
> > kswapd scanning rate rising or levelling off, direct reclaim scanning
> > kswapd scanning rate levelling, direct reclaim levelling, efficiency dropping
> > 
> > Detecting all three is not critical for notification to be useful but
> > it's probably the ideal.
> 
> Speaking of which, currently the factor accounts summed kswapd+direct
> scanned/reclaim, i.e. only third case, so far I don't differentiate kswapd
> scanning and direct scanning.
> 

kswapd is the PGSCAN_KSWAPD counter and direct reclaim is the
PGSCAN_DIRECT counter so you should be able to distinguish between them.


> We can surely add monitoring for the first two stages, but naming them
> "kswapd" or "direct reclaim" would kinda expose MM details, which we try
> to avoid exposing in vmevent API. If we can come up with some "generic"
> factor as in the third case, then it would be great indeed.
> 

I wouldn't expect you to expose them to userspace and I agree with you that
it would completely miss the point. I'm suggesting that this information be
used internally when deciding whether to fire the vmevent or not. i.e. you
may decide to only fire the event when stage 3 is reached and call that
"high pressure".

> > Either way, I prefer attempting something like this a lot more than
> > firing a notification because free memory is low!
> 
> Absolutely, I like it more as well.
> 
> [...]
> > And I like the metric but not the name - mostly because we've used the
> [...]
> > For your current definition how about "Reclaim inefficiency" or "Reclaim
> > wastage"?
> > 
> > "Reclaim inefficiency is the percentage of scans of pages that were not
> > reclaimed"
> > 
> > "Reclaim wastage refers to the time spent by the kernel uselessly
> > scanning pages"
> 
> Yeah, your words are all more to the point. Thanks for fixing my loosely
> defied terms. :-)
> 
> I guess I should put most of your explanations into the documentation.
> 

Yes, this will need to be documented because there will be arguements
about how this is tuned. I would have thought that "low pressure", "high
pressure" and "extreme pressure" would be valid tuneables but I'm not a
target consumer of the interface so my opinion on the exact interface to
userspace does not count :)

> [...]
> > > diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> > > index b1c4016..1397ade 100644
> > > --- a/include/linux/vmevent.h
> > > +++ b/include/linux/vmevent.h
> > > @@ -10,6 +10,7 @@ enum {
> > >  	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
> > >  	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
> > >  	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
> > > +	VMEVENT_ATTR_PRESSURE		= 4UL,
> > >  
> > >  	VMEVENT_ATTR_MAX		/* non-ABI */
> > >  };
> > 
> > I don't care about this as such but do you think you'll want high pressure
> > and low pressure notifications in the future or is that overkill?
> > 
> > low, shrink cache
> > high, processes consider exiting
> > 
> > or something, dunno really.
> 
> Currently userland can set their own thresholds, i.e. from 0 to 100, and
> kernel will only send notification once the value crosses the threshold
> (it can be edge-triggered or continuous).
> 

Understood. The documentation should cover this.

> (Down below are just my thoughts, I'm not trying to "convince" you, just
> sharing it so maybe you can see some flaws or misconceptions in my
> thinking.)
> 
> The problem with defining low/high in the kernel (instead of 0..100 range)
> is that people will want to tune it anyway. The decision what to consider
> low or high pressure is more like user's preference.
> 

I think you're right that people will want to tune it. Be careful though
that the meaning of a number like "70" does not change between releases
through. i.e. there is a risk that the number exposes internals of the
implementation if you're not careful if that number 70 is based on the
ratio between two values. If the meaning of that ratio ever changes then
the applications may need tuning so be careful there.

I think writing the documentation will mitigate this risk of getting the
interface wrong. Does the vmevent interface have manual pages of any
description?

> Just an example:
> 
> x="I mostly single-task, I don't switch tasks often, and I want to run
> foreground task as smooth as possible: do not care about the rest"
> 
> vs.
> 
> y="I want to multi-task everything: try to keep everything running, and
> use swap if things do not fit"
> 
> The ratio x/y should be the base for setting up the pressure threshold. It
> might be noted that it kind of reminds kernel's 'swappiness' -- how much
> the user is willing to sacrifice of the "[idling] rest" in favour of
> keeping things smooth for "recently used/new" stuff.
> 

That's fair enough although bear in mind that the swappiness parameter
has changed meaning slightly over time. It has not been a major problem
but take care.

> And here we just try to let userland to assist, userland can tell "oh,
> don't bother with swapping or draining caches, I can just free some
> memory".
> 
> Quite interesting, this also very much resembles volatile mmap ranges
> (i.e. the work that John Stultz is leading in parallel).
> 

Agreed. I haven't been paying close attention to those patches but it
seems to me that one possiblity is that a listener for a vmevent would
set volatile ranges in response.

> And the volatile mmap is one of many techniques for such an assistance.
> The downside of per-app volatile ranges though, is that that each app
> should manage what is volatile and what is not, but the app itself doesn't
> know about the overall system state, and whether the app is "important" at
> this moment or not.
> 

Indeed and that may be a problem because userspace cannot know the
global memory state nor is it reasonable to expect that applications
will co-ordinate perfectly.

> And here comes another approach, which Android also implements: activity
> manager, it tries to predict what user wants, which apps the user uses the
> most, which are running in the background but not necessary needed at the
> moment, etc. The manager marks appropriate process to be "killed*" once we
> are low on memory.
> 

I do not think that the activity manager approach hurts your proposed
interface.

For example, the activity manager could be implemented to be the only
receiver of vmevents from the kernel. It selects which applications to
inform to shrink. It could do this after examining the applications and
deciding a priority.

This would require that applications use a library instead of vmevents
directly. Depending on the system configuration, the library would decide
whether to listen for vmevents or listen to a process like "activity
manager". The library could be implemented to raise vmevents through an
existing service bus like dbus.

A problem may exist where activity manager needs to respond quickly if
it has not informed enough applications. I'm not sure how exactly that
problem would be dealt with but it seems sensible to implement that
policy decision in userspace in a central place than trying to put a
filtering policy in the kernel or expecting all applications to be
implemented perfectly and mediate between each other on who should
shrink.

> This is not to be confused w/ "which processes/pages are used the most",
> since there's a huge difference between this, and "which apps the user
> uses the most". Kernel can predict the former, but not the latter...
> 

Yes, but the decision can be punted to something like activity manager
that knows more about the system. Job schedulers might make different
decisions on migrating jobs to other machines in the cluster depending on
the vmevents fired. These are two extremes but illustrate why I think the
kernel making the policy decision will be a rathole :)

> * Note that in Android case, all apps, which lowmemory killer is killing,
>   have already saved their app state on disk, so swapping them makes
>   almost no sense: we'll read everything from the disk anyway. (In
>   contrast, if I recall correctly, Windows 8 has a similar function
>   nowadays, but it just forcibly/prematurely swaps the apps, i.e. a
>   combination of swap-prefetch and activity manager. And if so, I think
>   Android is a bit smarter in that regard, it does things a little bit
>   more fine-grained.)
> 

Interesting.

> > > <SNIP>
> > > +static void vmevent_match_pressure(struct vmevent_pwatcher *pw)
> > > +{
> > > +	struct vmevent_watch *watch = pw->watch;
> > > +	struct vmevent_attr *attr = pw->attr;
> > > +	ulong val;
> > > +
> > > +	val = vmevent_calc_pressure(pw);
> > > +
> > > +	/* Next round. */
> > > +	pw->scanned = 0;
> > > +	pw->reclaimed = 0;
> > > +
> > > +	if (!vmevent_match_attr(attr, val))
> > > +		return;
> > > +
> > 
> > So, it's not commented on but if there is a brief spike in reclaim
> > inefficiency due to slow storage then this might prematurely fire
> > because there is no attempt to level off spikes.
> > 
> > To deal with this you would need to smooth out these spikes by
> > considering multiple window sizes and only firing when all are hit. This
> > does not necessaarily need to be visible to userspace because you could
> > select the additional window sizes based on the size of the initial
> > window.
> 
> Actually, initially I tried to smooth them by root square mean of the
> previously calculated value, but I must admit it didn't make things much
> better, as I would expect. Although I didn't try to use additional window
> sizes, that might work indeed.
> 

Thanks. I do not think it's critical to solve this problem because in
practice people might not care.

> But yes, I guess it makes sense to play with it later, as soon as folks
> agree on the idea in general, and there are no "design" issues of using
> the heuristic.
> 

Agreed. I think it's important to get the documentation on the interface
down so people can bitch about that without worrying about the exact
internal implementation. If V2 of this patch included docs I think it
would be critical that people like Pekka take a look and ideally someone
from Google who *might* be interested in using an interface like this for
managing whether jobs should get cancelled because a high-priority job
was starting on the machine.

> > > <SNIP>
> > > +void __vmevent_pressure(struct mem_cgroup *memcg,
> > > +			ulong scanned,
> > > +			ulong reclaimed)
> > > +{
> [...]
> > > +	vmevent_scanned += scanned;
> > > +	vmevent_reclaimed += reclaimed;
> > > +
> > > +	if (vmevent_scanned >= vmevent_minwin)
> > > +		tasklet_schedule(&vmevent_pressure_tlet);
> 
> I.e. we fire it every time we gathered enough of data for the next round.
> 

Ok comment that and include it in the documentation.

But that aside, why are you using a tasklet as opposed to something like
schedule_work()? Tasklets make me think this is somehow interrupt related.

> We can't calculate the pressure factor here, since userland may setup
> multiple thresholds for the pressure, so updating all the watchers will
> not scale in this very hot path, I guess.
> 

Ok.

> Since we're running outside of interrupt context, tasklet_schedule() would
> just try to wakeup softirqd. I could use work_struct, it's just that it's
> a bit more heavyweight, I think. But using the tasklet is a premature
> "optimization", and I can make it work_struct, if that's desired.
> 

I really think you should be using schedule_work() here but I do not
have a concrete basis for that assessment. I believe (but did not double
check) that tasklets are limited to running on one CPU at a time. This
should not be a problem for you but it's still odd to limit it
indirectly like that.

More importantly I worry that using tasklets will increase the latency
of interrupt handling as the vm event pressure handling will run with
bottom-halves disabled. Similiarly it feels wrong that pressure handling
would be given a similar priority to handling interrupts. That feels
very wrong.

I recognise this is not great reasoning but I do feel you should use
workqueues unless it can be shown that it is required to handle it as
a softirq. If this had to be processed as a softirq then I'd be more
comfortable if Thomas Glexiner took a quick look at just a patch that
converted the workqueue to a tasklet and see how hard he stomps on it.
I'm guessing it will be lots of stomping so I'm not cc'ing him at this
point to save his foot.

> [...]
> > > +++ b/mm/vmscan.c
> > > @@ -20,6 +20,7 @@
> > >  #include <linux/init.h>
> > >  #include <linux/highmem.h>
> > >  #include <linux/vmstat.h>
> > > +#include <linux/vmevent.h>
> > >  #include <linux/file.h>
> > >  #include <linux/writeback.h>
> > >  #include <linux/blkdev.h>
> > > @@ -1334,6 +1335,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> > >  		nr_scanned, nr_reclaimed,
> > >  		sc->priority,
> > >  		trace_shrink_flags(file));
> > > +
> > > +	vmevent_pressure(sc->target_mem_cgroup, nr_scanned, nr_reclaimed);
> > > +
> > >  	return nr_reclaimed;
> > >  }
> > >  
> > 
> > Very broadly speaking I think this will work better in practice than plain
> > "low memory notification" which I expect fires too often. There are some
> > things that need fixing up, some comments and some clarifications but I
> > think they can be addressed. The firing on spikes might be a problem in
> > the future but it can be fixed without changing the user-visible API.
> 
> So far I only tested in "low memory notification mode", since it was my
> primary concern. I surely need to perform more use-case/dogfooding tests,
> for example try it on some heavy desktop environment on x86 machine, and
> see how precisely it reflects the pressure. My test would be like this:
> 
> 1. Start web/pdf browsing, with some video playback in background;
> 2. See if the pressure factor can reliably predict sluggish behaviour,
>    i.e. excessive caches draining and swapping/thrashing.
> 

That seems very reasonable.

> And the prediction part is most important, of course, we should act
> beforehand.
> 
> Much thanks for the review and ideas!
> 

My pleasure. Thanks for the implementation :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
