Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 67D9D6B0037
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 18:25:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bi5so8520726pad.32
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:25:58 -0700 (PDT)
Date: Thu, 13 Jun 2013 15:25:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130613151602.GG23070@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com>
References: <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com> <20130610142321.GE5138@dhcp22.suse.cz> <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com> <20130612202348.GA17282@dhcp22.suse.cz> <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
 <20130613151602.GG23070@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 13 Jun 2013, Michal Hocko wrote:

> > That's not at all the objective, the changelog quite explicitly states 
> > this is a deadlock as the result of userspace having disabled the oom 
> > killer so that its userspace oom handler can resolve the condition and it 
> > being unresponsive or unable to perform its job.
> 
> Ohh, so another round. Sigh. You insist on having user space handlers
> running in the context of the limited group. OK, I can understand your
> use case, although I think it is pushing the limits of the interface and
> it is dangerous.

Ok, this is where our misunderstanding is, and I can see why you have 
reacted the way you have.  It's my fault for not describing where we're 
going with this.

Userspace oom handling right now is very inadequate, not only for the 
reasons that you and Johannes have described.  This requirement that 
userspace oom handlers must run with more memory than the memcgs it is 
monitoring is where the pain is.

We have to accept the fact that users can be given control of their own 
memcg trees by chowning that "user root" directory to the user.  The only 
real change you must enforce is that the limit cannot be increased unless 
you have a special capability.  Otherwise, users can be given complete 
control over their own tree and enforce their own memory limits (or just 
accounting).

I haven't seen any objection to that usecase from anybody, so I'm assuming 
that it's something that is understood and acknowledged.  Nothing in the 
cgroups code prevents it and I believe it gives a much more powerful 
interface to the user to control their own destiny much like setting up 
root level memcgs for the admin.

The problem is that we want to control global oom conditions as well.  
oom_score_adj simply doesn't allow for user-specific implementations 
either within user subcontainers or at the root.  Users may very well want 
to kill the allocating task in their memcg to avoid expensive scans (SGI 
required oom_kill_allocating_task at a global level), kill the largest 
memory consumer, do a priority-based memcg scoring, kill the newest 
process, etc.  That's the power of user oom notifications beyond just 
statistics collection or creating a tombstone to examine later.

We want to do that at the root level as well for global oom conditions.  
We have a priority-based scoring method amongst top-level memcgs.  They 
are jobs that are scheduled on machines and given a certain priority to 
run at.  We also overcommit the machine so the sum of all top-level
memory.limit_in_bytes exceeds the amount of physical RAM since jobs seldom 
use their entire reservation.  When RAM is exhausted, we want to kill the 
lowest priority process from the lowest priority memcg.

That's not possible to do currently because we lack global oom 
notification and userspace oom handling.  We want to change that by 
notifying on the root memcg's memory.oom_control for global oom and wakeup 
a process that will handle global oom conditions.  Memcg is the perfect 
vehicle for this since it already does userspace oom notification and 
because the oom condition in a "user root" can be handled the same as a 
"global oom".

Waking up userspace and asking it to do anything useful in a global oom 
condition is problematic if it is unresponsive for whatever reason.  
Especially with true kmem accounting of all slab, we cannot be guaranteed 
that this global oom handler can actually do things like query the memory 
usage of a process or read a memcg's tasks file.  For this reason, we want 
a kernel failsafe to ensure that if it isn't able to respond in a 
reasonable amount of time, the kernel frees memory itself.

There's simply no other alternative to doing something like 
memory.oom_delay_millisecs then at the root level.  For notification to 
actually work, we need to preempt the kernel at least for a certain amount 
of time from killing: the solution right now is to disable the oom killer 
entirely with memory.oom_control == 1.  If the global oom handler fails 
the respond, the machine is essentially dead unless something starts 
freeing memory back for some strange reason.

For our own priority-based memcg oom scoring implementation, this global 
oom handler would then signal the memcg oom handler in the lowest priority 
memcg, if it exists, to handle the situation or it would kill something 
from that memcg itself.

The key is that without some sort of kernel-imposed delay, there's no way 
to sanely implement a global oom handler that doesn't risk killing the 
entire machine because the kernel oom killer is deferred.  This patch 
makes that delay configurable.

I could certainly push the patch that does the global oom notification on 
the root level memcg's memory.oom_control first if you'd like, but I 
didn't think there would be so much opposition to running a memcg oom 
handler in the memcg itself, which is what this essentially is.

If that's done, then we can't simply rely on the global oom killer, which 
your suggestion does when things go wrong or to act as a watchdog, to step 
in in such a situation and kill something.  We always want to kill from 
the lowest-priority memcg in global oom conditions and we don't expect to 
implement a multitude of different oom selection algorithms in the kernel.  
We want to punt to userspace and give it the functionality in the kernel 
that it needs when things go wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
