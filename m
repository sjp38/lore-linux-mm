Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4756B002D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2011 04:56:41 -0400 (EDT)
Date: Sat, 29 Oct 2011 10:56:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch added
 to -mm tree
Message-ID: <20111029085638.GA6368@tiehlicka.suse.cz>
References: <201110102246.p9AMkPVD004527@hpaq11.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201110102246.p9AMkPVD004527@hpaq11.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@google.com
Cc: mm-commits@vger.kernel.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, rjw@sisk.pl, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Sorry for the really late reply.

On Mon 10-10-11 15:46:25, akpm@google.com wrote:
> From: David Rientjes <rientjes@google.com>
> Subject: oom: thaw threads if oom killed thread is frozen before deferring
> 
> If a thread has been oom killed and is frozen, thaw it before returning to
> the page allocator.  Otherwise, it can stay frozen indefinitely and no
> memory will be freed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@google.com>

Can we still update the tags?
The issue has been reported by Konstantin Khlebnikov <khlebnikov@openvz.org>
and I think that we want SOB from Rafael here (he originally SOB the
previous patch which thawed tasks from oom_kill_task). You can also add
my Acked-by.

> ---
> 
>  mm/oom_kill.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff -puN mm/oom_kill.c~oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring mm/oom_kill.c
> --- a/mm/oom_kill.c~oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring
> +++ a/mm/oom_kill.c
> @@ -32,6 +32,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/security.h>
>  #include <linux/ptrace.h>
> +#include <linux/freezer.h>
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> @@ -320,8 +321,11 @@ static struct task_struct *select_bad_pr
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
> _
> Subject: Subject: oom: thaw threads if oom killed thread is frozen before deferring
> 
> Patches currently in -mm which might be from rientjes@google.com are
> 
> origin.patch
> linux-next.patch
> oom-avoid-killing-kthreads-if-they-assume-the-oom-killed-threads-mm.patch
> oom-remove-oom_disable_count.patch
> oom-fix-race-while-temporarily-setting-currents-oom_score_adj.patch
> mm-avoid-null-pointer-access-in-vm_struct-via-proc-vmallocinfo.patch
> mm-compaction-make-compact_zone_order-static.patch
> oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch
> cpusets-avoid-looping-when-storing-to-mems_allowed-if-one-node-remains-set.patch
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
