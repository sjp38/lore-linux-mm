Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 703186B0036
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 05:38:32 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so2104069eek.31
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:38:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si13714383eeo.58.2013.12.10.02.38.29
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 02:38:29 -0800 (PST)
Date: Tue, 10 Dec 2013 11:38:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131210103827.GB20242@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
 <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
 <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 09-12-13 13:46:16, David Rientjes wrote:
> On Mon, 9 Dec 2013, Michal Hocko wrote:
> 
> > > Google depends on getting memory.oom_control notifications only when they 
> > > are actionable, which is exactly how Documentation/cgroups/memory.txt 
> > > describes how userspace should respond to such a notification.
> > > 
> > > "Actionable" here means that the kernel has exhausted its capabilities of 
> > > allowing for future memory freeing, which is the entire premise of any oom 
> > > killer.
> > > 
> > > Giving a dying process or a process that is going to subsequently die 
> > > access to memory reserves is a capability the kernel users to ensure 
> > > progress is made in oom conditions.  It is not an exhaustion of 
> > > capabilities.
> > > 
> > > Yes, we all know that subsequent to the userspace notification that memory 
> > > may be freed and the kill no longer becomes required.  There is nothing 
> > > that can be done about that, and it has never been implied that a memcg is 
> > > guaranteed to still be oom when the process wakes up.
> > > 
> > > I'm referring to a siutation that can manifest in a number of ways: 
> > > coincidental process exit, coincidental process being killed, 
> > > VMPRESSURE_CRITICAL notification that results in a process being killed, 
> > > or memory threshold notification that results in a process being killed.  
> > > Regardless, we're talking about a situation where something is already 
> > > in the exit path or has been killed and is simply attempting to free its 
> > > memory.
> > 
> > You have already mentioned that. Several times in fact. And I do
> > understand what you are saying. You are just not backing your claims
> > with anything that would convince us that what you are trying to solve
> > is an issue in the real life. So show us it is real, please.
> > 
> 
> What exactly would you like to see?

How often do you see PF_EXITING tasks which haven't been killed causing
a pointless notification? Because fatal_signal_pending and TIF_MEMDIE
cases are already handled because we bypass charges in those cases (except
for user OOM killer killed tasks which don't get TIF_MEMDIE and that
should be fixed).

> It's obvious that the kernel has not 
> exhausted its capabilities of allowing for future memory freeing if the 
> notification happens before the check for current->flags & PF_EXITING or 
> fatal_signal_pending(current).  Does that conditional get triggered?  ALL 
> THE TIME.  We know it happens because I had to introduce it into both the 
> system oom killer and the memcg oom killer to fix mm->mmap_sem issues for 
> threads that were killed as part of the oom killer SIGKILL but weren't the 
> thread lucky enough to get TIF_MEMDIE set and they were in the allocation 
> path.

OOM killed task without TIF_MEMDIE is surely a problem. But the only
place I see this might happen right now is when a task is killed by
user space. And as I've said repeatedly this has to be fixed and it is
tangential to the notification problem your patch tries to handle but
not solve for other cases when we have notified but backout from killing
later.

> Are you asking me to patch our kernel, get it rolled out, and plot a graph 
> to show how often it gets triggered over time in our datacenters and that 
> it causes us to get unnecessary oom kill notifications?
> 
> I'm trying to support you in any way I can by giving you the information 
> you need, but in all honesty this seems pretty trivial and obvious to 
> understand.  I'm really quite stunned at this thread.  What exactly are 
> you arguing in the other direction for?  What does giving an oom 
> notification before allowing exiting processes to free its memory so the 
> memcg or system is no longer oom do?  Why can't you use memory thresholds 
> or vmpressure for such a situation?

David, I've tried to support you because I also think that notification
should be the last resort thing. But Johannes has a point that putting
this checks all over the place doesn't help longterm. So I would really
like to see a better justification than "it helps". 

> > > Such a process simply needs access to memory reserves to make progress and 
> > > free its memory as part of the exit path.  The process waiting on 
> > > memory.oom_control does _not_ need to do any of the actions mentioned in 
> > > Documentation/cgroups/memory.txt: reduce usage, enlarge the limit, kill a 
> > > process, or move a process with charge migration.
> > > 
> > > It would be ridiculous to require anybody implementing such a process to 
> > > check if the oom condition still exists after a period of time before 
> > > taking such an action.
> > 
> > Why would you consider that ridiculous? If your memcg is oom already
> > then waiting few seconds to let racing tasks finish doesn't sound that
> > bad to me.
> > 
> 
> A few seconds?  Is that just handwaving or are you making a guarantee that 
> all processes that need access to memory reserves will wake up, try its 
> allocation, get the memcg's oom lock, get access to memory reserves, 
> allocate, return to handle its pending SIGKILL, proceed down the exit() 
> path, and free its memory by then?
> 
> Meanwhile, the userspace oom handler is doing its little sleep(3) that you 
> suggest, it checks the status of the memcg, finds it's still oom, but 
> doesn't realize because it didn't do a second blocking read() that its a 
> second oom condition for a different process attached to the memcg and 
> that process simply needs memory reserves to exit.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
