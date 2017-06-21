Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3CD66B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 21:15:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m84so5685227ita.15
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:15:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n24si299614ioi.229.2017.06.20.18.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 18:15:05 -0700 (PDT)
Date: Tue, 20 Jun 2017 18:14:54 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] percpu_counter: Rename __percpu_counter_add to
 percpu_counter_add_batch
Message-ID: <20170621011454.GE4740@birch.djwong.org>
References: <20170620172835.GA21326@htj.duckdns.org>
 <1497981680-6969-1-git-send-email-nborisov@suse.com>
 <20170620194759.GG21326@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620194759.GG21326@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Nikolay Borisov <nborisov@suse.com>, jbacik@fb.com, linux-kernel@vger.kernel.org, mgorman@techsingularity.net, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>, Jan Kara <jack@suse.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>

On Tue, Jun 20, 2017 at 03:47:59PM -0400, Tejun Heo wrote:
> From 104b4e5139fe384431ac11c3b8a6cf4a529edf4a Mon Sep 17 00:00:00 2001
> From: Nikolay Borisov <nborisov@suse.com>
> Date: Tue, 20 Jun 2017 21:01:20 +0300
> 
> Currently, percpu_counter_add is a wrapper around __percpu_counter_add
> which is preempt safe due to explicit calls to preempt_disable.  Given
> how __ prefix is used in percpu related interfaces, the naming
> unfortunately creates the false sense that __percpu_counter_add is
> less safe than percpu_counter_add.  In terms of context-safety,
> they're equivalent.  The only difference is that the __ version takes
> a batch parameter.
> 
> Make this a bit more explicit by just renaming __percpu_counter_add to
> percpu_counter_add_batch.
> 
> This patch doesn't cause any functional changes.
> 
> tj: Minor updates to patch description for clarity.  Cosmetic
>     indentation updates.
> 
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Chris Mason <clm@fb.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: David Sterba <dsterba@suse.com>
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Cc: Jan Kara <jack@suse.com>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: linux-mm@kvack.org
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
> Hello,
> 
> Applying this patch to percpu/for-4.13.  It's a pure rename patch.  If
> there's any objection, please let me know.
> 
> Thanks.
> 
>  fs/btrfs/disk-io.c             | 12 ++++++------
>  fs/btrfs/extent_io.c           |  6 +++---
>  fs/btrfs/inode.c               |  8 ++++----
>  fs/xfs/xfs_mount.c             |  4 ++--
>  include/linux/backing-dev.h    |  2 +-
>  include/linux/blk-cgroup.h     |  6 +++---
>  include/linux/mman.h           |  2 +-
>  include/linux/percpu_counter.h |  7 ++++---
>  include/net/inet_frag.h        |  4 ++--
>  lib/flex_proportions.c         |  6 +++---
>  lib/percpu_counter.c           |  4 ++--
>  11 files changed, 31 insertions(+), 30 deletions(-)
> 
<snip>
> diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
> index 2eaf81859166..7147d4a8d207 100644
> --- a/fs/xfs/xfs_mount.c
> +++ b/fs/xfs/xfs_mount.c
> @@ -1209,7 +1209,7 @@ xfs_mod_icount(
>  	struct xfs_mount	*mp,
>  	int64_t			delta)
>  {
> -	__percpu_counter_add(&mp->m_icount, delta, XFS_ICOUNT_BATCH);
> +	percpu_counter_add_batch(&mp->m_icount, delta, XFS_ICOUNT_BATCH);
>  	if (__percpu_counter_compare(&mp->m_icount, 0, XFS_ICOUNT_BATCH) < 0) {
>  		ASSERT(0);
>  		percpu_counter_add(&mp->m_icount, -delta);
> @@ -1288,7 +1288,7 @@ xfs_mod_fdblocks(
>  	else
>  		batch = XFS_FDBLOCKS_BATCH;
>  
> -	__percpu_counter_add(&mp->m_fdblocks, delta, batch);
> +	percpu_counter_add_batch(&mp->m_fdblocks, delta, batch);
>  	if (__percpu_counter_compare(&mp->m_fdblocks, mp->m_alloc_set_aside,
>  				     XFS_FDBLOCKS_BATCH) >= 0) {
>  		/* we had space! */

Straight rename looks ok to me,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 557d84063934..ace73f96eb1e 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -66,7 +66,7 @@ static inline bool bdi_has_dirty_io(struct backing_dev_info *bdi)
>  static inline void __add_wb_stat(struct bdi_writeback *wb,
>  				 enum wb_stat_item item, s64 amount)
>  {
> -	__percpu_counter_add(&wb->stat[item], amount, WB_STAT_BATCH);
> +	percpu_counter_add_batch(&wb->stat[item], amount, WB_STAT_BATCH);
>  }
>  
>  static inline void __inc_wb_stat(struct bdi_writeback *wb,
> diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
> index 01b62e7bac74..7104bea8dab1 100644
> --- a/include/linux/blk-cgroup.h
> +++ b/include/linux/blk-cgroup.h
> @@ -518,7 +518,7 @@ static inline void blkg_stat_exit(struct blkg_stat *stat)
>   */
>  static inline void blkg_stat_add(struct blkg_stat *stat, uint64_t val)
>  {
> -	__percpu_counter_add(&stat->cpu_cnt, val, BLKG_STAT_CPU_BATCH);
> +	percpu_counter_add_batch(&stat->cpu_cnt, val, BLKG_STAT_CPU_BATCH);
>  }
>  
>  /**
> @@ -597,14 +597,14 @@ static inline void blkg_rwstat_add(struct blkg_rwstat *rwstat,
>  	else
>  		cnt = &rwstat->cpu_cnt[BLKG_RWSTAT_READ];
>  
> -	__percpu_counter_add(cnt, val, BLKG_STAT_CPU_BATCH);
> +	percpu_counter_add_batch(cnt, val, BLKG_STAT_CPU_BATCH);
>  
>  	if (op_is_sync(op))
>  		cnt = &rwstat->cpu_cnt[BLKG_RWSTAT_SYNC];
>  	else
>  		cnt = &rwstat->cpu_cnt[BLKG_RWSTAT_ASYNC];
>  
> -	__percpu_counter_add(cnt, val, BLKG_STAT_CPU_BATCH);
> +	percpu_counter_add_batch(cnt, val, BLKG_STAT_CPU_BATCH);
>  }
>  
>  /**
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index 634c4c51fe3a..c8367041fafd 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -22,7 +22,7 @@ unsigned long vm_memory_committed(void);
>  
>  static inline void vm_acct_memory(long pages)
>  {
> -	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
> +	percpu_counter_add_batch(&vm_committed_as, pages, vm_committed_as_batch);
>  }
>  
>  static inline void vm_unacct_memory(long pages)
> diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> index 84a109449610..ec065387f443 100644
> --- a/include/linux/percpu_counter.h
> +++ b/include/linux/percpu_counter.h
> @@ -39,7 +39,8 @@ int __percpu_counter_init(struct percpu_counter *fbc, s64 amount, gfp_t gfp,
>  
>  void percpu_counter_destroy(struct percpu_counter *fbc);
>  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
> -void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
> +void percpu_counter_add_batch(struct percpu_counter *fbc, s64 amount,
> +			      s32 batch);
>  s64 __percpu_counter_sum(struct percpu_counter *fbc);
>  int __percpu_counter_compare(struct percpu_counter *fbc, s64 rhs, s32 batch);
>  
> @@ -50,7 +51,7 @@ static inline int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
>  
>  static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
>  {
> -	__percpu_counter_add(fbc, amount, percpu_counter_batch);
> +	percpu_counter_add_batch(fbc, amount, percpu_counter_batch);
>  }
>  
>  static inline s64 percpu_counter_sum_positive(struct percpu_counter *fbc)
> @@ -136,7 +137,7 @@ percpu_counter_add(struct percpu_counter *fbc, s64 amount)
>  }
>  
>  static inline void
> -__percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
> +percpu_counter_add_batch(struct percpu_counter *fbc, s64 amount, s32 batch)
>  {
>  	percpu_counter_add(fbc, amount);
>  }
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 5894730ec82a..5932e6de8fc0 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -154,12 +154,12 @@ static inline int frag_mem_limit(struct netns_frags *nf)
>  
>  static inline void sub_frag_mem_limit(struct netns_frags *nf, int i)
>  {
> -	__percpu_counter_add(&nf->mem, -i, frag_percpu_counter_batch);
> +	percpu_counter_add_batch(&nf->mem, -i, frag_percpu_counter_batch);
>  }
>  
>  static inline void add_frag_mem_limit(struct netns_frags *nf, int i)
>  {
> -	__percpu_counter_add(&nf->mem, i, frag_percpu_counter_batch);
> +	percpu_counter_add_batch(&nf->mem, i, frag_percpu_counter_batch);
>  }
>  
>  static inline unsigned int sum_frag_mem_limit(struct netns_frags *nf)
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index a71cf1bdd4c9..2cc1f94e03a1 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -207,7 +207,7 @@ static void fprop_reflect_period_percpu(struct fprop_global *p,
>  		if (val < (nr_cpu_ids * PROP_BATCH))
>  			val = percpu_counter_sum(&pl->events);
>  
> -		__percpu_counter_add(&pl->events,
> +		percpu_counter_add_batch(&pl->events,
>  			-val + (val >> (period-pl->period)), PROP_BATCH);
>  	} else
>  		percpu_counter_set(&pl->events, 0);
> @@ -219,7 +219,7 @@ static void fprop_reflect_period_percpu(struct fprop_global *p,
>  void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
>  {
>  	fprop_reflect_period_percpu(p, pl);
> -	__percpu_counter_add(&pl->events, 1, PROP_BATCH);
> +	percpu_counter_add_batch(&pl->events, 1, PROP_BATCH);
>  	percpu_counter_add(&p->events, 1);
>  }
>  
> @@ -267,6 +267,6 @@ void __fprop_inc_percpu_max(struct fprop_global *p,
>  			return;
>  	} else
>  		fprop_reflect_period_percpu(p, pl);
> -	__percpu_counter_add(&pl->events, 1, PROP_BATCH);
> +	percpu_counter_add_batch(&pl->events, 1, PROP_BATCH);
>  	percpu_counter_add(&p->events, 1);
>  }
> diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
> index 9c21000df0b5..8ee7e5ec21be 100644
> --- a/lib/percpu_counter.c
> +++ b/lib/percpu_counter.c
> @@ -72,7 +72,7 @@ void percpu_counter_set(struct percpu_counter *fbc, s64 amount)
>  }
>  EXPORT_SYMBOL(percpu_counter_set);
>  
> -void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
> +void percpu_counter_add_batch(struct percpu_counter *fbc, s64 amount, s32 batch)
>  {
>  	s64 count;
>  
> @@ -89,7 +89,7 @@ void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
>  	}
>  	preempt_enable();
>  }
> -EXPORT_SYMBOL(__percpu_counter_add);
> +EXPORT_SYMBOL(percpu_counter_add_batch);
>  
>  /*
>   * Add up all the per-cpu counts, return the result.  This is a more accurate
> -- 
> 2.13.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
