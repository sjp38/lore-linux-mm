Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C367E6B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 23:13:11 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o883D8ZY018890
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:13:08 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by hpaq1.eem.corp.google.com with ESMTP id o883D6iG020192
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:13:07 -0700
Received: by pwj6 with SMTP id 6so3285439pwj.0
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 20:13:06 -0700 (PDT)
Date: Tue, 7 Sep 2010 20:12:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100907112756.C904.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009071954080.4790@chino.kir.corp.google.com>
References: <20100830113007.525A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011436390.29305@chino.kir.corp.google.com> <20100907112756.C904.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, KOSAKI Motohiro wrote:

> Of cource, there is simply just zero justification. Who ask google usage?
> Every developer have their own debugging and machine administate patches.
> Don't you concern why we don't push them into upstream? only one usage is
> not good reason to make kernel bloat. Need to generalize.
> 

/proc/pid/oom_adj was introduced before cpusets or memcg, so we were 
dealing with a static amount of system resources that would not change out 
from underneath an application.  Although that's not a defense of using a 
bitshift on a heuristic that included many arbitrary selections, it was 
reasonable to make it only a scalar that didn't consider the amount of 
resources that an application was allowed to access.

As time moved on, cgroups such as cpusets and memcg were introduced (and 
mempolicies became much more popular as larger NUMA machines became more 
popular in the industry) that bound or restricted the amount of memory 
that an aggregate of tasks could access.  Each of those methods may change 
the amount of memory resources that an application has available to it at 
any time without knowledge of that application, job scheduler, or system 
daemon.  Therefore, it's important to define a more powerful oom_adj 
mechanism that can properly attribute the oom killing priority of a task 
in comparison to others that are bound to the same resources without 
causing a regression on users who don't use those mechanisms that allow 
that working set size to be dynamic.  That's what oom_score_adj does.

> > We are certainly looking forward to using this when 2.6.36 is released 
> > since we work with both cpusets and memcg.
> 
> Could you please be serious? We are not making a sand castle, we are making
> a kernel. You have to understand the difference of them. Zero user feature
> trial don't have any good reason to make userland breakage.
> 

With respect to memory isolation and the oom killer, we want to follow the 
upstream behavior as much as possible.  We are looking forward to this 
interface being available in 2.6.36 and will begin to actively use it once 
it is released.  So although there is no existing user today, there will 
be when 2.6.36 is released.  I also hope that other users of cpusets or 
memcg will find it helpful to define oom killing priority with a unit 
rather than a bitshift and that understands the dynamic nature of resource 
isolation that they both imply.

> > Basically, it comes down to this: few users actually tune their oom 
> > killing priority, period.  That's partly because they accept the oom 
> > killer's heuristics to kill a memory-hogging task or use panic_on_oom, or 
> > because the old interface, /proc/pid/oom_adj, had no unit and no logical 
> > way of using it other than polarizing it (either +15 or -17).
> 
> Unrelated. We already have oom notifier. we have no reason to add new knob
> even though oom_adj is suck. We are not necessary to break userland application.
> 

There is no generic oom notifier solution other than what is implemented 
in the memory controller, and that comes at a cost of roughly 1% of system 
RAM since that's the amount of metadata that the memcg requires.  
oom_score_adj works for cpusets, memcg, and mempolicies.

Now you may insist that the fact that very few users actually use 
/proc/pid/oom_adj for _anything_ other than -17, -15 or +15 is unrelated, 
but in fact it provides a very nice context for your objections that it 
introduces all sorts of regressions and bugs that will break everybody's 
system.  Show me a single example of an application that tunes its oom_adj 
value based on any formula whatsoever that includes its own anticipated 
RAM usage or system capacity (which is required to make the bitshift make 
any sense).

> More importantly, We already have oom notifier. and It is most powerful
> infrastructure. It can be constructed any oom policy freely. It's not 
> restricted kernel implementaion.
> 

A generic oom notifier would be very nice to have in the kernel that 
isn't dependent on memory controller.  Unfortunately, many users cannot 
incur the 1% of memory penalty that it comes with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
