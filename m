Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 23C668D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 07:19:02 -0400 (EDT)
Date: Tue, 29 Mar 2011 13:18:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110329111858.GF30671@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328114430.GE5693@tiehlicka.suse.cz>
 <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz>
 <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329085942.GD30671@tiehlicka.suse.cz>
 <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-03-11 18:41:19, KAMEZAWA Hiroyuki wrote:
> On Tue, 29 Mar 2011 10:59:43 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 29-03-11 16:51:17, KAMEZAWA Hiroyuki wrote:
[...]
> > > My opinions is to enhance softlimit is better.
> > 
> > I will look how softlimit can be enhanced to match the expectations but
> > I'm kind of suspicious it can handle workloads where heuristics simply
> > cannot guess that the resident memory is important even though it wasn't
> > touched for a long time.
> > 
> 
> I think we recommend mlock() or hugepagefs to pin application's work area
> in usual. And mm guyes have did hardwork to work mm better even without
> memory cgroup under realisitic workloads.

Agreed. Whenever this approach is possible we recomend the same thing.

> If your worload is realistic but _important_ anonymous memory is swapped out,
> it's problem of global VM rather than memcg.

I would disagree with you on that. The important thing is that it can be
defined from many perspectives. One is the kernel which considers long
unused memory as not _that_ important. And it makes a perfect sense for
most workloads.
An important memory for an application can be something that would
considerably increase the latency just because the memory got paged out
(be it swap or the storage) because it contains pre-computed
data that have a big initial costs. 
As you can see there is no mention about the time from the application
POV because it can depend on the incoming requests which you cannot
control.

> If you add 'isolate' per process, okay, I'll agree to add isolate per memcg.

What do you mean by isolate per process?

[...]
> > > > OK, I have tried to explain that in one of the (2nd) patch description.
> > > > If I move all task from the root group to other group(s) and keep the
> > > > primary application in the root group I would achieve some isolation as
> > > > well. That is very much true. 
> > > 
> > > Okay, then, current works well.
> > > 
> > > > But then there is only one such a group.
> > > 
> > > I can't catch what you mean. you can create limitless cgroup, anywhere.
> > > Can't you ?
> > 
> > This is not about limits. This is about global vs. per-cgroup reclaim
> > and how much they interact together. 
> > 
> > The everything-in-groups approach with the "primary" service in the root
> > group (or call it unlimited) works just because all the memory activity
> > (but the primary service) is caped with the limits so the rest of the
> > memory can be used by the service. Moreover, in order this to work the
> > limit for other groups would be smaller then the working set of the
> > primary service.
> > 
> > Even if you created a limitless group for other important service they
> > would still interact together and if one goes wild the other would
> > suffer from that.
> > 
> 
> .........I can't understad what is the problem when global reclaim
> runs just because an application wasn't limited ...or memory are
> overcomitted.

I am not sure I understand but what I see as a problem is when unrelated
memory activity triggers reclaim and it pushes out the memory of a
process group just because the heuristics done by the reclaim algorithm
do not pick up the right memory - and honestly, no heuristic will fit
all requirements. Isolation can protect from an unrelated activity
without new heuristics.

[...]
> If softlimit (after some improvement) isn't enough, please add some other.
> 
> What I think of is
> 
> 1. need to "guarantee" memory usages in future.
>    "first come, first served" is not good for admins.

this is not in scope of these patchsets but I agree that it would be
nice to have this guarantee

> 2. need to handle zone memory shortage. Using memory migration
>    between zones will be necessary to avoid pageout.

I am not sure I understand.

> 
> 3. need a knob to say "please reclaim from my own cgroup rather than
>    affecting others (if usage > some(soft)limit)." 

Isn't this handled already and enhanced by the per-cgroup background
reclaim patches?

> 
> > [...]
> > > > > I think you should put tasks in root cgroup to somewhere. It works perfect
> > > > > against OOM. And if memory are hidden by isolation, OOM will happen easier.
> > > > 
> > > > Why do you think that it would happen easier? Isn't it similar (from OOM
> > > > POV) as if somebody mlocked that memory?
> > > > 
> > > 
> > > if global lru scan cannot find victim memory, oom happens.
> > 
> > Yes, but this will happen with mlocked memory as well, right?
> > 
> Yes, of course.
> 
> Anyway, I'll Nack to simple "first come, first served" isolation.
> Please implement garantee, which is reliable and admin can use safely.

Isolation is not about future guarantee. It is rather after you have it
you can rely it will stay in unless in-group activity pushes it out.

> mlock() has similar problem, So, I recommend hugetlbfs to customers,
> admin can schedule it at boot time.
> (the number of users of hugetlbfs is tend to be one app. (oracle))

What if we decide that hugetlbfs won't be pinned into memory in future?

> 
> I'll be absent, tomorrow.
> 
> I think you'll come LSF/MM summit and from the schedule, you'll have
> a joint session with Ying as "Memcg LRU management and isolation".

I didn't have plans to do a session actively, but I can certainly join
to talk and will be happy to discuss this topic.

> 
> IIUC, "LRU management" is a google's performance improvement topic.
> 
> It's ok for me to talk only about 'isolation'  1st in earlier session. 
> If you want, please ask James to move session and overlay 1st memory
> cgroup session. (I think you saw e-mail from James.)

Yeah, I can do that.

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
