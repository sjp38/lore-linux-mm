Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6847E6B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 17:53:22 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3175936pad.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 14:53:21 -0800 (PST)
Date: Sun, 18 Nov 2012 14:53:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <20121117012114.GA22910@lizard.sbx05663.mountca.wayport.net>
Message-ID: <alpine.DEB.2.00.1211181446090.5080@chino.kir.corp.google.com>
References: <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com> <20121117012114.GA22910@lizard.sbx05663.mountca.wayport.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Glauber Costa <glommer@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri, 16 Nov 2012, Anton Vorontsov wrote:

>  The main change is that I decided to go with discrete levels of the
>  pressure.
> 
>  When I started writing the man page, I had to describe the 'reclaimer
>  inefficiency index', and while doing this I realized that I'm describing
>  how the kernel is doing the memory management, which we try to avoid in
>  the vmevent. And applications don't really care about these details:
>  reclaimers, its inefficiency indexes, scanning window sizes, priority
>  levels, etc. -- it's all "not interesting", and purely kernel's stuff. So
>  I guess Mel Gorman was right, we need some sort of levels.
> 
>  What applications (well, activity managers) are really interested in is
>  this:
> 
>  1. Do we we sacrifice resources for new memory allocations (e.g. files
>     cache)?
>  2. Does the new memory allocations' cost becomes too high, and the system
>     hurts because of this?
>  3. Are we about to OOM soon?
> 
>  And here are the answers:
> 
>  1. VMEVENT_PRESSURE_LOW
>  2. VMEVENT_PRESSURE_MED
>  3. VMEVENT_PRESSURE_OOM
> 
>  There is no "high" pressure, since I really don't see any definition of
>  it, but it's possible to introduce new levels without breaking ABI.
> 
> Later I came up with the fourth level:
> 
>  Maybe it makes sense to implement something like PRESSURE_MILD/BALANCE
>  with an additional nr_pages threshold, which basically hits the kernel
>  about how many easily reclaimable pages userland has (that would be a
>  part of our definition for the mild/balance pressure level).
> 
> I.e. the fourth level can serve as a two-way communication w/ the kernel.
> But again, this would be just an extension, I don't want to introduce this
> now.
> 

That certainly makes sense, it would be too much of a usage and 
maintenance burden to assume that the implementation of the VM is to 
remain the same.

> > The set of nodes that a thread is allowed to allocate from may face memory 
> > pressure up to and including oom while the rest of the system may have a 
> > ton of free memory.  Your solution is to compile and mount memcg if you 
> > want notifications of memory pressure on those nodes.  Others in this 
> > thread have already said they don't want to rely on memcg for any of this 
> > and, as Anton showed, this can be tied directly into the VM without any 
> > help from memcg as it sits today.  So why implement a simple and clean 
> 
> You meant 'why not'?
> 

Yes, sorry.

> > mempressure cgroup that can be used alone or co-existing with either memcg 
> > or cpusets?
> > 
> > Same thing with a separate mempressure cgroup.  The point is that there 
> > will be users of this cgroup that do not want the overhead imposed by 
> > memcg (which is why it's disabled in defconfig) and there's no direct 
> > dependency that causes it to be a part of memcg.
> 
> There's also an API "inconvenince issue" with memcg's usage_in_bytes
> stuff: applications have a hard time resetting the threshold to 'emulate'
> the pressure notifications, and they also have to count bytes (like 'total
> - used = free') to set the threshold. While a separate 'pressure'
> notifications shows exactly what apps actually want to know: the pressure.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
