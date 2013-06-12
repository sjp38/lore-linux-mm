Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 0D4E86B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 16:23:53 -0400 (EDT)
Received: by mail-ea0-f179.google.com with SMTP id b15so6054953eae.24
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 13:23:52 -0700 (PDT)
Date: Wed, 12 Jun 2013 22:23:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130612202348.GA17282@dhcp22.suse.cz>
References: <20130601102058.GA19474@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com>
 <20130603193147.GC23659@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
 <20130604095514.GC31242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com>
 <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
 <20130610142321.GE5138@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 11-06-13 13:33:40, David Rientjes wrote:
> On Mon, 10 Jun 2013, Michal Hocko wrote:
[...]
> > Your only objection against userspace handling so far was that admin
> > has no control over sub-hierarchies. But that is hardly a problem. A
> > periodic tree scan would solve this easily (just to make sure we are on
> > the same page - this is still the global watchdog living in a trusted
> > root cgroup which is marked as unkillable for the global oom).
> > 
> 
> There's no way a "periodic tree scan" would solve this easily, it's 
> completely racy and leaves the possibility of missing oom events when they 
> happen in a new memcg before the next tree scan.

But the objective is to handle oom deadlocks gracefully and you cannot
possibly miss those as they are, well, _deadlocks_. So while the
watchdog might really miss some oom events which have been already
handled that is absolutely not important here. Please note that the
eventfd is notified also during registration if the group is under oom
already. So you cannot miss a deadlocked group.

> Not only that, but what happens when the entire machine is oom?

Then a memcg deadlock is irrelevant, isn't it? Deadlocked tasks are
sitting in the KILLABLE queue so they can be killed. And you can protect
the watchdog from being killed.

> The global watchdog can't allocate any memory to handle the event, yet
> it is supposed to always be doing entire memcg tree scans, registering
> oom handlers, and handling wakeups when notified?

So what? The global OOM will find a victim and the life goes on. I do
not think that the watchdog consumption would be negligible (simple
queue for timers, eventfd stuff for each existing group, few threads).

> How does this "global watchdog" know when to stop the timer?  In the 
> kernel that would happen if the user expands the memcg limit or there's an 
> uncharge to the memcg.  

Then the group won't be marked under_oom in memory.oom_control at the
time when timeout triggers so the watchdog knows that the oom has been
handled already and it can be discarded.

> The global watchdog stores the limit at the time of oom and compares  
> it before killing something?

Why it would need to check the limit? It cares only about the oom
events.

> How many memcgs do we have to store this value for without allocating
> memory in a global oom condition?  You expect us to run with all this
> memory mlocked in memory forever?

No, the only thing that the watchdog has to care about is memory.oom_control.

> How does the global watchdog know that there was an uncharge and then a 
> charge in the memcg so it is still oom?

It will get a new event for every new oom.

> This would reset the timer in the kernel but not in userspace and may
> result in unnecessary killing.

User space watchdog would do the same thing. When it receives an event
it will enqueue or requeue the corresponding timer.

> If the timeout is 10s, the memcg is
> oom for 9s, uncharges, recharges, and the global watchdog checks at
> 10s that it is still oom, we don't want the kill because we do get
> uncharge events.
>
> This idea for a global watchdog just doesn't work.

I am not convinced about that. Maybe I am missing some aspect but all
problems you have mentioned are _solvable_.
 
[...]
> > David, maybe I am still missing something but it seems to me that the
> > in-kernel timeout is not necessary because the user-space variant is not
> > that hard to implement and I really do not want to add new knobs for
> > something that can live outside.
> 
> It's vitally necessary and unless you answer the questions I've asked 
> about your proposed "global watchdog" that exists only in your theory then 

Which questions are still not answered?

> we'll just continue to have this circular argument.  You cannot implement 
> a userspace variant that works this way and insisting that you can is 
> ridiculous.  These are problems that real users face and we insist on the 
> problem being addressed.

Your use case pushes the interface to extreme, to be honest. You are
proposing a new knob that would have to be supported for ever. I feel
that we should be careful and prefer user space solution if there is
any.

To be clear, I am not nacking this patch and I will not ack it either.
If Johannes, Kamezawa or Andrew are OK with it I will not block it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
