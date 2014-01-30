Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id B02B26B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 12:18:48 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so1736907eek.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 09:18:48 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k3si12143787eep.183.2014.01.30.09.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 09:18:47 -0800 (PST)
Date: Thu, 30 Jan 2014 12:18:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/5] memcg: cleanup charge routines
Message-ID: <20140130171837.GD6963@cmpxchg.org>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
 <1387295130-19771-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387295130-19771-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Dec 17, 2013 at 04:45:26PM +0100, Michal Hocko wrote:
> The current core of memcg charging is wild to say the least.
> __mem_cgroup_try_charge which is in the center tries to be too clever
> and it handles two independent cases
> 	* when the memcg to be charged is known in advance
> 	* when the given mm_struct is charged
> The resulting callchains are quite complex:
> 
> memcg_charge_kmem(mm=NULL, memcg)  mem_cgroup_newpage_charge(mm)
>  |                                | _________________________________________ mem_cgroup_cache_charge(current->mm)
>  |                                |/                                            |
>  | ______________________________ mem_cgroup_charge_common(mm, memcg=NULL)      |
>  |/                                                                             /
>  |                                                                             /
>  | ____________________________ mem_cgroup_try_charge_swapin(mm, memcg=NULL)  /
>  |/                               | _________________________________________/
>  |                                |/
>  |                                |                         /* swap accounting */   /* no swap accounting */
>  | _____________________________  __mem_cgroup_try_charge_swapin(mm=NULL, memcg) || (mm, memcg=NULL)
>  |/
>  | ____________________________ mem_cgroup_do_precharge(mm=NULL, memcg)
>  |/
> __mem_cgroup_try_charge
>   mem_cgroup_do_charge
>     res_counter_charge
>     mem_cgroup_reclaim
>     mem_cgroup_wait_acct_move
>     mem_cgroup_oom
> 
> This patch splits __mem_cgroup_try_charge into two logical parts.
> mem_cgroup_try_charge_mm which is responsible for charges for the given
> mm_struct and it returns the charged memcg or NULL under OOM while
> mem_cgroup_try_charge_memcg charges a known memcg and returns an error
> code.
> 
> The only tricky part which remains is __mem_cgroup_try_charge_swapin
> because it can return 0 if PageCgroupUsed is already set and then we do
> not want to commit the charge. This is done with a magic combination of
> memcg = NULL and ret = 0. So the function preserves its memcgp parameter
> and sets the given memcg to NULL when it sees PageCgroupUsed
> (__mem_cgroup_commit_charge_swapin then ignores such a commit).
> 
> Not only the code is easier to follow the change reduces the code size
> too:
> $ size mm/built-in.o.before
>    text	   data	    bss	    dec	    hex	filename
>  457463	  83162	  49824	 590449	  90271	mm/built-in.o.before
> 
> $ size mm/built-in.o.after
>    text	   data	    bss	    dec	    hex	filename
>  456794	  83162	  49824	 589780	  8ffd4	mm/built-in.o.after

Nice!

> @@ -2655,37 +2655,68 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  }
>  
>  /*
> - * __mem_cgroup_try_charge() does
> - * 1. detect memcg to be charged against from passed *mm and *ptr,
> - * 2. update res_counter
> - * 3. call memory reclaim if necessary.
> + * __mem_cgroup_try_charge_memcg - core of the memcg charging code. The caller
> + * keeps a css reference to the given memcg. We do not charge root_mem_cgroup.
> + * OOM is triggered only if allowed by the given oom parameter (except for
> + * __GFP_NOFAIL when it is ignored).
>   *
> - * In some special case, if the task is fatal, fatal_signal_pending() or
> - * has TIF_MEMDIE, this function returns -EINTR while writing root_mem_cgroup
> - * to *ptr. There are two reasons for this. 1: fatal threads should quit as soon
> - * as possible without any hazards. 2: all pages should have a valid
> - * pc->mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
> - * pointer, that is treated as a charge to root_mem_cgroup.
> - *
> - * So __mem_cgroup_try_charge() will return
> - *  0       ...  on success, filling *ptr with a valid memcg pointer.
> - *  -ENOMEM ...  charge failure because of resource limits.
> - *  -EINTR  ...  if thread is fatal. *ptr is filled with root_mem_cgroup.
> - *
> - * Unlike the exported interface, an "oom" parameter is added. if oom==true,
> - * the oom-killer can be invoked.
> + * Returns 0 on success, -ENOMEM when the given memcg is under OOM and -EINTR
> + * when the charge is bypassed (either when fatal signals are pending or
> + * __GFP_NOFAIL allocation cannot be charged).
>   */
> -static int __mem_cgroup_try_charge(struct mm_struct *mm,
> -				   gfp_t gfp_mask,
> +static int __mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
>  				   unsigned int nr_pages,
> -				   struct mem_cgroup **ptr,
> +				   struct mem_cgroup *memcg,
>  				   bool oom)

Why not keep the __mem_cgroup_try_charge() name?  It's shorter and
just as descriptive.

>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	struct mem_cgroup *memcg = NULL;
>  	int ret;
>  
> +	VM_BUG_ON(!memcg || memcg == root_mem_cgroup);
> +
> +	if (unlikely(task_in_memcg_oom(current)))
> +		goto nomem;
> +
> +	if (gfp_mask & __GFP_NOFAIL)
> +		oom = false;
> +
> +	do {
> +		bool invoke_oom = oom && !nr_oom_retries;
> +
> +		/* If killed, bypass charge */
> +		if (fatal_signal_pending(current))
> +			goto bypass;
> +
> +		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
> +					   nr_pages, invoke_oom);
> +		switch (ret) {
> +		case CHARGE_RETRY: /* not in OOM situation but retry */
> +			batch = nr_pages;
> +			break;
> +		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
> +			goto nomem;
> +		case CHARGE_NOMEM: /* OOM routine works */
> +			if (!oom || invoke_oom)
> +				goto nomem;
> +			nr_oom_retries--;
> +			break;
> +		}
> +	} while (ret != CHARGE_OK);
> +
> +	if (batch > nr_pages)
> +		refill_stock(memcg, batch - nr_pages);
> +
> +	return 0;
> +nomem:
> +	if (!(gfp_mask & __GFP_NOFAIL))
> +		return -ENOMEM;
> +bypass:
> +	return -EINTR;
> +}
> +
> +static bool mem_cgroup_bypass_charge(void)

The name and parameter list suggests this consults some global memory
cgroup state.  current_bypass_charge()?  I think ultimately we want to
move away from all these mem_cgroup prefixes of static functions in
there, they add nothing of value.

> +{
>  	/*
>  	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
>  	 * in system level. So, allow to go ahead dying process in addition to
> @@ -2693,13 +2724,23 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	 */
>  	if (unlikely(test_thread_flag(TIF_MEMDIE)
>  		     || fatal_signal_pending(current)))
> -		goto bypass;
> +		return true;
>  
> -	if (unlikely(task_in_memcg_oom(current)))
> -		goto nomem;
> +	return false;
> +}
>  
> -	if (gfp_mask & __GFP_NOFAIL)
> -		oom = false;
> +/*
> + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> + * if mm is NULL). Returns NULL if memcg is under OOM.
> + */
> +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> +				   gfp_t gfp_mask,
> +				   unsigned int nr_pages,
> +				   bool oom)

We already have a try_get_mem_cgroup_from_mm().  After this series,
this function basically duplicates that and it would be much cleaner
if we only had one try_charge() function and let all the callers use
the appropriate try_get_mem_cgroup_from_wherever() themselves.

If you pull the patch that moves consume_stock() back into
try_charge() up front, I think this cleanup would be more obvious and
the result even better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
