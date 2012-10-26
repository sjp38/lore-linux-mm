Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 87FE96B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:31:50 -0400 (EDT)
Date: Fri, 26 Oct 2012 11:37:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs +
 man page
Message-ID: <20121026023720.GE15767@bbox>
References: <20121022111928.GA12396@lizard>
 <20121025064009.GA15767@bbox>
 <20121025090813.GA16078@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025090813.GA16078@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, Oct 25, 2012 at 02:08:14AM -0700, Anton Vorontsov wrote:
> Hello Minchan,
> 
> Thanks a lot for the email!
> 
> On Thu, Oct 25, 2012 at 03:40:09PM +0900, Minchan Kim wrote:
> [...]
> > > What applications (well, activity managers) are really interested in is
> > > this:
> > > 
> > > 1. Do we we sacrifice resources for new memory allocations (e.g. files
> > >    cache)?
> > > 2. Does the new memory allocations' cost becomes too high, and the system
> > >    hurts because of this?
> > > 3. Are we about to OOM soon?
> > 
> > Good but I think 3 is never easy.
> > But early notification would be better than late notification which can kill
> > someone.
> 
> Well, basically these are two fixed (strictly defined) levels (low and
> oom) + one flexible level (med), which meaning can be slightly tuned (but
> we still have a meaningful definition for it).
> 

I mean detection of "3) Are we about to OOM soon" isn't easy.

> So, I guess it's a good start. :)

Absolutely!

> 
> > > And here are the answers:
> > > 
> > > 1. VMEVENT_PRESSURE_LOW
> > > 2. VMEVENT_PRESSURE_MED
> > > 3. VMEVENT_PRESSURE_OOM
> > > 
> > > There is no "high" pressure, since I really don't see any definition of
> > > it, but it's possible to introduce new levels without breaking ABI. The
> > > levels described in more details in the patches, and the stuff is still
> > > tunable, but now via sysctls, not the vmevent_fd() call itself (i.e. we
> > > don't need to rebuild applications to adjust window size or other mm
> > > "details").
> > > 
> > > What I couldn't fix in this RFC is making vmevent_{scanned,reclaimed}
> > > stuff per-CPU (there's a comment describing the problem with this). But I
> > > made it lockless and tried to make it very lightweight (plus I moved the
> > > vmevent_pressure() call to a more "cold" path).
> > 
> > Your description doesn't include why we need new vmevent_fd(2).
> > Of course, it's very flexible and potential to add new VM knob easily but
> > the thing we is about to use now is only VMEVENT_ATTR_PRESSURE.
> > Is there any other use cases for swap or free? or potential user?
> 
> Number of idle pages by itself might be not that interesting, but
> cache+idle level is quite interesting.
> 
> By definition, _MED happens when performance already degraded, slightly,
> but still -- we can be swapping.
> 
> But _LOW notifications are coming when kernel is just reclaiming, so by
> using _LOW notifications + watching for cache level we can very easily
> predict the swapping activity long before we have even _MED pressure.

So, for seeing cache level, we need new vmevent_attr?

> 
> E.g. if idle+cache drops below amount of memory that userland can free,
> we'd indeed like to start freeing stuff (this somewhat resembles current
> logic that we have in the in-kernel LMK).
> 
> Sure, we can read and parse /proc/vmstat upon _LOW events (and that was my
> backup plan), but reporting stuff together would make things much nicer.

My concern is that user can imagine various scenario with vmstat and they might start to
require new vmevent_attr in future and vmevent_fd will be bloated and mm guys should
care of vmevent_vd whenever they add new vmstat. I don't like it. User can do it by
just reading /proc/vmstat. So I support your backup plan.


> 
> Although, I somewhat doubt that it is OK to report raw numbers, so this
> needs some thinking to develop more elegant solution.

Indeed.

> 
> Maybe it makes sense to implement something like PRESSURE_MILD with an
> additional nr_pages threshold, which basically hits the kernel about how
> many easily reclaimable pages userland has (that would be a part of our
> definition for the mild pressure level). So, essentially it will be
> 
> 	if (pressure_index >= oom_level)
> 		return PRESSURE_OOM;
> 	else if (pressure_index >= med_level)
> 		return PRESSURE_MEDIUM;
> 	else if (userland_reclaimable_pages >= nr_reclaimable_pages)
> 		return PRESSURE_MILD;
> 	return PRESSURE_LOW;
> 
> I must admit I like the idea more than exposing NR_FREE and stuff, but the
> scheme reminds me the blended attributes, which we abandoned. Although,
> the definition sounds better now, and we seem to be doing it in the right
> place.
> 
> And if we go this way, then sure, we won't need any other attributes, and
> so we could make the API much simpler.

That's what I want! If there isn't any user who really are willing to use it,
let's drop it. Do not persuade with imaginary scenario because we should be 
careful to introduce new ABI.

> 
> > Adding vmevent_fd without them is rather overkill.
> > 
> > And I want to avoid timer-base polling of vmevent if possbile.
> > mem_notify of KOSAKI doesn't use such timer.
> 
> For pressure notifications we don't use the timers. We also read the

Hmm, when I see the code, timer still works and can notify to user. No?

> vmstat counters together with the pressure, so "pressure + counters"
> effectively turns it into non-timer based polling. :)
> 
> But yes, hopefully we can get rid of the raw counters and timers, I don't
> them it too.

You and i are reaching on a conclusion, at least.

> 
> > I don't object but we need rationale for adding new system call which should
> > be maintained forever once we add it.
> 
> We can do it via eventfd, or /dev/chardev (which has been discussed and
> people didn't like it, IIRC), or signals (which also has been discussed
> and there are problems with this approach as well).
> 
> I'm not sure why having a syscall is a big issue. If we're making eventfd
> interface, then we'd need to maintain /sys/.../ ABI the same way as we
> maintain the syscall. What's the difference? A dedicated syscall is just a

No difference. What I want is just to remove unnecessary stuff in vmevent_fd
and keep it as simple. If we do via /dev/chardev, I expect we can do necessary
things for VM pressure. But if we can diet with vmevent_fd, It would be better.
If so, maybe we have to change vmevent_fd to lowmem_fd or vmpressure_fd.

> simpler interface, we don't need to mess with opening and passing things
> through /sys/.../.
> 
> Personally I don't have any preference (except that I distaste chardev and
> ioctls :), I just want to see pros and cons of all the solutions, and so
> far the syscall seems like an easiest way? Anyway, I'm totally open to
> changing it into whatever fits best.

Yeb. Interface stuff isn't a big concern for low memory notification so I'm not
against it stronlgy, too.

Thanks, Anton.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
