Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 7C4716B0085
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 02:37:31 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so967826pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 23:37:30 -0800 (PST)
Date: Wed, 14 Nov 2012 23:34:20 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
References: <20121107105348.GA25549@lizard>
 <20121107112136.GA31715@shutemov.name>
 <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com>
 <20121107114321.GA32265@shutemov.name>
 <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net>
 <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi David,

Thanks again for your inspirational comments!

On Wed, Nov 14, 2012 at 07:59:52PM -0800, David Rientjes wrote:
> > > I agree that eventfd is the way to go, but I'll also add that this feature 
> > > seems to be implemented at a far too coarse of level.  Memory, and hence 
> > > memory pressure, is constrained by several factors other than just the 
> > > amount of physical RAM which vmpressure_fd is addressing.  What about 
> > > memory pressure caused by cpusets or mempolicies?  (Memcg has its own 
> > > reclaim logic
> > 
> > Yes, sure, and my plan for per-cgroups vmpressure was to just add the same
> > hooks into cgroups reclaim logic (as far as I understand, we can use the
> > same scanned/reclaimed ratio + reclaimer priority to determine the
> > pressure).

[Answers reordered]

> Rather, I think it's much better to be notified when an individual process 
> invokes various levels of reclaim up to and including the oom killer so 
> that we know the context that memory freeing needs to happen (or, 
> optionally, the set of processes that could be sacrificed so that this 
> higher priority process may allocate memory).

I think I understand what you're saying, and surely it makes sense, but I
don't know how you see this implemented on the API level.

Getting struct {pid, pressure} pairs that cause the pressure at the
moment? And the monitor only gets <pids> that are in the same cpuset? How
about memcg limits?..

[...]
> > But we still want the "global vmpressure" thing, so that we could use it
> > without cgroups too. How to do it -- syscall or sysfs+eventfd doesn't
> > matter much (in the sense that I can do eventfd thing if you folks like it
> > :).
> > 
> 
> Most processes aren't going to care if they are running into memory 
> pressure and have no implementation to free memory back to the kernel or 
> start ratelimiting themselves.  They will just continue happily along 
> until they get the memory they want or they get oom killed.  The ones that 
> do, however, or a job scheduler or monitor that is watching over the 
> memory usage of a set of tasks, will be able to do something when 
> notified.

Yup, this is exactly how we want to use this. In Android we have "Activity
Manager" thing, which acts exactly how you describe: it's a tasks monitor.

> In the hopes of a single API that can do all this and not a 
> reimplementation for various types of memory limitations (it seems like 
> what you're suggesting is at least three different APIs: system-wide via 
> vmpressure_fd, memcg via memcg thresholds, and cpusets through an eventual 
> cpuset threshold), I'm hoping that we can have a single interface that can 
> be polled on to determine when individual processes are encountering 
> memory pressure.  And if I'm not running in your oom cpuset, I don't care 
> about your memory pressure.

I'm not sure to what exactly you are opposing. :) You don't want to have
three "kinds" pressures, or you don't what to have three different
interfaces to each of them, or both?

> I don't understand, how would this work with cpusets, for example, with 
> vmpressure_fd as defined?  The cpuset policy is embedded in the page 
> allocator and skips over zones that are not allowed when trying to find a 
> page of the specified order.  Imagine a cpuset bound to a single node that 
> is under severe memory pressure.  The reclaim logic will get triggered and 
> cause a notification on your fd when the rest of the system's nodes may 
> have tons of memory available.

Yes, I see your point: we have many ways to limit resources, so it makes
it hard to identify the cause of the "pressure" and thus how to deal with
it, since the pressure might be caused by different kinds of limits, and
freeing memory from one bucket doesn't mean that the memory will be
available to the process that is requesting the memory.

So we do want to know whether a specific cpuset is under pressure, whether
a specific memcg is under pressure, or whether the system (and kernel
itself) lacks memory.

And we want to have a single API for this? Heh. :)

The other idea might be this (I'm describing it in detail so that you
could actually comment on what exactly you don't like in this):

1. Obtain the fd via eventfd();

2. The fd can be passed to these files:

   I) Say /sys/kernel/mm/memory_pressure

      If we don't use cpusets/memcg or even have CGROUPS=n, this will be
      system's/global memory pressure. Pass the fd to this file and start
      polling.

      If we do use cpusets or memcg, the API will still work, but we have
      two options for its behaviour:

      a) This will only report the pressure when we're reclaiming with
         say (global_reclaim() && node_isset(zone_to_nid(zone),
         current->mems_allowed)) == 1. (Basically, we want to see pressure
         of kernel slabs allocations or any non-soft limits).

      or

      b) If 'filtering' cpusets/memcg seems too hard, we can say that
         these notifications are the "sum" of global+memcg+cpuset. It
         doesn't make sense to actually monitor these, though, so if the
         monitor is aware of cgroups, just 'goto II) and/or III)'.

   II) /sys/fs/cgroup/cpuset/.../cpuset.memory_pressure (yeah, we have
       it already)

      Pass the fd to this file to monitor per-cpuset pressure. So, if you
      get the pressure from here, it makes sense to free resources from
      this cpuset.

   III) /sys/fs/cgroup/memory/.../memory.pressure

      Pass the fd to this file to monitor per-memcg pressure. If you get
      the pressure from here, it only makes sense to free resources from
      this memcg.

3. The pressure level values (and their meaning) and the format of the
   files are the same, and this what defines the "API".

   So, if "memory monitor/supervisor app" is aware of cpusets, it manages
   memory at this level. If both cpuset and memcg is used, then it has to
   monitor both files, and act accordingly. And if we don't use
   cpusets/memcg (or even have cgroups=n), we can just watch the global
   reclaimer's pressure.

Do I understand correctly that you don't like this? Just to make sure. :)

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
