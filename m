Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD5A6B0257
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:32:28 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so145772822wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:28 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id e11si20709178wjs.28.2015.09.14.12.32.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:32:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so146272283wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:26 -0700 (PDT)
Date: Mon, 14 Sep 2015 21:32:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150914193225.GA26273@dhcp22.suse.cz>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913201442.GD25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Sun 13-09-15 16:14:42, Tejun Heo wrote:
> try_charge() is the main charging logic of memcg.  When it hits the
> limit but either can't fail the allocation due to __GFP_NOFAIL or the
> task is likely to free memory very soon, being OOM killed, has SIGKILL
> pending or exiting, it "bypasses" the charge to the root memcg and
> returns -EINTR.  While this is one approach which can be taken for
> these situations, it has several issues.
> 
> * It unnecessarily lies about the reality.  The number itself doesn't
>   go over the limit but the actual usage does.  memcg is either forced
>   to or actively chooses to go over the limit because that is the
>   right behavior under the circumstances, which is completely fine,
>   but, if at all avoidable, it shouldn't be misrepresenting what's
>   happening by sneaking the charges into the root memcg.
> 
> * Despite trying, we already do over-charge.  kmemcg can't deal with
>   switching over to the root memcg by the point try_charge() returns
>   -EINTR, so it open-codes over-charing.
> 
> * It complicates the callers.  Each try_charge() user has to handle
>   the weird -EINTR exception.  memcg_charge_kmem() does the manual
>   over-charging.  mem_cgroup_do_precharge() performs unnecessary
>   uncharging of root memcg, which BTW is inconsistent with what
>   memcg_charge_kmem() does. 

This is a left over from ce00a967377b ("mm: memcontrol: revert use of
root_mem_cgroup res_counter")

>   mem_cgroup_try_charge() needs to switch
>   the returned cgroup to the root one.
> 
> The reality is that in memcg there are cases where we are forced
> and/or willing to go over the limit.  Each such case needs to be
> scrutinized and justified but there definitely are situations where
> that is the right thing to do.  We alredy do this but with a
> superficial and inconsistent disguise which leads to unnecessary
> complications.
>
> This patch updates try_charge() so that it over-charges and returns 0
> when deemed necessary.  -EINTR return is removed along with all
> special case handling in the callers.

OK the code is easier in the end, although I would argue that try_charge
could return ENOMEM for GFP_NOWAIT instead of overcharging (this would
e.g. allow precharge to bail out earlier). Something for a separate patch I
guess.

Anyway I still do not like usage > max/hard limit presented to userspace
because it looks like a clear breaking of max/hard limit semantic. I
realize that we cannot solve the underlying problem easily or it might
be unfeasible but we should consider how to present this state to the
userspace.
We have basically 2 options AFAICS. We can either document that a
_temporal_ breach of the max/hard limit is allowed or we can hide this
fact and always present max(current,max).
The first one might be better for an easier debugging and it is also
more honest about the current state but the definition of the hard limit
is a bit weird. It also exposes implementation details to the userspace.
The other choice is clearly lying but users shouldn't care about the
implementation details and if the state is really temporal then the
userspace shouldn't even notice. There is also a risk that somebody is
already depending on current < max which happened to work without kmem
until now.

This is something to be solved in a separate patch I guess but we
should think about that. I am not entirely clear on that myself but I am
more inclined to the first option and simply document the potential
corner case and temporal breach.

> While at it, remove the local variable @ret, which was initialized to
> zero and never changed, along with done: label which just returned the
> always zero @ret.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c |   69 ++++++++++++++++----------------------------------------
>  1 file changed, 20 insertions(+), 49 deletions(-)
> 
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1999,13 +1999,12 @@ static int try_charge(struct mem_cgroup
>  	unsigned long nr_reclaimed;
>  	bool may_swap = true;
>  	bool drained = false;
> -	int ret = 0;
>  
>  	if (mem_cgroup_is_root(memcg))
> -		goto done;
> +		return 0;
>  retry:
>  	if (consume_stock(memcg, nr_pages))
> -		goto done;
> +		return 0;
>  
>  	if (!do_swap_account ||
>  	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
> @@ -2033,7 +2032,7 @@ retry:
>  	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
>  		     fatal_signal_pending(current) ||
>  		     current->flags & PF_EXITING))
> -		goto bypass;
> +		goto force;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
>  		goto nomem;
> @@ -2079,10 +2078,10 @@ retry:
>  		goto retry;
>  
>  	if (gfp_mask & __GFP_NOFAIL)
> -		goto bypass;
> +		goto force;
>  
>  	if (fatal_signal_pending(current))
> -		goto bypass;
> +		goto force;
>  
>  	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
>  
> @@ -2090,8 +2089,18 @@ retry:
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
> -bypass:
> -	return -EINTR;
> +force:
> +	/*
> +	 * The allocation either can't fail or will lead to more memory
> +	 * being freed very soon.  Allow memory usage go over the limit
> +	 * temporarily by force charging it.
> +	 */
> +	page_counter_charge(&memcg->memory, nr_pages);
> +	if (do_swap_account)
> +		page_counter_charge(&memcg->memsw, nr_pages);
> +	css_get_many(&memcg->css, nr_pages);
> +
> +	return 0;
>  
>  done_restock:
>  	css_get_many(&memcg->css, batch);
> @@ -2114,8 +2123,8 @@ done_restock:
>  			break;
>  		}
>  	} while ((memcg = parent_mem_cgroup(memcg)));
> -done:
> -	return ret;
> +
> +	return 0;
>  }
>  
>  static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
> @@ -2207,28 +2216,7 @@ int memcg_charge_kmem(struct mem_cgroup
>  		return ret;
>  
>  	ret = try_charge(memcg, gfp, nr_pages);
> -	if (ret == -EINTR)  {
> -		/*
> -		 * try_charge() chose to bypass to root due to OOM kill or
> -		 * fatal signal.  Since our only options are to either fail
> -		 * the allocation or charge it to this cgroup, do it as a
> -		 * temporary condition. But we can't fail. From a kmem/slab
> -		 * perspective, the cache has already been selected, by
> -		 * mem_cgroup_kmem_get_cache(), so it is too late to change
> -		 * our minds.
> -		 *
> -		 * This condition will only trigger if the task entered
> -		 * memcg_charge_kmem in a sane state, but was OOM-killed
> -		 * during try_charge() above. Tasks that were already dying
> -		 * when the allocation triggers should have been already
> -		 * directed to the root cgroup in memcontrol.h
> -		 */
> -		page_counter_charge(&memcg->memory, nr_pages);
> -		if (do_swap_account)
> -			page_counter_charge(&memcg->memsw, nr_pages);
> -		css_get_many(&memcg->css, nr_pages);
> -		ret = 0;
> -	} else if (ret)
> +	if (ret)
>  		page_counter_uncharge(&memcg->kmem, nr_pages);
>  
>  	return ret;
> @@ -4433,22 +4421,10 @@ static int mem_cgroup_do_precharge(unsig
>  		mc.precharge += count;
>  		return ret;
>  	}
> -	if (ret == -EINTR) {
> -		cancel_charge(root_mem_cgroup, count);
> -		return ret;
> -	}
>  
>  	/* Try charges one by one with reclaim */
>  	while (count--) {
>  		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
> -		/*
> -		 * In case of failure, any residual charges against
> -		 * mc.to will be dropped by mem_cgroup_clear_mc()
> -		 * later on.  However, cancel any charges that are
> -		 * bypassed to root right away or they'll be lost.
> -		 */
> -		if (ret == -EINTR)
> -			cancel_charge(root_mem_cgroup, 1);
>  		if (ret)
>  			return ret;
>  		mc.precharge++;
> @@ -5353,11 +5329,6 @@ int mem_cgroup_try_charge(struct page *p
>  	ret = try_charge(memcg, gfp_mask, nr_pages);
>  
>  	css_put(&memcg->css);
> -
> -	if (ret == -EINTR) {
> -		memcg = root_mem_cgroup;
> -		ret = 0;
> -	}
>  out:
>  	*memcgp = memcg;
>  	return ret;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
