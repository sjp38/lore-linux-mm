Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 002E66B0095
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:11:49 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so615849dad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 00:11:49 -0800 (PST)
Date: Thu, 15 Nov 2012 00:11:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
Message-ID: <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, 14 Nov 2012, Anton Vorontsov wrote:

> Thanks again for your inspirational comments!
> 

Heh, not sure I've been too inspirational (probably more annoying than 
anything else).  I really do want generic memory pressure notifications in 
the kernel and already have some ideas on how I can tie it into our malloc 
arenas, so please do keep working on it.

> I think I understand what you're saying, and surely it makes sense, but I
> don't know how you see this implemented on the API level.
> 
> Getting struct {pid, pressure} pairs that cause the pressure at the
> moment? And the monitor only gets <pids> that are in the same cpuset? How
> about memcg limits?..
> 

Depends on whether you want to support mempolicies or not and the argument 
could go either way:

 - FOR supporting mempolicies: memory that you're mbind() too can become 
   depleted and since there is no fallback then you have no way to prevent 
   lots of reclaim and/or invoking the oom killer, it would be 
   disappointing to not be able to get notifications of such a condition.

 - AGAINST supporting mempolicies: you only need to support memory 
   isolation for cgroups (memcg and cpusets) and thus can implement your 
   own memory pressure cgroup that you can use to aggregate tasks and 
   then replace memcg memory thresholds with co-mounting this new cgroup 
   that would notify on an eventfd anytime one of the attached processes 
   experiences memory pressure.

> > Most processes aren't going to care if they are running into memory 
> > pressure and have no implementation to free memory back to the kernel or 
> > start ratelimiting themselves.  They will just continue happily along 
> > until they get the memory they want or they get oom killed.  The ones that 
> > do, however, or a job scheduler or monitor that is watching over the 
> > memory usage of a set of tasks, will be able to do something when 
> > notified.
> 
> Yup, this is exactly how we want to use this. In Android we have "Activity
> Manager" thing, which acts exactly how you describe: it's a tasks monitor.
> 

In addition to that, I think I can hook into our implementation of malloc 
which frees memory back to the kernel with MADV_DONTNEED and zaps 
individual ptes to poke holes in the memory it allocates to actually cache 
the memory that we free() and then re-use it under normal circumstances to 
return cache-hot memory on the next allocation but under memory pressure, 
as triggered by your interface (but for threads attached to a memcg facing 
memcg limits), drain the memory back to the kernel immediately.

> > In the hopes of a single API that can do all this and not a 
> > reimplementation for various types of memory limitations (it seems like 
> > what you're suggesting is at least three different APIs: system-wide via 
> > vmpressure_fd, memcg via memcg thresholds, and cpusets through an eventual 
> > cpuset threshold), I'm hoping that we can have a single interface that can 
> > be polled on to determine when individual processes are encountering 
> > memory pressure.  And if I'm not running in your oom cpuset, I don't care 
> > about your memory pressure.
> 
> I'm not sure to what exactly you are opposing. :) You don't want to have
> three "kinds" pressures, or you don't what to have three different
> interfaces to each of them, or both?
> 

The three pressures are a separate topic (I think it would be better to 
have some measure of memory pressure similar to your reclaim scale and 
allow users to get notifications at levels they define).  I really dislike 
having multiple interfaces that are all different from one another 
depending on the context.

Given what we have right now with memory thresholds in memcg, if we were 
to merge vmpressure_fd, then we're significantly limiting the usecase 
since applications need not know if they are attached to a memcg or not: 
it's a type of virtualization that the admin may setup but another admin 
may be running unconstrained on a system with much more memory.  So for 
your usecase of a job monitor, that would work fine for global oom 
conditions but the application no longer has an API to use if it wants to 
know when it itself is feeling memory pressure.

I think others have voiced their opinion on trying to create a single API 
for memory pressure notifications as well, it's just a hard problem and 
takes a lot of work to determine how we can make it easy to use and 
understand and extendable at the same time.

> > I don't understand, how would this work with cpusets, for example, with 
> > vmpressure_fd as defined?  The cpuset policy is embedded in the page 
> > allocator and skips over zones that are not allowed when trying to find a 
> > page of the specified order.  Imagine a cpuset bound to a single node that 
> > is under severe memory pressure.  The reclaim logic will get triggered and 
> > cause a notification on your fd when the rest of the system's nodes may 
> > have tons of memory available.
> 
> Yes, I see your point: we have many ways to limit resources, so it makes
> it hard to identify the cause of the "pressure" and thus how to deal with
> it, since the pressure might be caused by different kinds of limits, and
> freeing memory from one bucket doesn't mean that the memory will be
> available to the process that is requesting the memory.
> 
> So we do want to know whether a specific cpuset is under pressure, whether
> a specific memcg is under pressure, or whether the system (and kernel
> itself) lacks memory.
> 
> And we want to have a single API for this? Heh. :)
> 

Might not be too difficult if you implement your own cgroup to aggregate 
these tasks for which you want to know memory pressure events; it would 
have to be triggered for the task trying to allocate memory at any given 
time and how hard it was to allocate that memory in the slowpath, tie it 
back to that tasks' memory pressure cgroup, and then report the trigger if 
it's over a user-defined threshold normalized to the 0-100 scale.  Then 
you could co-mount this cgroup with memcg, cpusets, or just do it for the 
root cgroup for users who want to monitor the entire system 
(CONFIG_CGROUPS is enabled by default).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
