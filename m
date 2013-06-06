Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0AD886B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:28:20 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:28:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm: memcontrol: fix lockless reclaim hierarchy
 iterator
Message-ID: <20130606082818.GC7909@dhcp22.suse.cz>
References: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-06-13 18:53:45, Johannes Weiner wrote:
> The lockless reclaim hierarchy iterator currently has a misplaced
> barrier that can lead to use-after-free crashes.
> 
> The reclaim hierarchy iterator consist of a sequence count and a
> position pointer that are read and written locklessly, with memory
> barriers enforcing ordering.
> 
> The write side sets the position pointer first, then updates the
> sequence count to "publish" the new position.  Likewise, the read side
> must read the sequence count first, then the position.  If the
> sequence count is up to date, it's guaranteed that the position is up
> to date as well:
> 
>   writer:                         reader:
>   iter->position = position       if iter->sequence == expected:
>   smp_wmb()                           smp_rmb()
>   iter->sequence = sequence           position = iter->position
> 
> However, the read side barrier is currently misplaced, which can lead
> to dereferencing stale position pointers that no longer point to valid
> memory.  Fix this.
> 
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: stable@kernel.org [3.10+]

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 010d6c1..e2cbb44 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1199,7 +1199,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  
>  			mz = mem_cgroup_zoneinfo(root, nid, zid);
>  			iter = &mz->reclaim_iter[reclaim->priority];
> -			last_visited = iter->last_visited;
>  			if (prev && reclaim->generation != iter->generation) {
>  				iter->last_visited = NULL;
>  				goto out_unlock;
> @@ -1218,13 +1217,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			 * is alive.
>  			 */
>  			dead_count = atomic_read(&root->dead_count);
> -			smp_rmb();
> -			last_visited = iter->last_visited;
> -			if (last_visited) {
> -				if ((dead_count != iter->last_dead_count) ||
> -					!css_tryget(&last_visited->css)) {
> +			if (dead_count == iter->last_dead_count) {
> +				smp_rmb();
> +				last_visited = iter->last_visited;
> +				if (last_visited &&
> +				    !css_tryget(&last_visited->css))
>  					last_visited = NULL;
> -				}
>  			}
>  		}
>  
> -- 
> 1.8.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
