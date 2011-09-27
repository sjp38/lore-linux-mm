Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3F80D9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:52:50 -0400 (EDT)
Date: Tue, 27 Sep 2011 09:52:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
Message-ID: <20110927075245.GA25807@tiehlicka.suse.cz>
References: <20110825151818.GA4003@redhat.com>
 <alpine.DEB.2.00.1109260154510.1389@chino.kir.corp.google.com>
 <20110926091440.GE10156@tiehlicka.suse.cz>
 <201109261751.40688.rjw@sisk.pl>
 <alpine.DEB.2.00.1109261801150.8510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109261801150.8510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Mon 26-09-11 18:03:26, David Rientjes wrote:
> On Mon, 26 Sep 2011, Rafael J. Wysocki wrote:
> 
> > > Konstantin Khlebnikov has reported (https://lkml.org/lkml/2011/8/23/45)
> > > that OOM can end up in a live lock if select_bad_process picks up a frozen
> > > task.
> > > Unfortunately we cannot mark such processes as unkillable to ignore them
> > > because we could panic the system even though there is a chance that
> > > somebody could thaw the process so we can make a forward process (e.g. a
> > > process from another cpuset or with a different nodemask).
> > > 
> > > Let's thaw an OOM selected frozen process right after we've sent fatal
> > > signal from oom_kill_task.
> > > Thawing is safe if the frozen task doesn't access any suspended device
> > > (e.g. by ioctl) on the way out to the userspace where we handle the
> > > signal and die. Note, we are not interested in the kernel threads because
> > > they are not oom killable.
> > > 
> > > Accessing suspended devices by a userspace processes shouldn't be an
> > > issue because devices are suspended only after userspace is already
> > > frozen and oom is disabled at that time.
> > > 
> > > run_guest (drivers/lguest/core.c) calls try_to_freeze with an user
> > > context but it seems it is able to cope with signals because it
> > > explicitly checks for pending signals so we should be safe.
> > > 
> > > Other than that userspace accesses the fridge only from the
> > > signal handling routines so we are able to handle SIGKILL without any
> > > negative side effects.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > 
> > Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
> > 
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks!

> 
> Although this still seems to be problematic if the chosen thread gets 
> frozen before the SIGKILL can be handled.  We don't have any checks for 
> fatal_signal_pending() when freezing threads and waiting for them to exit?

I guess you mean a situation when select_bad_process picks up a process
which is not marked as frozen yet but we send SIGKILL right before
schedule is called in refrigerator. 
In that case either schedule should catch it by signal_pending_state
check or we will pick it up next OOM round when we pick up the same
process (if nothing else is eligible). Or am I missing something?
 
> Michal, could you send Andrew your revised patch with all the acked-bys?

Yes I will. I would just like to hear back from Konstantin who
originally reported the issue. Maybe he has a test case.

> 
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
