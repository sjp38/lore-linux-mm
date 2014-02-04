Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A31F06B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:05:22 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id q59so4273928wes.6
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:05:22 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t5si43149148eeo.64.2014.02.04.08.05.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:05:19 -0800 (PST)
Date: Tue, 4 Feb 2014 11:05:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 2/6] memcg: cleanup charge routines
Message-ID: <20140204160509.GN6963@cmpxchg.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391520540-17436-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 04, 2014 at 02:28:56PM +0100, Michal Hocko wrote:
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
> size mm/built-in.o.before mm/built-in.o.after
>    text    data     bss     dec     hex filename
> 464718   83038   49904  597660   91e9c mm/built-in.o.before
> 463894   83038   49904  596836   91b64 mm/built-in.o.after
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 205 +++++++++++++++++++++++++++-----------------------------
>  1 file changed, 98 insertions(+), 107 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 042e4ff36c05..72fbe0fb3320 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2618,7 +2618,7 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  }
>  
>  
> -/* See __mem_cgroup_try_charge() for details */
> +/* See mem_cgroup_do_charge() for details */
>  enum {
>  	CHARGE_OK,		/* success */
>  	CHARGE_RETRY,		/* need to retry but retry is not bad */
> @@ -2691,108 +2691,69 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	return CHARGE_NOMEM;
>  }
>  
> +static bool current_bypass_charge(void)
> +{
> +	/*
> +	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> +	 * in system level. So, allow to go ahead dying process in addition to
> +	 * MEMDIE process.
> +	 */
> +	if (unlikely(test_thread_flag(TIF_MEMDIE)
> +		     || fatal_signal_pending(current)))
> +		return true;
> +
> +	return false;
> +}

I'd just leave it inline at this point, it lines up nicely with the
other pre-charge checks in try_charge, which is at this point short
enough to take this awkward 3-liner.

> +static int mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
>  				   unsigned int nr_pages,
> -				   struct mem_cgroup **ptr,
> +				   struct mem_cgroup *memcg,
>  				   bool oom)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	struct mem_cgroup *memcg = NULL;
>  	int ret;
>  
> -	/*
> -	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> -	 * in system level. So, allow to go ahead dying process in addition to
> -	 * MEMDIE process.
> -	 */
> -	if (unlikely(test_thread_flag(TIF_MEMDIE)
> -		     || fatal_signal_pending(current)))
> +	if (mem_cgroup_is_root(memcg) || current_bypass_charge())
>  		goto bypass;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
>  		goto nomem;
>  
> +	if (consume_stock(memcg, nr_pages))
> +		return 0;
> +
>  	if (gfp_mask & __GFP_NOFAIL)
>  		oom = false;
>  
> -	/*
> -	 * We always charge the cgroup the mm_struct belongs to.
> -	 * The mm_struct's mem_cgroup changes on task migration if the
> -	 * thread group leader migrates. It's possible that mm is not
> -	 * set, if so charge the root memcg (happens for pagecache usage).
> -	 */
> -	if (!*ptr && !mm)
> -		*ptr = root_mem_cgroup;

[...]

>  /*
> + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> + * if mm is NULL). Returns NULL if memcg is under OOM.
> + */
> +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> +				   gfp_t gfp_mask,
> +				   unsigned int nr_pages,
> +				   bool oom)
> +{
> +	struct mem_cgroup *memcg;
> +	int ret;
> +
> +	/*
> +	 * We always charge the cgroup the mm_struct belongs to.
> +	 * The mm_struct's mem_cgroup changes on task migration if the
> +	 * thread group leader migrates. It's possible that mm is not
> +	 * set, if so charge the root memcg (happens for pagecache usage).
> +	 */
> +	if (!mm)
> +		goto bypass;

Why shuffle it around right before you remove it anyway?  Just start
the series off with the patches that delete stuff without having to
restructure anything, get those out of the way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
