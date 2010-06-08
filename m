Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 26BDD6B0210
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg5lx008138
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B704A45DE70
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 612EA45DE87
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5A441DB8043
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A471E38010
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 13/18] oom: remove special handling for pagefault ooms
In-Reply-To: <alpine.DEB.2.00.1006061526120.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526120.32225@chino.kir.corp.google.com>
Message-Id: <20100608203659.7675.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It is possible to remove the special pagefault oom handler by simply oom
> locking all system zones and then calling directly into out_of_memory().
> 
> All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
> parallel oom killing in progress that will lead to eventual memory freeing
> so it's not necessary to needlessly kill another task.  The context in
> which the pagefault is allocating memory is unknown to the oom killer, so
> this is done on a system-wide level.
> 
> If a task has already been oom killed and hasn't fully exited yet, this
> will be a no-op since select_bad_process() recognizes tasks across the
> system with TIF_MEMDIE set.
> 
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   86 +++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 57 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -615,6 +615,44 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  }
>  
>  /*
> + * Try to acquire the oom killer lock for all system zones.  Returns zero if a
> + * parallel oom killing is taking place, otherwise locks all zones and returns
> + * non-zero.
> + */
> +static int try_set_system_oom(void)
> +{
> +	struct zone *zone;
> +	int ret = 1;
> +
> +	spin_lock(&zone_scan_lock);
> +	for_each_populated_zone(zone)
> +		if (zone_is_oom_locked(zone)) {
> +			ret = 0;
> +			goto out;
> +		}
> +	for_each_populated_zone(zone)
> +		zone_set_flag(zone, ZONE_OOM_LOCKED);
> +out:
> +	spin_unlock(&zone_scan_lock);
> +	return ret;
> +}
> +
> +/*
> + * Clears ZONE_OOM_LOCKED for all system zones so that failed allocation
> + * attempts or page faults may now recall the oom killer, if necessary.
> + */
> +static void clear_system_oom(void)
> +{
> +	struct zone *zone;
> +
> +	spin_lock(&zone_scan_lock);
> +	for_each_populated_zone(zone)
> +		zone_clear_flag(zone, ZONE_OOM_LOCKED);
> +	spin_unlock(&zone_scan_lock);
> +}
> +
> +
> +/*
>   * Must be called with tasklist_lock held for read.
>   */
>  static void __out_of_memory(gfp_t gfp_mask, int order,
> @@ -649,33 +687,6 @@ retry:
>  		goto retry;
>  }
>  
> -/*
> - * pagefault handler calls into here because it is out of memory but
> - * doesn't know exactly how or why.
> - */
> -void pagefault_out_of_memory(void)
> -{
> -	unsigned long freed = 0;
> -
> -	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> -	if (freed > 0)
> -		/* Got some memory back in the last second. */
> -		return;
> -
> -	check_panic_on_oom(CONSTRAINT_NONE, 0, 0);
> -	read_lock(&tasklist_lock);
> -	/* unknown gfp_mask and order */
> -	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
> -	read_unlock(&tasklist_lock);
> -
> -	/*
> -	 * Give "p" a good chance of killing itself before we
> -	 * retry to allocate memory.
> -	 */
> -	if (!test_thread_flag(TIF_MEMDIE))
> -		schedule_timeout_uninterruptible(1);
> -}
> -
>  /**
>   * out_of_memory - kill the "best" process when we run out of memory
>   * @zonelist: zonelist pointer
> @@ -692,7 +703,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *nodemask)
>  {
>  	unsigned long freed = 0;
> -	enum oom_constraint constraint;
> +	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
>  	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
>  	if (freed > 0)
> @@ -713,7 +724,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA) that may require different handling.
>  	 */
> -	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
> +	if (zonelist)
> +		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
>  	check_panic_on_oom(constraint, gfp_mask, order);
>  	read_lock(&tasklist_lock);
>  	__out_of_memory(gfp_mask, order, constraint, nodemask);
> @@ -726,3 +738,19 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	if (!test_thread_flag(TIF_MEMDIE))
>  		schedule_timeout_uninterruptible(1);
>  }
> +
> +/*
> + * The pagefault handler calls here because it is out of memory, so kill a
> + * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
> + * oom killing is already in progress so do nothing.  If a task is found with
> + * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
> + */
> +void pagefault_out_of_memory(void)
> +{
> +	if (try_set_system_oom()) {
> +		out_of_memory(NULL, 0, 0, NULL);
> +		clear_system_oom();
> +	}
> +	if (!test_thread_flag(TIF_MEMDIE))
> +		schedule_timeout_uninterruptible(1);
> +}

this one is already there in my patch kit.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
