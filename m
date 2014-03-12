Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B1A986B00A6
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:01:42 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so5223969wgh.17
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:01:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ua15si4014849wib.15.2014.03.12.07.01.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 07:01:40 -0700 (PDT)
Date: Wed, 12 Mar 2014 15:01:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/8] memcg: sanitize __mem_cgroup_try_charge() call
 protocol
Message-ID: <20140312140138.GD11831@dhcp22.suse.cz>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
 <1394587714-6966-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394587714-6966-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 11-03-14 21:28:34, Johannes Weiner wrote:
> Some callsites pass a memcg directly, some callsites pass a mm that
> first has to be translated to an mm.  This makes for a terrible
> function interface.
> 
> Just push the mm-to-memcg translation into the respective callsites
> and always pass a memcg to mem_cgroup_try_charge().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

   text    data     bss     dec     hex filename
  39435    5916    4192   49543    c187 mm/memcontrol.o.after
  40466    5916    4192   50574    c58e mm/memcontrol.o.before

1K down very nice. But we can shave off additional ~300B if the the
common mm charging helper as I suggested before:

   text    data     bss     dec     hex filename
  39100    5916    4192   49208    c038 mm/memcontrol.o.mm

commit 7aa420bc051849d85dcf5a091f3619c6b8e33cfb
Author: Michal Hocko <mhocko@suse.cz>
Date:   Wed Mar 12 14:59:06 2014 +0100

    add charge mm helper

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2d7aa3e784d9..67e01b27a021 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2757,6 +2757,35 @@ bypass:
 	return -EINTR;
 }
 
+/**
+ * mem_cgroup_try_charge_mm - try charging a mm
+ * @mm: mm_struct to charge
+ * @nr_pages: number of pages to charge
+ * @oom: trigger OOM if reclaim fails
+ *
+ * Returns the charged mem_cgroup associated with the given mm_struct or
+ * NULL the charge failed.
+ */
+static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
+				 gfp_t gfp_mask,
+				 unsigned int nr_pages,
+				 bool oom)
+
+{
+	struct mem_cgroup *memcg;
+	int ret;
+
+	memcg = get_mem_cgroup_from_mm(mm);
+	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
+	css_put(&memcg->css);
+	if (ret == -EINTR)
+		memcg = root_mem_cgroup;
+	else if (ret)
+		memcg = NULL;
+
+	return memcg;
+}
+
 /*
  * Somemtimes we have to undo a charge we got by try_charge().
  * This function is for that and do uncharge, put css's refcnt.
@@ -3828,7 +3857,6 @@ int mem_cgroup_newpage_charge(struct page *page,
 	unsigned int nr_pages = 1;
 	struct mem_cgroup *memcg;
 	bool oom = true;
-	int ret;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -3847,13 +3875,9 @@ int mem_cgroup_newpage_charge(struct page *page,
 		oom = false;
 	}
 
-	memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
-	css_put(&memcg->css);
-	if (ret == -EINTR)
-		memcg = root_mem_cgroup;
-	else if (ret)
-		return ret;
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
+	if (!memcg)
+		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, nr_pages,
 				   MEM_CGROUP_CHARGE_TYPE_ANON, false);
 	return 0;
@@ -3914,15 +3938,10 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	 */
 	if (!PageSwapCache(page)) {
 		struct mem_cgroup *memcg;
-		int ret;
 
-		memcg = get_mem_cgroup_from_mm(mm);
-		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
-		css_put(&memcg->css);
-		if (ret == -EINTR)
-			memcg = root_mem_cgroup;
-		else if (ret)
-			return ret;
+		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+		if (!memcg)
+			return -ENOMEM;
 		*memcgp = memcg;
 		return 0;
 	}
@@ -3996,13 +4015,9 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (unlikely(!mm))
 		memcg = root_mem_cgroup;
 	else {
-		memcg = get_mem_cgroup_from_mm(mm);
-		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
-		css_put(&memcg->css);
-		if (ret == -EINTR)
-			memcg = root_mem_cgroup;
-		else if (ret)
-			return ret;
+		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+		if (!memcg)
+			return -ENOMEM;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
 	return 0;

Anyway to your patch as is. The above can be posted as a separate patch
or folded in as you prefer.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 184 +++++++++++++++++++++++++-------------------------------
>  1 file changed, 83 insertions(+), 101 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4f7192bfa5fa..876598b4505b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2609,7 +2609,7 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  }
>  
>  
> -/* See __mem_cgroup_try_charge() for details */
> +/* See mem_cgroup_try_charge() for details */
>  enum {
>  	CHARGE_OK,		/* success */
>  	CHARGE_RETRY,		/* need to retry but retry is not bad */
> @@ -2682,45 +2682,34 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	return CHARGE_NOMEM;
>  }
>  
> -/*
> - * __mem_cgroup_try_charge() does
> - * 1. detect memcg to be charged against from passed *mm and *ptr,
> - * 2. update res_counter
> - * 3. call memory reclaim if necessary.
> - *
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
> +/**
> + * mem_cgroup_try_charge - try charging a memcg
> + * @memcg: memcg to charge
> + * @nr_pages: number of pages to charge
> + * @oom: trigger OOM if reclaim fails
>   *
> - * Unlike the exported interface, an "oom" parameter is added. if oom==true,
> - * the oom-killer can be invoked.
> + * Returns 0 if @memcg was charged successfully, -EINTR if the charge
> + * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
>   */
> -static int __mem_cgroup_try_charge(struct mm_struct *mm,
> -				   gfp_t gfp_mask,
> -				   unsigned int nr_pages,
> -				   struct mem_cgroup **ptr,
> -				   bool oom)
> +static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
> +				 gfp_t gfp_mask,
> +				 unsigned int nr_pages,
> +				 bool oom)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	struct mem_cgroup *memcg = NULL;
>  	int ret;
>  
> +	if (mem_cgroup_is_root(memcg))
> +		goto done;
>  	/*
> -	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> -	 * in system level. So, allow to go ahead dying process in addition to
> -	 * MEMDIE process.
> +	 * Unlike in global OOM situations, memcg is not in a physical
> +	 * memory shortage.  Allow dying and OOM-killed tasks to
> +	 * bypass the last charges so that they can exit quickly and
> +	 * free their memory.
>  	 */
> -	if (unlikely(test_thread_flag(TIF_MEMDIE)
> -		     || fatal_signal_pending(current)))
> +	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> +		     fatal_signal_pending(current)))
>  		goto bypass;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
> @@ -2729,14 +2718,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	if (gfp_mask & __GFP_NOFAIL)
>  		oom = false;
>  again:
> -	if (*ptr) { /* css should be a valid one */
> -		memcg = *ptr;
> -		css_get(&memcg->css);
> -	} else {
> -		memcg = get_mem_cgroup_from_mm(mm);
> -	}
> -	if (mem_cgroup_is_root(memcg))
> -		goto done;
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
>  
> @@ -2744,10 +2725,8 @@ again:
>  		bool invoke_oom = oom && !nr_oom_retries;
>  
>  		/* If killed, bypass charge */
> -		if (fatal_signal_pending(current)) {
> -			css_put(&memcg->css);
> +		if (fatal_signal_pending(current))
>  			goto bypass;
> -		}
>  
>  		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
>  					   nr_pages, invoke_oom);
> @@ -2756,17 +2735,12 @@ again:
>  			break;
>  		case CHARGE_RETRY: /* not in OOM situation but retry */
>  			batch = nr_pages;
> -			css_put(&memcg->css);
> -			memcg = NULL;
>  			goto again;
>  		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
> -			css_put(&memcg->css);
>  			goto nomem;
>  		case CHARGE_NOMEM: /* OOM routine works */
> -			if (!oom || invoke_oom) {
> -				css_put(&memcg->css);
> +			if (!oom || invoke_oom)
>  				goto nomem;
> -			}
>  			nr_oom_retries--;
>  			break;
>  		}
> @@ -2775,16 +2749,11 @@ again:
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
>  done:
> -	css_put(&memcg->css);
> -	*ptr = memcg;
>  	return 0;
>  nomem:
> -	if (!(gfp_mask & __GFP_NOFAIL)) {
> -		*ptr = NULL;
> +	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
> -	}
>  bypass:
> -	*ptr = root_mem_cgroup;
>  	return -EINTR;
>  }
>  
> @@ -2983,20 +2952,17 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
>  static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>  {
>  	struct res_counter *fail_res;
> -	struct mem_cgroup *_memcg;
>  	int ret = 0;
>  
>  	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
>  	if (ret)
>  		return ret;
>  
> -	_memcg = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
> -				      &_memcg, oom_gfp_allowed(gfp));
> -
> +	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
> +				    oom_gfp_allowed(gfp));
>  	if (ret == -EINTR)  {
>  		/*
> -		 * __mem_cgroup_try_charge() chosed to bypass to root due to
> +		 * mem_cgroup_try_charge() chosed to bypass to root due to
>  		 * OOM kill or fatal signal.  Since our only options are to
>  		 * either fail the allocation or charge it to this cgroup, do
>  		 * it as a temporary condition. But we can't fail. From a
> @@ -3006,7 +2972,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>  		 *
>  		 * This condition will only trigger if the task entered
>  		 * memcg_charge_kmem in a sane state, but was OOM-killed during
> -		 * __mem_cgroup_try_charge() above. Tasks that were already
> +		 * mem_cgroup_try_charge() above. Tasks that were already
>  		 * dying when the allocation triggers should have been already
>  		 * directed to the root cgroup in memcontrol.h
>  		 */
> @@ -3858,8 +3824,8 @@ out:
>  int mem_cgroup_newpage_charge(struct page *page,
>  			      struct mm_struct *mm, gfp_t gfp_mask)
>  {
> -	struct mem_cgroup *memcg = NULL;
>  	unsigned int nr_pages = 1;
> +	struct mem_cgroup *memcg;
>  	bool oom = true;
>  	int ret;
>  
> @@ -3880,8 +3846,12 @@ int mem_cgroup_newpage_charge(struct page *page,
>  		oom = false;
>  	}
>  
> -	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
> -	if (ret == -ENOMEM)
> +	memcg = get_mem_cgroup_from_mm(mm);
> +	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
> +	css_put(&memcg->css);
> +	if (ret == -EINTR)
> +		memcg = root_mem_cgroup;
> +	else if (ret)
>  		return ret;
>  	__mem_cgroup_commit_charge(memcg, page, nr_pages,
>  				   MEM_CGROUP_CHARGE_TYPE_ANON, false);
> @@ -3899,7 +3869,7 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  					  gfp_t mask,
>  					  struct mem_cgroup **memcgp)
>  {
> -	struct mem_cgroup *memcg;
> +	struct mem_cgroup *memcg = NULL;
>  	struct page_cgroup *pc;
>  	int ret;
>  
> @@ -3912,31 +3882,29 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  	 * in turn serializes uncharging.
>  	 */
>  	if (PageCgroupUsed(pc))
> -		return 0;
> -	if (!do_swap_account)
> -		goto charge_cur_mm;
> -	memcg = try_get_mem_cgroup_from_page(page);
> +		goto out;
> +	if (do_swap_account)
> +		memcg = try_get_mem_cgroup_from_page(page);
>  	if (!memcg)
> -		goto charge_cur_mm;
> -	*memcgp = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
> +		memcg = get_mem_cgroup_from_mm(mm);
> +	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
>  	css_put(&memcg->css);
>  	if (ret == -EINTR)
> -		ret = 0;
> -	return ret;
> -charge_cur_mm:
> -	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
> -	if (ret == -EINTR)
> -		ret = 0;
> -	return ret;
> +		memcg = root_mem_cgroup;
> +	else if (ret)
> +		return ret;
> +out:
> +	*memcgp = memcg;
> +	return 0;
>  }
>  
>  int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
>  				 gfp_t gfp_mask, struct mem_cgroup **memcgp)
>  {
> -	*memcgp = NULL;
> -	if (mem_cgroup_disabled())
> +	if (mem_cgroup_disabled()) {
> +		*memcgp = NULL;
>  		return 0;
> +	}
>  	/*
>  	 * A racing thread's fault, or swapoff, may have already
>  	 * updated the pte, and even removed page from swap cache: in
> @@ -3944,12 +3912,18 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
>  	 * there's also a KSM case which does need to charge the page.
>  	 */
>  	if (!PageSwapCache(page)) {
> +		struct mem_cgroup *memcg;
>  		int ret;
>  
> -		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, memcgp, true);
> +		memcg = get_mem_cgroup_from_mm(mm);
> +		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
> +		css_put(&memcg->css);
>  		if (ret == -EINTR)
> -			ret = 0;
> -		return ret;
> +			memcg = root_mem_cgroup;
> +		else if (ret)
> +			return ret;
> +		*memcgp = memcg;
> +		return 0;
>  	}
>  	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp);
>  }
> @@ -3996,8 +3970,8 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> -	struct mem_cgroup *memcg = NULL;
>  	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	struct mem_cgroup *memcg;
>  	int ret;
>  
>  	if (mem_cgroup_disabled())
> @@ -4005,23 +3979,32 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  	if (PageCompound(page))
>  		return 0;
>  
> -	if (!PageSwapCache(page)) {
> -		/*
> -		 * Page cache insertions can happen without an actual
> -		 * task context, e.g. during disk probing on boot.
> -		 */
> -		if (!mm)
> -			memcg = root_mem_cgroup;
> -		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
> -		if (ret != -ENOMEM)
> -			__mem_cgroup_commit_charge(memcg, page, 1, type, false);
> -	} else { /* page is swapcache/shmem */
> +	if (PageSwapCache(page)) { /* shmem */
>  		ret = __mem_cgroup_try_charge_swapin(mm, page,
>  						     gfp_mask, &memcg);
> -		if (!ret)
> -			__mem_cgroup_commit_charge_swapin(page, memcg, type);
> +		if (ret)
> +			return ret;
> +		__mem_cgroup_commit_charge_swapin(page, memcg, type);
> +		return 0;
>  	}
> -	return ret;
> +
> +	/*
> +	 * Page cache insertions can happen without an actual mm
> +	 * context, e.g. during disk probing on boot.
> +	 */
> +	if (unlikely(!mm))
> +		memcg = root_mem_cgroup;
> +	else {
> +		memcg = get_mem_cgroup_from_mm(mm);
> +		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
> +		css_put(&memcg->css);
> +		if (ret == -EINTR)
> +			memcg = root_mem_cgroup;
> +		else if (ret)
> +			return ret;
> +	}
> +	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
> +	return 0;
>  }
>  
>  static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
> @@ -6635,8 +6618,7 @@ one_by_one:
>  			batch_count = PRECHARGE_COUNT_AT_ONCE;
>  			cond_resched();
>  		}
> -		ret = __mem_cgroup_try_charge(NULL,
> -					GFP_KERNEL, 1, &memcg, false);
> +		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
>  		if (ret)
>  			/* mem_cgroup_clear_mc() will do uncharge later */
>  			return ret;
> -- 
> 1.9.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
