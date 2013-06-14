Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A1F176B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 06:12:55 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id xb12so431230pbc.12
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 03:12:54 -0700 (PDT)
Date: Fri, 14 Jun 2013 03:12:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <51BA6A2A.3060107@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
References: <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com> <20130610142321.GE5138@dhcp22.suse.cz> <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com> <20130612202348.GA17282@dhcp22.suse.cz> <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
 <20130613151602.GG23070@dhcp22.suse.cz> <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com> <51BA6A2A.3060107@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 14 Jun 2013, Kamezawa Hiroyuki wrote:

> Reading your discussion, I think I understand your requirements.
> The problem is that I can't think you took into all options into
> accounts and found the best way is this new oom_delay. IOW, I can't
> convice oom-delay is the best way to handle your issue.
> 

Ok, let's talk about it.

> Your requeirement is
>  - Allowing userland oom-handler within local memcg.
> 

Another requirement:

 - Allow userland oom handler for global oom conditions.

Hopefully that's hooked into memcg because the functionality is already 
there, we can simply duplicate all of the oom functionality that we'll be 
adding for the root memcg.

> Considering straightforward, the answer should be
>  - Allowing oom-handler daemon out of memcg's control by its limit.
>    (For example, a flag/capability for a task can archive this.)
>    Or attaching some *fixed* resource to the task rather than cgroup.
> 
>    Allow to set task->secret_saving=20M.
> 

Exactly!

First of all, thanks very much for taking an interest in our usecase and 
discussing it with us.

I didn't propose what I referred to earlier in the thread as "memcg 
reserves" because I thought it was going to be a more difficult battle.  
The fact that you brought it up first actually makes me think it's less 
insane :)

We do indeed want memcg reserves and I have patches to add it if you'd 
like to see that first.  It ensures that this userspace oom handler can 
actually do some work in determining which process to kill.  The reserve 
is a fraction of true memory reserves (the space below the per-zone min 
watermarks) which is dependent on min_free_kbytes.  This does indeed 
become more difficult with true and complete kmem charging.  That "work" 
could be opening the tasks file (which allocates the pidlist within the 
kernel), checking /proc/pid/status for rss, checking for how long a 
process has been running, checking for tid, sending a signal to drop 
caches, etc.

We'd also like to do this for global oom conditions, which makes it even 
more interesting.  I was thinking of using a fraction of memory reserves 
as the oom killer currently does (that memory below the min watermark) for 
these purposes.

Memory charging is simply bypassed for these oom handlers (we only grant 
access to those waiting on the memory.oom_control eventfd) up to 
memory.limit_in_bytes + (min_free_kbytes / 4), for example.  I don't think 
this is entirely insane because these oom handlers should lead to future 
memory freeing, just like TIF_MEMDIE processes.

> Going back to your patch, what's confusing is your approach.
> Why the problem caused by the amount of memory should be solved by
> some dealy, i.e. the amount of time ?
> 
> This exchanging sounds confusing to me.
> 

Even with all of the above (which is not actually that invasive of a 
patch), I still think we need memory.oom_delay_millisecs.  I probably made 
a mistake in describing what that is addressing if it seems like it's 
trying to address any of the above.

If a userspace oom handler fails to respond even with access to those 
"memcg reserves", the kernel needs to kill within that memcg.  Do we do 
that above a set time period (this patch) or when the reserves are 
completely exhausted?  That's debatable, but if we are to allow it for 
global oom conditions as well then my opinion was to make it as safe as 
possible; today, we can't disable the global oom killer from userspace and 
I don't think we should ever allow it to be disabled.  I think we should 
allow userspace a reasonable amount of time to respond and then kill if it 
is exceeded.

For the global oom case, we want to have a priority-based memcg selection.  
Select the lowest priority top-level memcg and kill within it.  If it has 
an oom notifier, send it a signal to kill something.  If it fails to 
react, kill something after memory.oom_delay_millisecs has elapsed.  If 
there isn't a userspace oom notifier, kill something within that lowest 
priority memcg.

The bottomline with my approach is that I don't believe there is ever a 
reason for an oom memcg to remain oom indefinitely.  That's why I hate 
memory.oom_control == 1 and I think for the global notification it would 
be deemed a nonstarter since you couldn't even login to the machine.

> I'm not against what you finally want to do, but I don't like the fix.
> 

I'm thrilled to hear that, and I hope we can work to make userspace oom 
handling more effective.

What do you think about that above?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
