Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 702C69000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:14:45 -0400 (EDT)
Date: Mon, 26 Sep 2011 11:14:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
Message-ID: <20110926091440.GE10156@tiehlicka.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109260154510.1389@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Mon 26-09-11 01:56:57, David Rientjes wrote:
> On Mon, 26 Sep 2011, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 626303b..b9774f3 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -32,6 +32,7 @@
> >  #include <linux/mempolicy.h>
> >  #include <linux/security.h>
> >  #include <linux/ptrace.h>
> > +#include <linux/freezer.h>
> >  
> >  int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> > @@ -451,6 +452,9 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  				task_pid_nr(q), q->comm);
> >  			task_unlock(q);
> >  			force_sig(SIGKILL, q);
> > +
> > +			if (frozen(q))
> > +				thaw_process(q);
> >  		}
> >  
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> 
> This is in the wrong place, oom_kill_task() iterates over all threads that 
> are _not_ in the same thread group as the chosen thread and kills them 
> without giving them access to memory reserves.  The chosen task, p, could 
> still be frozen and may not exit.

Ahh, right you are. I ave missed that one. Updated patch bellow.

> 
> Once that's fixed, feel free to add my
> 
> 	Acked-by: David Rientjes <rientjes@google.com>

Thanks

> 
> once Rafael sends his acked-by or reviewed-by.
---
