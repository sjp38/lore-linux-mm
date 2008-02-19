Date: Tue, 19 Feb 2008 16:36:23 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080217084906.e1990b11.pj@sgi.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com> <20080217084906.e1990b11.pj@sgi.com>
Message-Id: <20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

Thank you for wonderful interestings comment.
your comment is really nice.

I was HPC guy with large NUMA box at past. 
I promise i don't ignroe hpc user.
but unfortunately I didn't have experience of use CPUSET
because at that point, it was under development yet.

I hope discuss you that CPUSET usage case and mem_notify requirement.
to be honest, I thought hpc user doesn't use mem_notify, sorry.


> I have what seems, intuitively, a similar problem at the opposite
> end of the world, on big-honkin NUMA boxes (hundreds or thousands of
> CPUs, terabytes of main memory.)  The problem there is often best
> resolved if we can kill the offending task, rather than shrink its
> memory footprint.  The situation is that several compute intensive
> multi-threaded jobs are running, each in their own dedicated cpuset.

agreed.

> So we like to identify such jobs as soon as they begin to swap,
> and kill them very very quickly (before the direct reclaim code
> in mm/vmscan.c can push more than a few pages to the swap device.)

you think kill the process just after swap, right?
but unfortunately, almost user hope receive notification before swap ;-)
because avoid swap.

I think we need discuss this point more.


> For a much earlier, unsuccessful, attempt to accomplish this, see:
> 
> 	[Patch] cpusets policy kill no swap
> 	http://lkml.org/lkml/2005/3/19/148
> 
> Now, it may well be that we are too far apart to share any part of
> a solution; one seldom uses the same technology to build a Tour de
> France bicycle as one uses to build a Lockheed C-5A Galaxy heavy
> cargo transport.
> 
> One clear difference is the policy of what action we desire to take
> when under memory pressure: do we invite user space to free memory so
> as to avoid the wrath of the oom killer, or do we go to the opposite
> extreme, seeking a nearly instantant killing, faster than the oom
> killer can even begin its search for a victim.

Hmm, sorry
I understand your patch yet, because I don't know CPUSET so much.

I learn CPUSET more, about this week and I'll reply again about next week ;-)


> Another clear difference is the use of cpusets, which are a major and
> vital part of administering the big NUMA boxes, and I presume are not
> even compiled into embedded kernels (correct?).  This difference maybe
> unbridgeable ... these big NUMA systems require per-cpuset mechanisms,
> whereas embedded may require builds without cpusets.

Yes, some embedded distribution(i.e. monta vista) distribute as source.
but embedded people strongly dislike bloat code size.
I think they never turn on CPUSET.

I hope mem_notify works fine without CPUSET.


> 1) You have a little bit of code in the kernel to throttle the
>    thundering herd problem.  Perhaps this could be moved to user space
>    ... one user daemon that is always notified of such memory pressure
>    alarms, and in turn notifies interested applications.  This might
>    avoid the need to add poll_wait_exclusive() to the kernel.  And it
>    moves any fussy details of how to tame the thundering herd out of
>    the kernel.

I think you talk about user space oom manager.
it and many user process are obviously different.

I doubt memory manager daemon model doesn't works on desktop and
typical server.
thus, current implementaion optimize to no manager environment.

of course, it doesn't mean i refuse add to code for oom manager.
it is very interesting idea.

i hope discussion it more.


> 2) Another possible mechanism for communicating events from
>    the kernel to user space is inotify.  For example, I added
>    the line:
> 
>    	fsnotify_modify(dentry);   # dentry is current tasks cpuset

Excellent!
that is really good idea.

thaks.


> 3) Perhaps, instead of sending simple events, one could update
>    a meter of the rate of recent such events, such as the per-cpuset
>    'memory_pressure' mechanism does.  This might lead to addressing
>    Andrew Morton's comment:
> 
> 	If this feature is useful then I'd expect that some
> 	applications would want notification at different times, or at
> 	different levels of VM distress.  So this semi-randomly-chosen
> 	notification point just won't be strong enough in real-world
> 	use.

Hmmm, I don't think so.
I think timing of memmory_pressure_notify(1) is already best.

the page move active list to inactive list indicate swap I/O happen
a bit after.

but memmory_pressure_notify(0) is a bit messy.
I'll try to improve more simplify.


> 4) A place that I found well suited for my purposes (watching for
>    swapping from direct reclaim) was just before the lines in the
>    pageout() routine in mm/vmscan.c:
> 
>    	if (clear_page_dirty_for_io(page)) {
> 		...
> 		res = mapping->a_ops->writepage(page, &wbc);
> 
>    It seemed that testing "PageAnon(page)" here allowed me to easily
>    distinguish between dirty pages going back to the file system, and
>    pages going to swap (this detail is from work on a 2.6.16 kernel;
>    things might have changed.)
> 
>    One possible advantage of the above hook in the direct reclaim
>    code path in vmscan.c is that pressure in one cpuset did not cause
>    any false alarms in other cpusets.  However even this hook does
>    not take into account the constraints of mm/mempolicy (the NUMA
>    memory policy that Andi mentioned) nor of cgroup memory controllers.

Disagreed.
that is too late.

after writepage notifify mean can't avoid swap I/O.


> 5) I'd be keen to find an agreeable way that you could have the
>    system-wide, no cpuset, mechanism you need, while at the same
>    time, I have a cpuset interface that is similar and depends on the
>    same set of hooks.  This might involve a single set of hooks in
>    the key places in the memory and swapping code, that (1) updated
>    the system wide state you need, and (2) if cpusets were present,
>    updated similar state for the tasks current cpuset.  The user
>    visible API would present both the system-wide connector you need
>    (the special file or whatever) and if cpusets are present, similar
>    per-cpuset connectors.

that makes sense.
I will learn cpuset and think integrate mem_notify and cpuset.


and,

Please don't think I reject your idea.
your proposal is large different of past our discussion and
i don't know cpuset.

I think we can't drop all current design and accept your idea all, may be.
but we may be able to accept partial until hpc guys content enough.

I will learn to CPUSET more in a few days.
after it, we can discussion more.

please wait for a while.

Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
