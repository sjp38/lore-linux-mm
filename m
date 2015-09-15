Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8153C6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 17:22:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so46707722wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 14:22:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb3si27409896wib.77.2015.09.15.14.21.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 14:21:58 -0700 (PDT)
Date: Tue, 15 Sep 2015 07:20:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH block/for-linus] block: don't release bdi while
 request_queue has live references
Message-ID: <20150915052028.GA2392@quack.suse.cz>
References: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
 <20150902194019.GL22326@mtj.duckdns.org>
 <CAAeHK+yZ_696uNf3XFObjCxiG_J3BYvfG_YSMaPEmjuyZdfOzw@mail.gmail.com>
 <CAAeHK+zErydFj8Pqzxj_pM3vtSYAezFMDvRE4CkROjTV=TiPRA@mail.gmail.com>
 <CAAeHK+y=xsnyMy47_Hs1aXNRRpHMDY18Y8uzfAPWHkW3f0+i3Q@mail.gmail.com>
 <20150908162022.GE13749@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150908162022.GE13749@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@fb.com>, Andrey Konovalov <andreyknvl@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, kernel-team@fb.com

On Tue 08-09-15 12:20:22, Tejun Heo wrote:
> bdi's are initialized in two steps, bdi_init() and bdi_register(), but
> destroyed in a single step by bdi_destroy() which, for a bdi embedded
> in a request_queue, is called during blk_cleanup_queue() which makes
> the queue invisible and starts the draining of remaining usages.
> 
> A request_queue's user can access the congestion state of the embedded
> bdi as long as it holds a reference to the queue.  As such, it may
> access the congested state of a queue which finished
> blk_cleanup_queue() but hasn't reached blk_release_queue() yet.
> Because the congested state was embedded in backing_dev_info which in
> turn is embedded in request_queue, accessing the congested state after
> bdi_destroy() was called was fine.  The bdi was destroyed but the
> memory region for the congested state remained accessible till the
> queue got released.
> 
> a13f35e87140 ("writeback: don't embed root bdi_writeback_congested in
> bdi_writeback") changed the situation.  Now, the root congested state
> which is expected to be pinned while request_queue remains accessible
> is separately reference counted and the base ref is put during
> bdi_destroy().  This means that the root congested state may go away
> prematurely while the queue is between bdi_dstroy() and
> blk_cleanup_queue(), which was detected by Andrey's KASAN tests.
> 
> The root cause of this problem is that bdi doesn't distinguish the two
> steps of destruction, unregistration and release, and now the root
> congested state actually requires a separate release step.  To fix the
> issue, this patch separates out bdi_unregister() and bdi_exit() from
> bdi_destroy().  bdi_unregister() is called from blk_cleanup_queue()
> and bdi_exit() from blk_release_queue().  bdi_destroy() is now just a
> simple wrapper calling the two steps back-to-back.
> 
> While at it, the prototype of bdi_destroy() is moved right below
> bdi_setup_and_register() so that the counterpart operations are
> located together.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Fixes: a13f35e87140 ("writeback: don't embed root bdi_writeback_congested in bdi_writeback")
> Cc: stable@vger.kernel.org # v4.2+
> Reported-and-tested-by: Andrey Konovalov <andreyknvl@google.com>
> Link: http://lkml.kernel.org/g/CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  block/blk-core.c            |    2 +-
>  block/blk-sysfs.c           |    1 +
>  include/linux/backing-dev.h |    6 +++++-
>  mm/backing-dev.c            |   12 +++++++++++-
>  4 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 60912e9..ae49240 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -576,7 +576,7 @@ void blk_cleanup_queue(struct request_queue *q)
>  		q->queue_lock = &q->__queue_lock;
>  	spin_unlock_irq(lock);
>  
> -	bdi_destroy(&q->backing_dev_info);
> +	bdi_unregister(&q->backing_dev_info);
>  
>  	/* @q is and will stay empty, shutdown and put */
>  	blk_put_queue(q);
> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
> index 3e44a9d..07b42f5 100644
> --- a/block/blk-sysfs.c
> +++ b/block/blk-sysfs.c
> @@ -540,6 +540,7 @@ static void blk_release_queue(struct kobject *kobj)
>  	struct request_queue *q =
>  		container_of(kobj, struct request_queue, kobj);
>  
> +	bdi_exit(&q->backing_dev_info);
>  	blkcg_exit_queue(q);
>  
>  	if (q->elevator) {
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 0fe9df9..fe0ab98 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -18,13 +18,17 @@
>  #include <linux/slab.h>
>  
>  int __must_check bdi_init(struct backing_dev_info *bdi);
> -void bdi_destroy(struct backing_dev_info *bdi);
> +void bdi_exit(struct backing_dev_info *bdi);
>  
>  __printf(3, 4)
>  int bdi_register(struct backing_dev_info *bdi, struct device *parent,
>  		const char *fmt, ...);
>  int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
> +void bdi_unregister(struct backing_dev_info *bdi);
> +
>  int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
> +void bdi_destroy(struct backing_dev_info *bdi);
> +
>  void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  			bool range_cyclic, enum wb_reason reason);
>  void wb_start_background_writeback(struct bdi_writeback *wb);
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index dac5bf5..dc07d88 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -823,7 +823,7 @@ static void bdi_remove_from_list(struct backing_dev_info *bdi)
>  	synchronize_rcu_expedited();
>  }
>  
> -void bdi_destroy(struct backing_dev_info *bdi)
> +void bdi_unregister(struct backing_dev_info *bdi)
>  {
>  	/* make sure nobody finds us on the bdi_list anymore */
>  	bdi_remove_from_list(bdi);
> @@ -835,9 +835,19 @@ void bdi_destroy(struct backing_dev_info *bdi)
>  		device_unregister(bdi->dev);
>  		bdi->dev = NULL;
>  	}
> +}
>  
> +void bdi_exit(struct backing_dev_info *bdi)
> +{
> +	WARN_ON_ONCE(bdi->dev);
>  	wb_exit(&bdi->wb);
>  }
> +
> +void bdi_destroy(struct backing_dev_info *bdi)
> +{
> +	bdi_unregister(bdi);
> +	bdi_exit(bdi);
> +}
>  EXPORT_SYMBOL(bdi_destroy);
>  
>  /*
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
