Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7650A9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:26:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 440AF3EE0C3
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:26:29 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2476F45DE60
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:26:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0114145DE5A
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:26:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E90851DB8056
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:26:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1317E18002
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:26:28 +0900 (JST)
Date: Mon, 26 Sep 2011 18:25:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
Message-Id: <20110926182536.9020bb5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110926091440.GE10156@tiehlicka.suse.cz>
References: <20110825151818.GA4003@redhat.com>
	<20110825164758.GB22564@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
	<20110826070946.GA7280@tiehlicka.suse.cz>
	<20110826085610.GA9083@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
	<20110826095356.GB9083@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
	<20110926082837.GC10156@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1109260154510.1389@chino.kir.corp.google.com>
	<20110926091440.GE10156@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Mon, 26 Sep 2011 11:14:40 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 26-09-11 01:56:57, David Rientjes wrote:
> > On Mon, 26 Sep 2011, Michal Hocko wrote:
> > 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 626303b..b9774f3 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -32,6 +32,7 @@
> > >  #include <linux/mempolicy.h>
> > >  #include <linux/security.h>
> > >  #include <linux/ptrace.h>
> > > +#include <linux/freezer.h>
> > >  
> > >  int sysctl_panic_on_oom;
> > >  int sysctl_oom_kill_allocating_task;
> > > @@ -451,6 +452,9 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> > >  				task_pid_nr(q), q->comm);
> > >  			task_unlock(q);
> > >  			force_sig(SIGKILL, q);
> > > +
> > > +			if (frozen(q))
> > > +				thaw_process(q);
> > >  		}
> > >  
> > >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > 
> > This is in the wrong place, oom_kill_task() iterates over all threads that 
> > are _not_ in the same thread group as the chosen thread and kills them 
> > without giving them access to memory reserves.  The chosen task, p, could 
> > still be frozen and may not exit.
> 
> Ahh, right you are. I ave missed that one. Updated patch bellow.
> 
> > 
> > Once that's fixed, feel free to add my
> > 
> > 	Acked-by: David Rientjes <rientjes@google.com>
> 
> Thanks
> 
> > 
> > once Rafael sends his acked-by or reviewed-by.
> ---
> From f935ed4558c2fb033ef5c14e02b28e12a615f80e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 16 Sep 2011 11:23:15 +0200
> Subject: [PATCH] oom: do not live lock on frozen tasks
> 
> Konstantin Khlebnikov has reported (https://lkml.org/lkml/2011/8/23/45)
> that OOM can end up in a live lock if select_bad_process picks up a frozen
> task.
> Unfortunately we cannot mark such processes as unkillable to ignore them
> because we could panic the system even though there is a chance that
> somebody could thaw the process so we can make a forward process (e.g. a
> process from another cpuset or with a different nodemask).
> 
> Let's thaw an OOM selected frozen process right after we've sent fatal
> signal from oom_kill_task.
> Thawing is safe if the frozen task doesn't access any suspended device
> (e.g. by ioctl) on the way out to the userspace where we handle the
> signal and die. Note, we are not interested in the kernel threads because
> they are not oom killable.
> 
> Accessing suspended devices by a userspace processes shouldn't be an
> issue because devices are suspended only after userspace is already
> frozen and oom is disabled at that time.
> 
> run_guest (drivers/lguest/core.c) calls try_to_freeze with an user
> context but it seems it is able to cope with signals because it
> explicitly checks for pending signals so we should be safe.
> 
> Other than that userspace accesses the fridge only from the
> signal handling routines so we are able to handle SIGKILL without any
> negative side effects.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
