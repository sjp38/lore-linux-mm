Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9AA166B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:57:12 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2333145pad.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:57:11 -0800 (PST)
Date: Fri, 16 Nov 2012 13:57:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <50A6AC48.6080102@parallels.com>
Message-ID: <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Sat, 17 Nov 2012, Glauber Costa wrote:

> > I'm wondering if we should have more than three different levels.
> > 
> 
> In the case I outlined below, for backwards compatibility. What I
> actually mean is that memcg *currently* allows arbitrary notifications.
> One way to merge those, while moving to a saner 3-point notification, is
> to still allow the old writes and fit them in the closest bucket.
> 

Yeah, but I'm wondering why three is the right answer.

> > Umm, why do users of cpusets not want to be able to trigger memory 
> > pressure notifications?
> > 
> Because cpusets only deal with memory placement, not memory usage.

The set of nodes that a thread is allowed to allocate from may face memory 
pressure up to and including oom while the rest of the system may have a 
ton of free memory.  Your solution is to compile and mount memcg if you 
want notifications of memory pressure on those nodes.  Others in this 
thread have already said they don't want to rely on memcg for any of this 
and, as Anton showed, this can be tied directly into the VM without any 
help from memcg as it sits today.  So why implement a simple and clean 
mempressure cgroup that can be used alone or co-existing with either memcg 
or cpusets?

> And it is not that moving a task to cpuset disallows you to do any of
> this: you could, as long as the same set of tasks are mounted in a
> corresponding memcg.
> 

Same thing with a separate mempressure cgroup.  The point is that there 
will be users of this cgroup that do not want the overhead imposed by 
memcg (which is why it's disabled in defconfig) and there's no direct 
dependency that causes it to be a part of memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
