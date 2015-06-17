Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D5DC86B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 03:47:57 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so43280140wib.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:47:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ht6si7446316wib.102.2015.06.17.00.47.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 00:47:55 -0700 (PDT)
Date: Wed, 17 Jun 2015 09:47:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: use srcu for shrinkers
Message-ID: <20150617074751.GC25056@dhcp22.suse.cz>
References: <1434398602.1903.15.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434398602.1903.15.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 15-06-15 13:03:22, Davidlohr Bueso wrote:
> The shrinker_rwsem is a global lock that protects the shrinker_list,
> serializing a shrinking call with register/unregistering the shrinker
> itself. As such, this lock is taken mostly for reading. In the unlikely
> case that the the list is being modified, we simply return indicating
> we want to iterate again. However, the only caller of shrink_slab()
> that acknowledges this return is drop_slab_node(), so in practice, the
> rest of the callers never try again.

Yeah the try_lock&retry is quite ugly.
 
> This patch proposes replacing the rwsem with an srcu aware list of
> shrinkers, where registering tasks use a spinlock. Upon shrinker calls,
> the srcu read lock will guarantee the existence of the structure. This
> optimizes the common (read locked) case while maintaining the semantics,
> such that a shrinker task will not occur if the list is being modified.

The patch doesn't mention motivation for the change. Yeah the lock
is taken for reading most of the time but I do not remember seeing
it in profiles. I would be quite skeptical if the reason for that
would be a measurable performance gain.

On the other hand using srcu is a neat idea. Shrinkers only need the
existence guarantee when racing with unregister. Register even shouldn't
be that interesting because such a shrinker wouldn't have much to
shrink anyway so we can safely miss it AFAIU. With the srcu read lock
we can finally get rid of the try_lock. I do not think you need an
ugly spin_is_locked as the replacement though. We have the existence
guarantee and that should be sufficient.

The idea makes perfect sense to me.
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  fs/super.c  |  9 ++++-----
>  mm/vmscan.c | 44 ++++++++++++++++++++++++++++----------------
>  2 files changed, 32 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 928c20f..f6946c9 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -49,8 +49,8 @@ static char *sb_writers_name[SB_FREEZE_LEVELS] = {
>   * One thing we have to be careful of with a per-sb shrinker is that we don't
>   * drop the last active reference to the superblock from within the shrinker.
>   * If that happens we could trigger unregistering the shrinker from within the
> - * shrinker path and that leads to deadlock on the shrinker_rwsem. Hence we
> - * take a passive reference to the superblock to avoid this from occurring.
> + * shrinker path. Hence we take a passive reference to the superblock to avoid
> + * this from occurring.
>   */
>  static unsigned long super_cache_scan(struct shrinker *shrink,
>  				      struct shrink_control *sc)
> @@ -121,9 +121,8 @@ static unsigned long super_cache_count(struct shrinker *shrink,
>  	 * Don't call trylock_super as it is a potential
>  	 * scalability bottleneck. The counts could get updated
>  	 * between super_cache_count and super_cache_scan anyway.
> -	 * Call to super_cache_count with shrinker_rwsem held
> -	 * ensures the safety of call to list_lru_shrink_count() and
> -	 * s_op->nr_cached_objects().
> +	 * Safe shrinker deregistering ensures the safety of call
> +	 * to list_lru_shrink_count() and s_op->nr_cached_objects().
>  	 */
>  	if (sb->s_op && sb->s_op->nr_cached_objects)
>  		total_objects = sb->s_op->nr_cached_objects(sb, sc);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c8d8282..d11dc94 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -36,7 +36,8 @@
>  #include <linux/cpuset.h>
>  #include <linux/compaction.h>
>  #include <linux/notifier.h>
> -#include <linux/rwsem.h>
> +#include <linux/srcu.h>
> +#include <linux/spinlock.h>
>  #include <linux/delay.h>
>  #include <linux/kthread.h>
>  #include <linux/freezer.h>
> @@ -146,8 +147,9 @@ int vm_swappiness = 60;
>   */
>  unsigned long vm_total_pages;
>  
> +DEFINE_STATIC_SRCU(shrinker_srcu);
>  static LIST_HEAD(shrinker_list);
> -static DECLARE_RWSEM(shrinker_rwsem);
> +static DEFINE_SPINLOCK(shrinker_list_lock);
>  
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
> @@ -242,9 +244,9 @@ int register_shrinker(struct shrinker *shrinker)
>  	if (!shrinker->nr_deferred)
>  		return -ENOMEM;
>  
> -	down_write(&shrinker_rwsem);
> -	list_add_tail(&shrinker->list, &shrinker_list);
> -	up_write(&shrinker_rwsem);
> +	spin_lock(&shrinker_list_lock);
> +	list_add_tail_rcu(&shrinker->list, &shrinker_list);
> +	spin_unlock(&shrinker_list_lock);
>  	return 0;
>  }
>  EXPORT_SYMBOL(register_shrinker);
> @@ -254,9 +256,14 @@ EXPORT_SYMBOL(register_shrinker);
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> -	down_write(&shrinker_rwsem);
> -	list_del(&shrinker->list);
> -	up_write(&shrinker_rwsem);
> +	spin_lock(&shrinker_list_lock);
> +	list_del_rcu(&shrinker->list);
> +	spin_unlock(&shrinker_list_lock);
> +	/*
> +	 * Before freeing nr_deferred, ensure all srcu
> +	 * readers are done with their critical region.
> +	 */
> +	synchronize_srcu(&shrinker_srcu);
>  	kfree(shrinker->nr_deferred);
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
> @@ -408,6 +415,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  				 unsigned long nr_scanned,
>  				 unsigned long nr_eligible)
>  {
> +	int idx;
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> @@ -417,18 +425,23 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	if (nr_scanned == 0)
>  		nr_scanned = SWAP_CLUSTER_MAX;
>  
> -	if (!down_read_trylock(&shrinker_rwsem)) {
> +	idx = srcu_read_lock(&shrinker_srcu);
> +
> +	if (spin_is_locked(&shrinker_list_lock)) {
>  		/*
> -		 * If we would return 0, our callers would understand that we
> -		 * have nothing else to shrink and give up trying. By returning
> -		 * 1 we keep it going and assume we'll be able to shrink next
> -		 * time.
> +		 * Another task is modifying the shriner_list, abort the
> +		 * shrinking operation until after register/deregistering.
> +		 *
> +		 * If we would return 0, drop_slab_node() would understand
> +		 * that we have nothing else to shrink and give up trying.
> +		 * By returning 1 we keep it going and assume we'll be able
> +		 * to shrink next time.
>  		 */
>  		freed = 1;
>  		goto out;
>  	}
>  
> -	list_for_each_entry(shrinker, &shrinker_list, list) {
> +	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
>  		struct shrink_control sc = {
>  			.gfp_mask = gfp_mask,
>  			.nid = nid,
> @@ -443,9 +456,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  
>  		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
>  	}
> -
> -	up_read(&shrinker_rwsem);
>  out:
> +	srcu_read_unlock(&shrinker_srcu, idx);
>  	cond_resched();
>  	return freed;
>  }
> -- 
> 2.1.4
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
