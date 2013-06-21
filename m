Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0F0256B0034
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 12:44:21 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so8045406pab.41
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:44:21 -0700 (PDT)
Date: Sat, 22 Jun 2013 01:44:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
Message-ID: <20130621164413.GA4759@gmail.com>
References: <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621162743.GA2837@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Sat, Jun 22, 2013 at 01:27:43AM +0900, Minchan Kim wrote:
> Hello Michal,
> 
> On Fri, Jun 21, 2013 at 11:19:44AM +0200, Michal Hocko wrote:
> > On Fri 21-06-13 10:22:34, Minchan Kim wrote:
> > > On Fri, Jun 21, 2013 at 09:24:38AM +0900, Hyunhee Kim wrote:
> > > > In the original vmpressure, events are triggered whenever there is a reclaim
> > > > activity. This becomes overheads to user space module and also increases
> > > 
> > > Not true.
> > > We have lots of filter to not trigger event even if reclaim is going on.
> > > Your statement would make confuse.
> > 
> > Where is the filter implemented? In the kernel? I do not see any
> > throttling in the current mm tree.
> 
> 1. mem_cgroup_soft_limit_reclaim
> 2. reclaim caused by DMA zone
> 3. vmpressure_win
> 
> > 
> > > > power consumption if there is somebody to listen to it. This patch provides
> > > > options to trigger events only when the pressure level changes.
> > > > This trigger option can be set when registering each event by writing
> > > > a trigger option, "edge" or "always", next to the string of levels.
> > > > "edge" means that the event is triggered only when the pressure level is changed.
> > > > "always" means that events are triggered whenever there is a reclaim process.
> > >                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > >                                                   Not true, either.
> > 
> > Is this about vmpressure_win? But I agree that this could be more
> > specific. Something like "`Always' trigger option will signal all events
> > while `edge' option will trigger only events when the level changes."
> > 
> > > > To keep backward compatibility, "always" is set by default if nothing is input
> > > > as an option. Each event can have different option. For example,
> > > > "low" level uses "always" trigger option to see reclaim activity at user space
> > > > while "medium"/"critical" uses "edge" to do an important job
> > > > like killing tasks only once.
> > > 
> > > Question.
> > > 
> > > 1. user: set critical edge
> > > 2. kernel: memory is tight and trigger event with critical
> > > 3. user: kill a program when he receives a event
> > > 4. kernel: memory is very tight again and want to trigger a event
> > >    with critical but fail because last_level was critical and it was edge.
> > > 
> > > Right?
> > 
> > yes, this is the risk of the edge triggering and the user has to be
> > prepared for that. I still think that it makes some sense to have the
> > two modes.
> 
> I'm not sure it's good idea.
> How could user overcome above problem?
> The problem is "critical" means that the memory is really tight so
> that user should do ememgency plan to overcome the situation like
> kill someone. Even, kill could be a problem because the one from userspace
> couldn't use reserved memory pool so that killing could be stalled for a
> long time and then, we could end up encountering OOM. :(
> 
> So, the description should include how to overcome above situation in
> userspace efficiently even though memory is really tight, which we don't
> have extra memory to read vmstat.
> 
> We reviewers should review that it does make sense. If so, we need to
> write down it in documentation, otherwise, we should fix it from kernel
> side.
> 
> Another problem from this patch is that it couldn't detect same event
> contiguously so you are saying userspace have to handle it.
> It doesn't make sense to me. Why should user handle such false positive?
> I don't mean false positive signal is bad because low memory notification
> has inherent such a problem but we should try to avoid such frequent triggering
> if possible.
> IOW, It reveals current vmpressure's problem.
> Fix it without band-aiding of userspace if it's really problem.
> 

1. One of the design problem is that why vmpressure trigger by per-zone
   while userspace isn't aware of zone. It would trigger event
   several time during walking several zones in reclaim path.

2. Why vmpressure skip if another work is pending?
   More urgent work should preempt exisitng pending work.

3. The reclaimed could be greater than scanned in vmpressure_evnet
   by several reasons. Totally, It could trigger wrong event.

2 and 3 is another story but 1 would be related to this problem.
Anyway, I suggest let's fix kernel first without userside's
awkward bandaid.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
