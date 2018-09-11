Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB768E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:32:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 13-v6so32452158oiq.1
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 09:32:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h124-v6si14222257oic.303.2018.09.11.09.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 09:32:28 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8BGV7Hj023779
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:32:27 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mee0h9ted-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:32:27 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 11 Sep 2018 17:32:24 +0100
Subject: Re: [RFC PATCH v2 1/8] mm, memcontrol.c: make memcg lru stats
 thread-safe without lru_lock
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
 <20180911004240.4758-2-daniel.m.jordan@oracle.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 11 Sep 2018 18:32:17 +0200
MIME-Version: 1.0
In-Reply-To: <20180911004240.4758-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e62ef1a0-9518-5a16-df5b-86977b4e8881@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com



On 11/09/2018 02:42, Daniel Jordan wrote:
> lru_lock needs to be held to update memcg LRU statistics.  This
> requirement arises fairly naturally based on when the stats are updated
> because callers are holding lru_lock already.
> 
> In preparation for allowing concurrent adds and removes from the LRU,
> however, make concurrent updates to these statistics safe without
> lru_lock.  The lock continues to be held until later in the series, when
> it is replaced with a rwlock that also disables preemption, maintaining
> the assumption of __mod_lru_zone_size, which is introduced here.
> 
> Follow the existing pattern for statistics in memcontrol.h by using a
> combination of per-cpu counters and atomics.
> 
> Remove the negative statistics warning from ca707239e8a7 ("mm:
> update_lru_size warn and reset bad lru_size").  Although an earlier
> version of this patch updated the warning to account for the error
> introduced by the per-cpu counters, Hugh says this warning has not been
> seen in the wild and that for simplicity's sake it should probably just
> be removed.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  include/linux/memcontrol.h | 43 +++++++++++++++++++++++++++++---------
>  mm/memcontrol.c            | 29 +++++++------------------
>  2 files changed, 40 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d99b71bc2c66..6377dc76dc41 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -99,7 +99,8 @@ struct mem_cgroup_reclaim_iter {
>  };
> 
>  struct lruvec_stat {
> -	long count[NR_VM_NODE_STAT_ITEMS];
> +	long node[NR_VM_NODE_STAT_ITEMS];
> +	long lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];

It might be better to use different name for the lru_zone_size field to
distinguish it from the one in the mem_cgroup_per_node structure.

>  };
> 
>  /*
> @@ -109,9 +110,8 @@ struct mem_cgroup_per_node {
>  	struct lruvec		lruvec;
> 
>  	struct lruvec_stat __percpu *lruvec_stat_cpu;
> -	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
> -
> -	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
> +	atomic_long_t		node_stat[NR_VM_NODE_STAT_ITEMS];
> +	atomic_long_t		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
> 
>  	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
> 
> @@ -446,7 +446,7 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
> 
>  	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
>  	for (zid = 0; zid < MAX_NR_ZONES; zid++)
> -		nr_pages += mz->lru_zone_size[zid][lru];
> +		nr_pages += atomic64_read(&mz->lru_zone_size[zid][lru]);
>  	return nr_pages;
>  }
> 
> @@ -457,7 +457,7 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
>  	struct mem_cgroup_per_node *mz;
> 
>  	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -	return mz->lru_zone_size[zone_idx][lru];
> +	return atomic64_read(&mz->lru_zone_size[zone_idx][lru]);
>  }
> 
>  void mem_cgroup_handle_over_high(void);
> @@ -575,7 +575,7 @@ static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
>  		return node_page_state(lruvec_pgdat(lruvec), idx);
> 
>  	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -	x = atomic_long_read(&pn->lruvec_stat[idx]);
> +	x = atomic_long_read(&pn->node_stat[idx]);
>  #ifdef CONFIG_SMP
>  	if (x < 0)
>  		x = 0;
> @@ -601,12 +601,12 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
>  	__mod_memcg_state(pn->memcg, idx, val);
> 
>  	/* Update lruvec */
> -	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
> +	x = val + __this_cpu_read(pn->lruvec_stat_cpu->node[idx]);
>  	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> -		atomic_long_add(x, &pn->lruvec_stat[idx]);
> +		atomic_long_add(x, &pn->node_stat[idx]);
>  		x = 0;
>  	}
> -	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
> +	__this_cpu_write(pn->lruvec_stat_cpu->node[idx], x);
>  }
> 
>  static inline void mod_lruvec_state(struct lruvec *lruvec,
> @@ -619,6 +619,29 @@ static inline void mod_lruvec_state(struct lruvec *lruvec,
>  	local_irq_restore(flags);
>  }
> 
> +/**
> + * __mod_lru_zone_size - update memcg lru statistics in batches
> + *
> + * Updates memcg lru statistics using per-cpu counters that spill into atomics
> + * above a threshold.
> + *
> + * Assumes that the caller has disabled preemption.  IRQs may be enabled
> + * because this function is not called from irq context.
> + */
> +static inline void __mod_lru_zone_size(struct mem_cgroup_per_node *pn,
> +				       enum lru_list lru, int zid, int val)
> +{
> +	long x;
> +	struct lruvec_stat __percpu *lruvec_stat_cpu = pn->lruvec_stat_cpu;
> +
> +	x = val + __this_cpu_read(lruvec_stat_cpu->lru_zone_size[zid][lru]);
> +	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> +		atomic_long_add(x, &pn->lru_zone_size[zid][lru]);
> +		x = 0;
> +	}
> +	__this_cpu_write(lruvec_stat_cpu->lru_zone_size[zid][lru], x);
> +}
> +
>  static inline void __mod_lruvec_page_state(struct page *page,
>  					   enum node_stat_item idx, int val)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3d101a..5463ad160e10 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -962,36 +962,20 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
>   * @zid: zone id of the accounted pages
>   * @nr_pages: positive when adding or negative when removing
>   *
> - * This function must be called under lru_lock, just before a page is added
> - * to or just after a page is removed from an lru list (that ordering being
> - * so as to allow it to check that lru_size 0 is consistent with list_empty).
> + * This function must be called just before a page is added to, or just after a
> + * page is removed from, an lru list.  Callers aren't required to hold lru_lock
> + * because these statistics use per-cpu counters and atomics.
>   */
>  void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
>  				int zid, int nr_pages)
>  {
>  	struct mem_cgroup_per_node *mz;
> -	unsigned long *lru_size;
> -	long size;
> 
>  	if (mem_cgroup_disabled())
>  		return;
> 
>  	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -	lru_size = &mz->lru_zone_size[zid][lru];
> -
> -	if (nr_pages < 0)
> -		*lru_size += nr_pages;
> -
> -	size = *lru_size;
> -	if (WARN_ONCE(size < 0,
> -		"%s(%p, %d, %d): lru_size %ld\n",
> -		__func__, lruvec, lru, nr_pages, size)) {
> -		VM_BUG_ON(1);
> -		*lru_size = 0;
> -	}
> -
> -	if (nr_pages > 0)
> -		*lru_size += nr_pages;
> +	__mod_lru_zone_size(mz, lru, zid, nr_pages);
>  }
> 
>  bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
> @@ -1833,9 +1817,10 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>  				struct mem_cgroup_per_node *pn;
> 
>  				pn = mem_cgroup_nodeinfo(memcg, nid);
> -				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
> +				x = this_cpu_xchg(pn->lruvec_stat_cpu->node[i],
> +						  0);
>  				if (x)
> -					atomic_long_add(x, &pn->lruvec_stat[i]);
> +					atomic_long_add(x, &pn->node_stat[i]);
>  			}
>  		}
> 
