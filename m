Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A0E1C8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 04:59:47 -0400 (EDT)
Date: Tue, 29 Mar 2011 10:59:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110329085942.GD30671@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328114430.GE5693@tiehlicka.suse.cz>
 <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz>
 <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-03-11 16:51:17, KAMEZAWA Hiroyuki wrote:
> On Tue, 29 Mar 2011 09:32:32 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 29-03-11 09:09:24, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 28 Mar 2011 13:44:30 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > On Mon 28-03-11 20:03:32, KAMEZAWA Hiroyuki wrote:
> > > > > On Mon, 28 Mar 2011 11:39:57 +0200
> > > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > [...]
> > > > > 
> > > > > Isn't it the same result with the case where no cgroup is used ?
> > > > 
> > > > Yes and that is the point of the patchset. Memory cgroups will not give
> > > > you anything else but the top limit wrt. to the global memory activity.
> > > > 
> > > > > What is the problem ?
> > > > 
> > > > That we cannot prevent from paging out memory of process(es), even though
> > > > we have intentionaly isolated them in a group (read as we do not have
> > > > any other possibility for the isolation), because of unrelated memory
> > > > activity.
> > > > 
> > > Because the design of memory cgroup is not for "defending" but for 
> > > "never attack some other guys".
> > 
> > Yes, I am aware of the current state of implementation. But as the
> > patchset show there is not quite trivial to implement also the other
> > (defending) part.
> > 
> 
> My opinions is to enhance softlimit is better.

I will look how softlimit can be enhanced to match the expectations but
I'm kind of suspicious it can handle workloads where heuristics simply
cannot guess that the resident memory is important even though it wasn't
touched for a long time.

> > > > > Why it's not a problem of configuration ?
> > > > > IIUC, you can put all logins to some cgroup by using cgroupd/libgcgroup.
> > > > 
> > > > Yes, but this still doesn't bring the isolation.
> > > > 
> > > 
> > > Please explain this more.
> > > Why don't you move all tasks under /root/default <- this has some limit ?
> > 
> > OK, I have tried to explain that in one of the (2nd) patch description.
> > If I move all task from the root group to other group(s) and keep the
> > primary application in the root group I would achieve some isolation as
> > well. That is very much true. 
> 
> Okay, then, current works well.
> 
> > But then there is only one such a group.
> 
> I can't catch what you mean. you can create limitless cgroup, anywhere.
> Can't you ?

This is not about limits. This is about global vs. per-cgroup reclaim
and how much they interact together. 

The everything-in-groups approach with the "primary" service in the root
group (or call it unlimited) works just because all the memory activity
(but the primary service) is caped with the limits so the rest of the
memory can be used by the service. Moreover, in order this to work the
limit for other groups would be smaller then the working set of the
primary service.

Even if you created a limitless group for other important service they
would still interact together and if one goes wild the other would
suffer from that.

But, well, I might be wrong at this, I will play with it so see how it
works.

[...]
> > > Yes, then, almost all mm guys answer has been "please use mlock".
> > 
> > Yes. As I already tried to explain, mlock is not the remedy all the
> > time. It gets very tricky when you balance on the edge of the limit of
> > the available memory resp. cgroup limit. Sometimes you rather want to
> > have something swapped out than being killed (or fail due to ENOMEM).
> > The important thing about swapped out above is that with the isolation
> > it is only per-cgroup.
> > 
> 
> IMHO, doing isolation by hiding is not good idea. 

It depends on what you want to guarantee.

> Because we're kernel engineer, we should do isolation by
> scheduling. The kernel is art of shceduling, not separation.

Well, I would disagree with this statement (to some extend of course).
Cgroups are quite often used for separation (e.g. cpusets basically
hide tasks from CPUs that are not configured for them).

You are certainly right that the memory management is about proper
scheduling and balancing needs vs. demands. And it turned out to be
working fine in many (maybe even most of) workloads (modulo bugs
which are fixed over time). But if an application has more specific
requirements for its memory usage then it is quite limited in ways how
it can achieve them (mlock is one way how to pin the memory but there
are cases where it is not appropriate).
Kernel will simply never know the complete picture and have to rely on
heuristics which will never fit in with everybody.


> I think we should start from some scheduling as softlimit. Then,
> as an extreme case of scheduling, 'complete isolation' should be
> archived. If it seems impossible after trial of making softlimit
> better, okay, we should consider some.

As I already tried to point out what-ever will scheduling do it has no
way to guess that somebody needs to be isolated unless he says that to
kernel.
Anyway, I will have a look whether softlimit can be used and how helpful
it would be.

[...]
> > > I think you should put tasks in root cgroup to somewhere. It works perfect
> > > against OOM. And if memory are hidden by isolation, OOM will happen easier.
> > 
> > Why do you think that it would happen easier? Isn't it similar (from OOM
> > POV) as if somebody mlocked that memory?
> > 
> 
> if global lru scan cannot find victim memory, oom happens.

Yes, but this will happen with mlocked memory as well, right?

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
