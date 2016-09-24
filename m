Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7E556B028E
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 23:00:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cg13so236719200pac.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:00:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w9si10978204paa.82.2016.09.23.20.00.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 20:00:24 -0700 (PDT)
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160923081555.14645-1-mhocko@kernel.org>
	<201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
	<20160923150234.GV4478@dhcp22.suse.cz>
In-Reply-To: <20160923150234.GV4478@dhcp22.suse.cz>
Message-Id: <201609241200.AEE21807.OSOtQVOLHMFJFF@I-love.SAKURA.ne.jp>
Date: Sat, 24 Sep 2016 12:00:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 23-09-16 23:36:22, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  	else
> > >  		no_progress_loops++;
> > >  
> > > +	/* Make sure we know about allocations which stall for too long */
> > > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > 
> > Should we check !__GFP_NOWARN ? I think __GFP_NOWARN is likely used with
> > __GFP_NORETRY, and __GFP_NORETRY is already checked by now.
> > 
> > I think printing warning regardless of __GFP_NOWARN is better because
> > this check is similar to hungtask warning.
> 
> Well, if the user said to not warn we should really obey that. Why would
> that matter?

__GFP_NOWARN is defined as "Do not print failure messages when memory
allocation failed". It is not defined as "Do not print OOM killer messages
when OOM killer is invoked". It is undefined that "Do not print stall
messages when memory allocation is stalling".

If memory allocating threads were blocked on locks instead of doing direct
reclaim, hungtask will be able to find stalling memory allocations without
this change. Since direct reclaim prevents allocating threads from sleeping
for long enough to be warned by hungtask, it is important that this change
shall find allocating threads which cannot be warned by hungtask. That is,
not printing warning messages for __GFP_NOWARN allocation requests looses
the value of this change.

>  
> > > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> > > +				order, gfp_mask, &gfp_mask);
> > > +		stall_timeout += 10 * HZ;
> > > +		dump_stack();
> > 
> > Can we move this pr_warn() + dump_stack() to a separate function like
> > 
> > static void __warn_memalloc_stall(unsigned int order, gfp_t gfp_mask, unsigned long alloc_start)
> > {
> > 	pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > 		current->comm, jiffies_to_msecs(jiffies-alloc_start),
> > 		order, gfp_mask, &gfp_mask);
> > 	dump_stack();
> > }
> > 
> > in order to allow SystemTap scripts to perform additional actions by name (e.g.
> > 
> > # stap -g -e 'probe kernel.function("__warn_memalloc_stall").return { panic(); }
> 
> I find this reasoning and the use case really _absurd_, seriously! Pulling
> the warning into a separate function might be reasonable regardless,
> though. It matches warn_alloc_failed. Also if we find out we need some
> rate limitting or more checks it might just turn out being easier to
> follow rather than in the middle of an already complicated allocation
> slow path. I just do not like that the stall_timeout would have to stay
> in the original place or have it an in/out parameter.

SystemTap script shown above is just an example. What is nice is that
we can do whatever actions for examining what is going on by using a
function as if an interrupt handler. For example, when I was working at
support center, there was a support case where the customer's system always
reboots for unknown reason whenever specific action is taken. I inserted
SystemTap script shown above into a function which is called when a system
reboots, and I identified that the reason was SysRq-b which was triggered by
HA manager daemon due to misconfiguration. I used a reboot function as an
interrupt handler for examining why that handler was called. Likewise, we
can use __warn_memalloc_stall() as an interrupt handler for examining what
is going on. I think that there will be situations where existing printk()
does not provide enough information and thus examining a memory snapshot is
needed. Allowing tracing tools like SystemTap to insert a hook by function
name (instead of line number) is helpful anyway.

Going back to !(gfp_mask & __GFP_NOWARN) check, if you don't want to
print stall messages, you can move that check to inside
__warn_memalloc_stall(). Then, I can insert a SystemTap hook to print
stall messages for !(gfp_mask & __GFP_NOWARN) case. Even more, if you
are not sure what is best threshold, you can call a hook function every
second. The SystemTap script can check threshold and print warning if
necessary information are passed to that hook function. This resembles
LSM hooks. In the past, LSM hook was calling an empty function with
necessary information when LSM hook user (e.g. SELinux) is not registered.

> 
> > ) rather than by line number, and surround __warn_memalloc_stall() call with
> > mutex in order to serialize warning messages because it is possible that
> > multiple allocation requests are stalling?
> 
> we do not use any lock in warn_alloc_failed so why this should be any
> different?

warn_alloc_failed() is called for both __GFP_DIRECT_RECLAIM and
!__GFP_DIRECT_RECLAIM allocation requests, and it is not allowed
to sleep if !__GFP_DIRECT_RECLAIM. Thus, we have to tolerate that
concurrent memory allocation failure messages make dmesg output
unreadable. But __warn_memalloc_stall() is called for only
__GFP_DIRECT_RECLAIM allocation requests. Thus, we are allowed to
sleep in order to serialize concurrent memory allocation stall
messages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
