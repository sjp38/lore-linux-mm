Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8ED4A6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 21:05:58 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3421812pbb.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 18:05:57 -0700 (PDT)
Date: Fri, 26 Oct 2012 18:02:15 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs +
 man page
Message-ID: <20121027010215.GA9152@lizard>
References: <20121022111928.GA12396@lizard>
 <20121025064009.GA15767@bbox>
 <20121025090813.GA16078@lizard>
 <20121026023720.GE15767@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121026023720.GE15767@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Fri, Oct 26, 2012 at 11:37:20AM +0900, Minchan Kim wrote:
[...]
> > > Of course, it's very flexible and potential to add new VM knob easily but
> > > the thing we is about to use now is only VMEVENT_ATTR_PRESSURE.
> > > Is there any other use cases for swap or free? or potential user?
> > 
> > Number of idle pages by itself might be not that interesting, but
> > cache+idle level is quite interesting.
> > 
> > By definition, _MED happens when performance already degraded, slightly,
> > but still -- we can be swapping.
> > 
> > But _LOW notifications are coming when kernel is just reclaiming, so by
> > using _LOW notifications + watching for cache level we can very easily
> > predict the swapping activity long before we have even _MED pressure.
> 
> So, for seeing cache level, we need new vmevent_attr?

Hopefully, not. We're not interested in the raw values of the cache level,
but what we want is to to tell the kernel how much "easily reclaimable
pages" userland has, and get notified when kernel believes that it's good
time for the userland is to help. I.e. this new _MILD level:

> > Maybe it makes sense to implement something like PRESSURE_MILD with an
> > additional nr_pages threshold, which basically hits the kernel about how
> > many easily reclaimable pages userland has (that would be a part of our
> > definition for the mild pressure level). So, essentially it will be
> > 
> > 	if (pressure_index >= oom_level)
> > 		return PRESSURE_OOM;
> > 	else if (pressure_index >= med_level)
> > 		return PRESSURE_MEDIUM;
> > 	else if (userland_reclaimable_pages >= nr_reclaimable_pages)
> > 		return PRESSURE_MILD;
> > 	return PRESSURE_LOW;
> > 
> > I must admit I like the idea more than exposing NR_FREE and stuff, but the
> > scheme reminds me the blended attributes, which we abandoned. Although,
> > the definition sounds better now, and we seem to be doing it in the right
> > place.
> > 
> > And if we go this way, then sure, we won't need any other attributes, and
> > so we could make the API much simpler.
> 
> That's what I want! If there isn't any user who really are willing to use it,
> let's drop it. Do not persuade with imaginary scenario because we should be 
> careful to introduce new ABI.

Yeah, I think you're right. Let's make the vmevent_fd slim first. I won't
even focus on the _MILD/_BALANCE level for now, we can do it later, and we
always have the /proc/vmstat even if the _MILD turns out to be a bad idea.

Reading /proc/vmstat is a bit more overhead, but it's not that much at all
(especially when we don't have to timer-poll the vmstat).

> > > Adding vmevent_fd without them is rather overkill.
> > > 
> > > And I want to avoid timer-base polling of vmevent if possbile.
> > > mem_notify of KOSAKI doesn't use such timer.
> > 
> > For pressure notifications we don't use the timers. We also read the
> 
> Hmm, when I see the code, timer still works and can notify to user. No?

Yes, I was mostly saying that it is technically not required anymore, but
you're right, the code still fires the timer (it just runs needlessly for
the pressure attr).

Bad wording on my side.

[..]
> > We can do it via eventfd, or /dev/chardev (which has been discussed and
> > people didn't like it, IIRC), or signals (which also has been discussed
> > and there are problems with this approach as well).
> > 
> > I'm not sure why having a syscall is a big issue. If we're making eventfd
> > interface, then we'd need to maintain /sys/.../ ABI the same way as we
> > maintain the syscall. What's the difference? A dedicated syscall is just a
> 
> No difference. What I want is just to remove unnecessary stuff in vmevent_fd
> and keep it as simple. If we do via /dev/chardev, I expect we can do necessary
> things for VM pressure. But if we can diet with vmevent_fd, It would be better.
> If so, maybe we have to change vmevent_fd to lowmem_fd or
> vmpressure_fd.

Sure, then I'm starting the work to slim the API down, and we'll see how
things are going to look after that.

Thanks a lot!

Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
