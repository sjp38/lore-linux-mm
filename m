Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 067D36B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 13:14:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 82so16072195oid.11
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 10:14:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t33si1757083otb.89.2017.10.22.10.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 10:14:02 -0700 (PDT)
Date: Sun, 22 Oct 2017 20:13:59 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 3/3] virtio-balloon: stop inflating when OOM occurs
Message-ID: <20171022062159-mutt-send-email-mst@kernel.org>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
 <1508500466-21165-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508500466-21165-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Fri, Oct 20, 2017 at 07:54:26PM +0800, Wei Wang wrote:
> This patch forces the cease of the inflating work when OOM occurs.
> The fundamental idea of memory ballooning is to take out some guest
> pages when the guest has low memory utilization, so it is sensible to
> inflate nothing when the guest is already under memory pressure.
> 
> On the other hand, the policy is determined by the admin or the
> orchestration layer from the host. That is, the host is expected to
> re-start the memory inflating request at a proper time later when
> the guest has enough memory to inflate, for example, by checking
> the memory stats reported by the balloon.

Is there any other way to do it? And if so can't we just have guest do
it automatically? Maybe the issue is really that fill attempts to
allocate memory aggressively instead of checking availability.
Maybe with deflate on oom it should check availability?


> If another inflating
> requests is sent to guest when the guest is still under memory
> pressure, still no pages will be inflated.

Any such changes are hypervisor-visible and need a new feature bit.


> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  drivers/virtio/virtio_balloon.c | 33 +++++++++++++++++++++++++++++----
>  1 file changed, 29 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index ab55cf8..cf29663 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -63,6 +63,15 @@ struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>  
> +	/*
> +	 * The balloon driver enters the oom mode if the oom notifier is
> +	 * invoked. Entering the oom mode will force the exit of current
> +	 * inflating work. When a later inflating request is received from
> +	 * the host, the success of memory allocation via balloon_page_enqueue
> +	 * will turn off the mode.
> +	 */
> +	bool oom_mode;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> @@ -142,22 +151,22 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> +	struct page *page;
> +	size_t orig_num;
>  	unsigned int num_pfns;
>  	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
>  
> +	orig_num = num;
>  	/* We can only do one array worth at a time. */
>  	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
>  
>  	for (num_pfns = 0; num_pfns < num;
>  	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		struct page *page = balloon_page_enqueue(vb_dev_info);
> -
> +		page = balloon_page_enqueue(vb_dev_info);
>  		if (!page) {
>  			dev_info_ratelimited(&vb->vdev->dev,
>  					     "Out of puff! Can't get %u pages\n",
>  					     VIRTIO_BALLOON_PAGES_PER_PAGE);
> -			/* Sleep for at least 1/5 of a second before retry. */
> -			msleep(200);
>  			break;
>  		}
>  		set_page_pfns(vb, pfns + num_pfns, page);
> @@ -166,6 +175,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			adjust_managed_page_count(page, -1);
>  	}
>  
> +	/*
> +	 * The oom_mode is set, but we've already been able to get some
> +	 * pages, so it is time to turn it off here.
> +	 */
> +	if (unlikely(READ_ONCE(vb->oom_mode) && page))
> +		WRITE_ONCE(vb->oom_mode, false);
> +
>  	mutex_lock(&vb->inflate_lock);
>  	/* Did we get any? */
>  	if (num_pfns != 0)
> @@ -173,6 +189,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  	mutex_unlock(&vb->inflate_lock);
>  	atomic64_add(num_pfns, &vb->num_pages);
>  
> +	/*
> +	 * If oom_mode is on, return the original @num passed by
> +	 * update_balloon_size_func to stop the inflating.
> +	 */
> +	if (READ_ONCE(vb->oom_mode))
> +		return orig_num;
> +
>  	return num_pfns;
>  }
>  
> @@ -365,6 +388,7 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		return NOTIFY_OK;
>  
> +	WRITE_ONCE(vb->oom_mode, true);
>  	freed = parm;
>  
>  	/* Don't deflate more than the number of inflated pages */
> @@ -549,6 +573,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
> +	vb->oom_mode = false;
>  	atomic64_set(&vb->num_pages, 0);
>  	mutex_init(&vb->inflate_lock);
>  	mutex_init(&vb->deflate_lock);
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
