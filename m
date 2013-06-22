Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 226366B0031
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 00:36:59 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so8158819lab.36
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 21:36:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130621162743.GA2837@gmail.com>
References: <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
	<20130618110151.GI13677@dhcp22.suse.cz>
	<00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
	<20130619125329.GB16457@dhcp22.suse.cz>
	<000401ce6d5c$566ac620$03405260$%kim@samsung.com>
	<20130620121649.GB27196@dhcp22.suse.cz>
	<001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
	<001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
	<20130621012234.GF11659@bbox>
	<20130621091944.GC12424@dhcp22.suse.cz>
	<20130621162743.GA2837@gmail.com>
Date: Sat, 22 Jun 2013 13:36:56 +0900
Message-ID: <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, Kyungmin Park <kyungmin.park@samsung.com>

2013/6/22 Minchan Kim <minchan@kernel.org>:
> Hello Michal,
>
> On Fri, Jun 21, 2013 at 11:19:44AM +0200, Michal Hocko wrote:
>> On Fri 21-06-13 10:22:34, Minchan Kim wrote:
>> > On Fri, Jun 21, 2013 at 09:24:38AM +0900, Hyunhee Kim wrote:
>> > > In the original vmpressure, events are triggered whenever there is a reclaim
>> > > activity. This becomes overheads to user space module and also increases
>> >
>> > Not true.
>> > We have lots of filter to not trigger event even if reclaim is going on.
>> > Your statement would make confuse.
>>
>> Where is the filter implemented? In the kernel? I do not see any
>> throttling in the current mm tree.
>
> 1. mem_cgroup_soft_limit_reclaim
> 2. reclaim caused by DMA zone
> 3. vmpressure_win
>
>>
>> > > power consumption if there is somebody to listen to it. This patch provides
>> > > options to trigger events only when the pressure level changes.
>> > > This trigger option can be set when registering each event by writing
>> > > a trigger option, "edge" or "always", next to the string of levels.
>> > > "edge" means that the event is triggered only when the pressure level is changed.
>> > > "always" means that events are triggered whenever there is a reclaim process.
>> >                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> >                                                   Not true, either.
>>
>> Is this about vmpressure_win? But I agree that this could be more
>> specific. Something like "`Always' trigger option will signal all events
>> while `edge' option will trigger only events when the level changes."
>>
>> > > To keep backward compatibility, "always" is set by default if nothing is input
>> > > as an option. Each event can have different option. For example,
>> > > "low" level uses "always" trigger option to see reclaim activity at user space
>> > > while "medium"/"critical" uses "edge" to do an important job
>> > > like killing tasks only once.
>> >
>> > Question.
>> >
>> > 1. user: set critical edge
>> > 2. kernel: memory is tight and trigger event with critical
>> > 3. user: kill a program when he receives a event
>> > 4. kernel: memory is very tight again and want to trigger a event
>> >    with critical but fail because last_level was critical and it was edge.
>> >
>> > Right?
>>
>> yes, this is the risk of the edge triggering and the user has to be
>> prepared for that. I still think that it makes some sense to have the
>> two modes.
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

Thanks for your review.
With the current vmpressure, if we registered all of the levels "low",
"medium", and "critical", and the current level is critical,
there are so many signals. Whenever the critical signal occurs
continuously, "low" and "medium" are also signaled.
And, I still think that in the critical situation, handling these
signals becomes overheads.

How about handling low memory situation, e.g., reclaiming, swapping,
killing some processes, until the lower level event is signaled?
For example,
1. register "medium" and "critical" with edge trigger option
2. When we reach "critical" level, start to kill processes until we
receive "medium"
3. If the memory state become critical again, we can get signal again.

However, in the current vmpressure, vmpressure_level_med and
vmpressure_level_critical are fixed to 60 and 95.
If there is an interface to change these thresholds when registering
each event, I think that we can use "medium" level (this is an
example. we can also make new level) with new threshold (if 60 is too
small) as the level we can finish the low memory handler.

What's your opinion?

Thanks,
Hyunhee Kim.

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
>>
>> > > @@ -823,7 +831,7 @@ Test:
>> > >     # cd /sys/fs/cgroup/memory/
>> > >     # mkdir foo
>> > >     # cd foo
>> > > -   # cgroup_event_listener memory.pressure_level low &
>> > > +   # cgroup_event_listener memory.pressure_level low edge &
>> > >     # echo 8000000 > memory.limit_in_bytes
>> > >     # echo 8000000 > memory.memsw.limit_in_bytes
>> > >     # echo $$ > tasks
>> > > diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> > > index 736a601..a08252e 100644
>> > > --- a/mm/vmpressure.c
>> > > +++ b/mm/vmpressure.c
>> > > @@ -137,6 +137,8 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>> > >  struct vmpressure_event {
>> > >   struct eventfd_ctx *efd;
>> > >   enum vmpressure_levels level;
>> > > + int last_level;
>> >
>> > int? but level is enum vmpressure_levels?
>>
>> good catch
>>
>> > > + bool edge_trigger;
>> > >   struct list_head node;
>> > >  };
>> > >
>> > > @@ -153,11 +155,14 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>> > >
>> > >   list_for_each_entry(ev, &vmpr->events, node) {
>> > >           if (level >= ev->level) {
>> > > +                 if (ev->edge_trigger && level == ev->last_level)
>> > > +                         continue;
>> > > +
>> > >                   eventfd_signal(ev->efd, 1);
>> > >                   signalled = true;
>> > >           }
>> > > +         ev->last_level = level;
>> > >   }
>> > > -
>> >
>> > Unnecessary change.
>> >
>> > >   mutex_unlock(&vmpr->events_lock);
>> > >
>> > >   return signalled;
>> > > @@ -290,9 +295,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
>> > >   *
>> > >   * This function associates eventfd context with the vmpressure
>> > >   * infrastructure, so that the notifications will be delivered to the
>> > > - * @eventfd. The @args parameter is a string that denotes pressure level
>> > > + * @eventfd. The @args parameters are a string that denotes pressure level
>> > >   * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
>> > > - * "critical").
>> > > + * "critical") and a trigger option that decides whether events are triggered
>> > > + * continuously or only on edge ("always" or "edge" if "edge", events
>> > > + * are triggered when the pressure level changes.
>> > >   *
>> > >   * This function should not be used directly, just pass it to (struct
>> > >   * cftype).register_event, and then cgroup core will handle everything by
>> > > @@ -303,22 +310,43 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>> > >  {
>> > >   struct vmpressure *vmpr = cg_to_vmpressure(cg);
>> > >   struct vmpressure_event *ev;
>> > > + char *strlevel, *strtrigger;
>> > >   int level;
>> > > + bool trigger;
>> >
>> > What trigger?
>> > Would be better to use "bool egde" instead?
>>
>> yes
>>
>> > > +
>> > > + strlevel = args;
>> > > + strtrigger = strchr(args, ' ');
>> > > +
>> > > + if (strtrigger) {
>> > > +         *strtrigger = '\0';
>> > > +         strtrigger++;
>> > > + }
>> > >
>> > >   for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
>> > > -         if (!strcmp(vmpressure_str_levels[level], args))
>> > > +         if (!strcmp(vmpressure_str_levels[level], strlevel))
>> > >                   break;
>> > >   }
>> > >
>> > >   if (level >= VMPRESSURE_NUM_LEVELS)
>> > >           return -EINVAL;
>> > >
>> > > + if (strtrigger == NULL)
>> > > +         trigger = false;
>> > > + else if (!strcmp(strtrigger, "always"))
>> > > +         trigger = false;
>> > > + else if (!strcmp(strtrigger, "edge"))
>> > > +         trigger = true;
>> > > + else
>> > > +         return -EINVAL;
>> > > +
>> > >   ev = kzalloc(sizeof(*ev), GFP_KERNEL);
>> > >   if (!ev)
>> > >           return -ENOMEM;
>> > >
>> > >   ev->efd = eventfd;
>> > >   ev->level = level;
>> > > + ev->last_level = -1;
>> >
>> > VMPRESSURE_NONE is better?
>>
>> Yes
>> --
>> Michal Hocko
>> SUSE Labs
>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
