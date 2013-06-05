Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 11EB96B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 02:40:19 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w16so1373376pde.37
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 23:40:19 -0700 (PDT)
Date: Tue, 4 Jun 2013 23:40:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130604095514.GC31242@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com>
References: <20130530150539.GA18155@dhcp22.suse.cz> <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com> <20130531081052.GA32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com> <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com> <20130601102058.GA19474@dhcp22.suse.cz> <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com> <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
 <20130604095514.GC31242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 4 Jun 2013, Michal Hocko wrote:

> > I'm not sure a userspace oom notifier would want to keep a
> > preallocated buffer around that is mlocked in memory for all possible
> > lengths of this file.
> 
> Well, an oom handler which allocates memory under the same restricted
> memory doesn't make much sense to me. Tracking all kmem allocations
> makes it almost impossible to implement a non-trivial handler.
> 

This isn't only about oom notifiers that reside in the same oom memcg, 
they can be at a higher level or a different subtree entirely.  The point 
is that they can be unresponsive either because userspace is flaky, its 
oom itself, or we do track all slab.  The kernel is the only thing in the 
position to fix the issue after a sensible user-defined amount of time has 
elapsed, and that's what this patch is.

> OK, maybe I just wasn't clear enough or I am missing your point. Your
> users _can_ implement and register their oom handlers. But as your
> requirements are rather benevolent for handlers implementation you would
> have a global watchdog which would sit on the oom_control of those
> groups (which are allowed to have own handlers - all of them in your
> case I guess) and trigger (user defined/global) timeout when it gets a
> notification. If the group was under oom always during the timeout then
> just disable oom_control until oom is settled (under_oom is 0).
> 
> Why wouldn't something like this work for your use case?
> 

For the aforementioned reason that we give users the ability to manipulate 
their own memcg trees and userspace is untrusted.  Their oom notifiers 
cannot be run as root, not only because of security but also because it 
would not properly isolate their memory usage to their memcg tree.

> Hohmm, so you are insisting on something that can be implemented in the
> userspace and put it into the kernel because it is more convenient for
> you and your use case. This doesn't sound like a way for accepting a
> feature.
> 

I don't think you yet understand the problem, which is probably my fault.  
I'm not insisting this be implemented in the kernel, I'm saying it's not 
possible to do it in userspace.  Your idea of a timeout implemented in 
userspace doesn't work in practice: userspace is both untrusted and cannot 
be guaranteed to be perfect and always wakeup, get the information it does 
according to its implementation, and issue a SIGKILL.

This is the result of memcg allowing users to disable the oom killer 
entirely for a memcg, which is still ridiculous, because if the user 
doesn't respond then you've wasted all that memory and cannot get it back 
without admin intervention or a reboot.  There are no other "features" in 
the kernel that put such a responsibility on a userspace process such that 
if it doesn't work then the entire memcg deadlocks forever without admin 
intervention.  We need a failsafe in the kernel.

Real users like this cannot run as root, and we cannot run in the root 
memcg without charging that memory usage to the user's container for that 
share of a global resource.  Real users do have to tollerate buggy and 
flaky userspace implementations that cannot be guaranteed to run or do 
what they are supposed to do.  It's too costly of a problem to not address 
with a failsafe.  I speak strictly from experience on this.

> And yes we should make memcg oom handling less deadlock prone and
> Johannes' work in this thread is a good step forward.

The long-term solution to that, which I already have patches for, is 
something you would cringe even more at: memcg memory reserves that are 
shared with per-zone memory reserves that get the global oom killer to 
kill off that process without notification in the case the memcg memory 
reserves cause a global oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
