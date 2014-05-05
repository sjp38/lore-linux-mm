Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 95BB26B00A1
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:35:21 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so1946904eei.28
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:35:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si10576489eew.168.2014.05.05.08.35.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:35:20 -0700 (PDT)
Date: Mon, 5 May 2014 17:35:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] mm/memcontrol.c: introduce helper
 mem_cgroup_zoneinfo_zone()
Message-ID: <20140505153519.GE32598@dhcp22.suse.cz>
References: <1397862103-31982-1-git-send-email-nasa4836@gmail.com>
 <20140422095923.GD29311@dhcp22.suse.cz>
 <20140428150426.GB24807@dhcp22.suse.cz>
 <20140501125450.GA23420@cmpxchg.org>
 <20140502150516.d42792bad53d86fb727816bd@linux-foundation.org>
 <20140502232908.GQ23420@cmpxchg.org>
 <20140502233138.GR23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502233138.GR23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jianyu Zhan <nasa4836@gmail.com>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.com

On Fri 02-05-14 19:31:38, Johannes Weiner wrote:
> While in that area, I noticed that the soft limit tree updaters don't
> actually use the memcg argument anymore...
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: memcontrol: remove unnecessary memcg argument from soft
>  limit functions
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 34 ++++++++++++++--------------------
>  1 file changed, 14 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 83cbd5a0e62f..3381f76df084 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -714,11 +714,9 @@ soft_limit_tree_from_page(struct page *page)
>  	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
>  }
>  
> -static void
> -__mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
> -				struct mem_cgroup_per_zone *mz,
> -				struct mem_cgroup_tree_per_zone *mctz,
> -				unsigned long long new_usage_in_excess)
> +static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
> +					 struct mem_cgroup_tree_per_zone *mctz,
> +					 unsigned long long new_usage_in_excess)
>  {
>  	struct rb_node **p = &mctz->rb_root.rb_node;
>  	struct rb_node *parent = NULL;
> @@ -748,10 +746,8 @@ __mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
>  	mz->on_tree = true;
>  }
>  
> -static void
> -__mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
> -				struct mem_cgroup_per_zone *mz,
> -				struct mem_cgroup_tree_per_zone *mctz)
> +static void __mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
> +					 struct mem_cgroup_tree_per_zone *mctz)
>  {
>  	if (!mz->on_tree)
>  		return;
> @@ -759,13 +755,11 @@ __mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
>  	mz->on_tree = false;
>  }
>  
> -static void
> -mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
> -				struct mem_cgroup_per_zone *mz,
> -				struct mem_cgroup_tree_per_zone *mctz)
> +static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
> +				       struct mem_cgroup_tree_per_zone *mctz)
>  {
>  	spin_lock(&mctz->lock);
> -	__mem_cgroup_remove_exceeded(memcg, mz, mctz);
> +	__mem_cgroup_remove_exceeded(mz, mctz);
>  	spin_unlock(&mctz->lock);
>  }
>  
> @@ -792,12 +786,12 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>  			spin_lock(&mctz->lock);
>  			/* if on-tree, remove it */
>  			if (mz->on_tree)
> -				__mem_cgroup_remove_exceeded(memcg, mz, mctz);
> +				__mem_cgroup_remove_exceeded(mz, mctz);
>  			/*
>  			 * Insert again. mz->usage_in_excess will be updated.
>  			 * If excess is 0, no tree ops.
>  			 */
> -			__mem_cgroup_insert_exceeded(memcg, mz, mctz, excess);
> +			__mem_cgroup_insert_exceeded(mz, mctz, excess);
>  			spin_unlock(&mctz->lock);
>  		}
>  	}
> @@ -813,7 +807,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>  		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>  			mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
>  			mctz = soft_limit_tree_node_zone(nid, zid);
> -			mem_cgroup_remove_exceeded(memcg, mz, mctz);
> +			mem_cgroup_remove_exceeded(mz, mctz);
>  		}
>  	}
>  }
> @@ -836,7 +830,7 @@ retry:
>  	 * we will to add it back at the end of reclaim to its correct
>  	 * position in the tree.
>  	 */
> -	__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
> +	__mem_cgroup_remove_exceeded(mz, mctz);
>  	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
>  		!css_tryget(&mz->memcg->css))
>  		goto retry;
> @@ -4694,7 +4688,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  					break;
>  			} while (1);
>  		}
> -		__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
> +		__mem_cgroup_remove_exceeded(mz, mctz);
>  		excess = res_counter_soft_limit_excess(&mz->memcg->res);
>  		/*
>  		 * One school of thought says that we should not add
> @@ -4705,7 +4699,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  		 * term TODO.
>  		 */
>  		/* If excess == 0, no tree ops */
> -		__mem_cgroup_insert_exceeded(mz->memcg, mz, mctz, excess);
> +		__mem_cgroup_insert_exceeded(mz, mctz, excess);
>  		spin_unlock(&mctz->lock);
>  		css_put(&mz->memcg->css);
>  		loop++;
> -- 
> 1.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
