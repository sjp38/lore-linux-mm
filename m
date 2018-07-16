Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B966F6B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 08:30:45 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u1-v6so8354258wrs.18
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 05:30:45 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w18-v6si9530942wmc.107.2018.07.16.05.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 05:30:44 -0700 (PDT)
Date: Mon, 16 Jul 2018 14:30:38 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/6] bdi: Use refcount_t for reference counting instead
 atomic_t
Message-ID: <20180716123038.hxdc3dv7h3gyfjpd@linutronix.de>
References: <20180703200141.28415-1-bigeasy@linutronix.de>
 <20180703200141.28415-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180703200141.28415-4-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org

On 2018-07-03 22:01:38 [+0200], To linux-kernel@vger.kernel.org wrote:
> refcount_t type and corresponding API should be used instead of atomic_t when
> the variable is used as a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free situations.

Andrew, is it okay for you to collect this one (and 4/6 of this series,
both bdi)? The prerequisites are already in Linus' tree.

> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  include/linux/backing-dev-defs.h |  3 ++-
>  include/linux/backing-dev.h      |  4 ++--
>  mm/backing-dev.c                 | 12 ++++++------
>  3 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index 24251762c20c..9a6bc0951cfa 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -12,6 +12,7 @@
>  #include <linux/timer.h>
>  #include <linux/workqueue.h>
>  #include <linux/kref.h>
> +#include <linux/refcount.h>
>  
>  struct page;
>  struct device;
> @@ -75,7 +76,7 @@ enum wb_reason {
>   */
>  struct bdi_writeback_congested {
>  	unsigned long state;		/* WB_[a]sync_congested flags */
> -	atomic_t refcnt;		/* nr of attached wb's and blkg */
> +	refcount_t refcnt;		/* nr of attached wb's and blkg */
>  
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  	struct backing_dev_info *__bdi;	/* the associated bdi, set to NULL
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 72ca0f3d39f3..c28a47cbe355 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -404,13 +404,13 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
>  static inline struct bdi_writeback_congested *
>  wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  {
> -	atomic_inc(&bdi->wb_congested->refcnt);
> +	refcount_inc(&bdi->wb_congested->refcnt);
>  	return bdi->wb_congested;
>  }
>  
>  static inline void wb_congested_put(struct bdi_writeback_congested *congested)
>  {
> -	if (atomic_dec_and_test(&congested->refcnt))
> +	if (refcount_dec_and_test(&congested->refcnt))
>  		kfree(congested);
>  }
>  
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 2e5d3df0853d..55a233d75f39 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -438,10 +438,10 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  	if (new_congested) {
>  		/* !found and storage for new one already allocated, insert */
>  		congested = new_congested;
> -		new_congested = NULL;
>  		rb_link_node(&congested->rb_node, parent, node);
>  		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
> -		goto found;
> +		spin_unlock_irqrestore(&cgwb_lock, flags);
> +		return congested;
>  	}
>  
>  	spin_unlock_irqrestore(&cgwb_lock, flags);
> @@ -451,13 +451,13 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  	if (!new_congested)
>  		return NULL;
>  
> -	atomic_set(&new_congested->refcnt, 0);
> +	refcount_set(&new_congested->refcnt, 1);
>  	new_congested->__bdi = bdi;
>  	new_congested->blkcg_id = blkcg_id;
>  	goto retry;
>  
>  found:
> -	atomic_inc(&congested->refcnt);
> +	refcount_inc(&congested->refcnt);
>  	spin_unlock_irqrestore(&cgwb_lock, flags);
>  	kfree(new_congested);
>  	return congested;
> @@ -474,7 +474,7 @@ void wb_congested_put(struct bdi_writeback_congested *congested)
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
> +	if (!refcount_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
>  		local_irq_restore(flags);
>  		return;
>  	}
> @@ -804,7 +804,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
>  	if (!bdi->wb_congested)
>  		return -ENOMEM;
>  
> -	atomic_set(&bdi->wb_congested->refcnt, 1);
> +	refcount_set(&bdi->wb_congested->refcnt, 1);
>  
>  	err = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
>  	if (err) {
> -- 
> 2.18.0

Sebastian
