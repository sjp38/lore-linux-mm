Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 16BD09000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 06:44:51 -0400 (EDT)
Date: Wed, 28 Sep 2011 12:44:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: thaw threads if oom killed thread is frozen before
 deferring
Message-ID: <20110928104445.GB15062@tiehlicka.suse.cz>
References: <cover.1317110948.git.mhocko@suse.cz>
 <65d9dff7ff78fad1f146e71d32f9f92741281b46.1317110948.git.mhocko@suse.cz>
 <alpine.DEB.2.00.1109271133590.17876@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109271133590.17876@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 27-09-11 11:35:04, David Rientjes wrote:
> On Tue, 27 Sep 2011, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 626303b..c419a7e 100644
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
> > @@ -451,10 +452,15 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  				task_pid_nr(q), q->comm);
> >  			task_unlock(q);
> >  			force_sig(SIGKILL, q);
> > +
> > +			if (frozen(q))
> > +				thaw_process(q);
> >  		}
> >  
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> >  	force_sig(SIGKILL, p);
> > +	if (frozen(p))
> > +		thaw_process(p);
> >  
> >  	return 0;
> >  }
> 
> Also needs this...
> 
> 
> oom: thaw threads if oom killed thread is frozen before deferring
> 
> If a thread has been oom killed and is frozen, thaw it before returning
> to the page allocator.  Otherwise, it can stay frozen indefinitely and
> no memory will be freed.

OK, I can see the race now:
oom_kill_task				refrigerator
  set_tsk_thread_flag(p, TIF_MEMDIE);
  force_sig(SIGKILL, p);
  if (frozen(p))
  	thaw_process(p)
					  frozen_process();
					  [...]
					  if (!frozen(current))
					  	break;
					  schedule();

select_bad_process
  [...]
  if (test_tsk_thread_flag(p, TIF_MEMDIE))
	  return ERR_PTR(-1UL);

So we either have to make sure that TIF_MEMDIE task is not frozen in
select_bad_process (your patch) or check for fatal_signal_pending
in refrigerator before we schedule and break out of the loop. Maybe the
later one is safer? Rafael?

Anyway this looks good. I guess it would be good to fold it into the
patch.

> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -318,8 +318,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		 * blocked waiting for another task which itself is waiting
>  		 * for memory. Is there a better alternative?
>  		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			if (unlikely(frozen(p)))
> +				thaw_process(p);
>  			return ERR_PTR(-1UL);
> +		}
>  		if (!p->mm)
>  			continue;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
