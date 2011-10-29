Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BBF106B002D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2011 04:52:16 -0400 (EDT)
Date: Sat, 29 Oct 2011 10:52:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + oom-do-not-live-lock-on-frozen-tasks.patch added to -mm tree
Message-ID: <20111029085209.GA6203@tiehlicka.suse.cz>
References: <201110282223.p9SMNl50018144@hpaq3.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201110282223.p9SMNl50018144@hpaq3.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, khlebnikov@openvz.org, rientjes@google.com, rjw@sisk.pl, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 28-10-11 15:23:47, Andrew Morton wrote:
> From: Michal Hocko <mhocko@suse.cz>
> Subject: oom: do not live lock on frozen tasks
> 
> Konstantin Khlebnikov has reported (https://lkml.org/lkml/2011/8/23/45)
> that OOM can end up in a live lock if select_bad_process picks up a frozen
> task.
> 
> Unfortunately we cannot mark such processes as unkillable to ignore them
> because we could panic the system even though there is a chance that
> somebody could thaw the process so we can make a forward process (e.g. a
> process from another cpuset or with a different nodemask).
> 
> Let's thaw an OOM selected frozen process right after we've sent fatal
> signal from oom_kill_task.
> 
> Thawing is safe if the frozen task doesn't access any suspended device
> (e.g.  by ioctl) on the way out to the userspace where we handle the
> signal and die.  Note, we are not interested in the kernel threads because
> they are not oom killable.
> 
> Accessing suspended devices by a userspace processes shouldn't be an issue
> because devices are suspended only after userspace is already frozen and
> oom is disabled at that time.
> 
> Other than that userspace accesses the fridge only from the signal
> handling routines so we are able to handle SIGKILL without any negative
> side effects or we always check for pending signals after we return from
> try_to_freeze (e.g.  in lguest).

The patch is not needed after we have
oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch
which is already in the -mm tree
(http://permalink.gmane.org/gmane.linux.kernel.mm/69138, the whole email
thread started here:
http://comments.gmane.org/gmane.linux.kernel.mm/69003). 

So you can drop this one.

> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/oom_kill.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff -puN mm/oom_kill.c~oom-do-not-live-lock-on-frozen-tasks mm/oom_kill.c
> --- a/mm/oom_kill.c~oom-do-not-live-lock-on-frozen-tasks
> +++ a/mm/oom_kill.c
> @@ -462,10 +462,15 @@ static int oom_kill_task(struct task_str
>  				task_pid_nr(q), q->comm);
>  			task_unlock(q);
>  			force_sig(SIGKILL, q);
> +
> +			if (frozen(q))
> +				thaw_process(q);
>  		}
>  
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
>  	force_sig(SIGKILL, p);
> +	if (frozen(p))
> +		thaw_process(p);
>  
>  	return 0;
>  }
> _
> Subject: Subject: oom: do not live lock on frozen tasks
> 
> Patches currently in -mm which might be from mhocko@suse.cz are
> 
> origin.patch
> linux-next.patch
> mm-compaction-trivial-clean-up-in-acct_isolated.patch
> mm-change-isolate-mode-from-define-to-bitwise-type.patch
> mm-compaction-make-isolate_lru_page-filter-aware.patch
> mm-compaction-make-isolate_lru_page-filter-aware-fix.patch
> mm-zone_reclaim-make-isolate_lru_page-filter-aware.patch
> mm-zone_reclaim-make-isolate_lru_page-filter-aware-fix.patch
> mm-migration-clean-up-unmap_and_move.patch
> mm-page-writebackc-make-determine_dirtyable_memory-static-again.patch
> oom-avoid-killing-kthreads-if-they-assume-the-oom-killed-threads-mm.patch
> mm-vmscan-drop-nr_force_scan-from-get_scan_count.patch
> mm-mmapc-eliminate-the-ret-variable-from-mm_take_all_locks.patch
> oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch
> oom-do-not-live-lock-on-frozen-tasks.patch
> cgroup-kmemleak-annotate-alloc_page-for-cgroup-allocations.patch
> memcg-rename-mem-variable-to-memcg.patch
> memcg-fix-oom-schedule_timeout.patch
> memcg-do-not-expose-uninitialized-mem_cgroup_per_node-to-world.patch
> memcg-close-race-between-charge-and-putback.patch
> 

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
