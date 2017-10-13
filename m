Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DFFB6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 09:19:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k123so5557415qke.10
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 06:19:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c207si778908qkg.220.2017.10.13.06.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 06:19:10 -0700 (PDT)
Date: Fri, 13 Oct 2017 16:19:07 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at
 virtballoon_oom_notify()
Message-ID: <20171013161804-mutt-send-email-mst@kernel.org>
References: <1507632457-4611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59DED510.5000407@intel.com>
 <201710132028.EHI23713.MJLHOFFOOVtFQS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710132028.EHI23713.MJLHOFFOOVtFQS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jasowang@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On Fri, Oct 13, 2017 at 08:28:37PM +0900, Tetsuo Handa wrote:
> Michael, will you pick up this patch?
> ----------
> >From 210dba24134e54cd470e79712c5cb8bb255566c0 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 10 Oct 2017 19:28:20 +0900
> Subject: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
> 
> In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> serialize against fill_balloon(). But in fill_balloon(),
> alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> is specified, this allocation attempt might indirectly depend on somebody
> else's __GFP_DIRECT_RECLAIM memory allocation. And such indirect
> __GFP_DIRECT_RECLAIM memory allocation might call leak_balloon() via
> virtballoon_oom_notify() via blocking_notifier_call_chain() callback via
> out_of_memory() when it reached __alloc_pages_may_oom() and held oom_lock
> mutex. Since vb->balloon_lock mutex is already held by fill_balloon(), it
> will cause OOM lockup. Thus, do not wait for vb->balloon_lock mutex if
> leak_balloon() is called from out_of_memory().
> 
>   Thread1                                       Thread2
>     fill_balloon()
>       takes a balloon_lock
>       balloon_page_enqueue()
>         alloc_page(GFP_HIGHUSER_MOVABLE)
>           direct reclaim (__GFP_FS context)       takes a fs lock
>             waits for that fs lock                  alloc_page(GFP_NOFS)
>                                                       __alloc_pages_may_oom()
>                                                         takes the oom_lock
>                                                         out_of_memory()
>                                                           blocking_notifier_call_chain()
>                                                             leak_balloon()
>                                                               tries to take that balloon_lock and deadlocks
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reviewed-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Wei Wang <wei.w.wang@intel.com>

I won't since it does not deflate on OOM as we have promised host to do.
Will post a patch to fix the issue shortly.

> ---
>  drivers/virtio/virtio_balloon.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index f0b3a0b..03e6078 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -192,7 +192,7 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>  	}
>  }
>  
> -static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> +static unsigned leak_balloon(struct virtio_balloon *vb, size_t num, bool wait)
>  {
>  	unsigned num_freed_pages;
>  	struct page *page;
> @@ -202,7 +202,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> -	mutex_lock(&vb->balloon_lock);
> +	if (wait)
> +		mutex_lock(&vb->balloon_lock);
> +	else if (!mutex_trylock(&vb->balloon_lock)) {
> +		pr_info("virtio_balloon: Unable to release %lu pages due to lock contention.\n",
> +			(unsigned long) min(num, (size_t)vb->num_pages));
> +		return 0;
> +	}
>  	/* We can't release more pages than taken */
>  	num = min(num, (size_t)vb->num_pages);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -367,7 +373,7 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  		return NOTIFY_OK;
>  
>  	freed = parm;
> -	num_freed_pages = leak_balloon(vb, oom_pages);
> +	num_freed_pages = leak_balloon(vb, oom_pages, false);
>  	update_balloon_size(vb);
>  	*freed += num_freed_pages;
>  
> @@ -395,7 +401,7 @@ static void update_balloon_size_func(struct work_struct *work)
>  	if (diff > 0)
>  		diff -= fill_balloon(vb, diff);
>  	else if (diff < 0)
> -		diff += leak_balloon(vb, -diff);
> +		diff += leak_balloon(vb, -diff, true);
>  	update_balloon_size(vb);
>  
>  	if (diff)
> @@ -597,7 +603,7 @@ static void remove_common(struct virtio_balloon *vb)
>  {
>  	/* There might be pages left in the balloon: free them. */
>  	while (vb->num_pages)
> -		leak_balloon(vb, vb->num_pages);
> +		leak_balloon(vb, vb->num_pages, true);
>  	update_balloon_size(vb);
>  
>  	/* Now we reset the device so we can clean up the queues. */
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
