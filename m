Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id C630F6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 12:20:23 -0400 (EDT)
Date: Thu, 1 Aug 2013 12:20:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 7/8] memcg: don't account root memcg page stats if
 only root exists
Message-ID: <20130801162012.GA23319@cmpxchg.org>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
 <1375358407-10777-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375358407-10777-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, Aug 01, 2013 at 08:00:07PM +0800, Sha Zhengju wrote:
> @@ -6303,6 +6360,49 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	}
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> +	if (!error) {
> +		if (!mem_cgroup_in_use()) {
> +			/* I'm the first non-root memcg, move global stats to root memcg.
> +			 * Memcg creating is serialized by cgroup locks(cgroup_mutex),
> +			 * so the mem_cgroup_in_use() checking is safe.
> +			 *
> +			 * We use global_page_state() to get global page stats, but
> +			 * because of the optimized inc/dec functions in SMP while
> +			 * updating each zone's stats, We may lose some numbers
> +			 * in a stock(zone->pageset->vm_stat_diff) which brings some
> +			 * inaccuracy. But places where kernel use these page stats to
> +			 * steer next decision e.g. dirty page throttling or writeback
> +			 * also use global_page_state(), so here it's enough too.
> +			 */
> +			spin_lock(&root_mem_cgroup->pcp_counter_lock);
> +			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_MAPPED] =
> +						global_page_state(NR_FILE_MAPPED);
> +			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_DIRTY] =
> +						global_page_state(NR_FILE_DIRTY);
> +			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_WRITEBACK] =
> +						global_page_state(NR_WRITEBACK);
> +			spin_unlock(&root_mem_cgroup->pcp_counter_lock);
> +		}

If inaccuracies in these counters are okay, why do we go through an
elaborate locking scheme that sprinkles memcg callbacks everywhere
just to be 100% reliable in the rare case somebody moves memory
between cgroups?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
