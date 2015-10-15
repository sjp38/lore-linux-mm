Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBC56B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 11:50:53 -0400 (EDT)
Received: by payp3 with SMTP id p3so43614438pay.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 08:50:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lo9si22421146pab.201.2015.10.15.08.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 08:50:52 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH block/for-linus] block: don't release bdi while request_queue has live references
References: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
	<20150902194019.GL22326@mtj.duckdns.org>
	<CAAeHK+yZ_696uNf3XFObjCxiG_J3BYvfG_YSMaPEmjuyZdfOzw@mail.gmail.com>
	<CAAeHK+zErydFj8Pqzxj_pM3vtSYAezFMDvRE4CkROjTV=TiPRA@mail.gmail.com>
	<CAAeHK+y=xsnyMy47_Hs1aXNRRpHMDY18Y8uzfAPWHkW3f0+i3Q@mail.gmail.com>
	<20150908162022.GE13749@mtj.duckdns.org>
Date: Thu, 15 Oct 2015 11:50:49 -0400
In-Reply-To: <20150908162022.GE13749@mtj.duckdns.org> (Tejun Heo's message of
	"Tue, 8 Sep 2015 12:20:22 -0400")
Message-ID: <x49d1wggmg6.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@fb.com>, Andrey Konovalov <andreyknvl@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, kernel-team@fb.com

Tejun Heo <tj@kernel.org> writes:

[snip]

Thanks for the nice write-up of the problem.  This looks good to me.
The only minor nit I have is that you might want to rename
cgwb_bdi_destroy to cgwb_bdi_unregister.

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>


> Signed-off-by: Tejun Heo <tj@kernel.org>
> Fixes: a13f35e87140 ("writeback: don't embed root bdi_writeback_congested in bdi_writeback")
> Cc: stable@vger.kernel.org # v4.2+
> Reported-and-tested-by: Andrey Konovalov <andreyknvl@google.com>
> Link: http://lkml.kernel.org/g/CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
