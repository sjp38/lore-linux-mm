Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 697256B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:01:36 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id e4so8701463ote.7
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 16:01:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s81si3363532oie.356.2018.01.30.16.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 16:01:35 -0800 (PST)
Date: Wed, 31 Jan 2018 02:01:33 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_balloon: use non-blocking allocation
Message-ID: <20180131015912-mutt-send-email-mst@kernel.org>
References: <1514904621-39186-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1514904621-39186-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Wei Wang <wei.w.wang@intel.com>

On Tue, Jan 02, 2018 at 11:50:21PM +0900, Tetsuo Handa wrote:
> Commit c7cdff0e864713a0 ("virtio_balloon: fix deadlock on OOM") tried to
> avoid OOM lockup by moving memory allocations to outside of balloon_lock.
> 
> Now, Wei is trying to allocate far more pages outside of balloon_lock and
> some more memory inside of balloon_lock in order to perform efficient
> communication between host and guest using scatter-gather API.
> 
> Since pages allocated outside of balloon_lock are not visible to the OOM
> notifier path until fill_balloon() holds balloon_lock (and enqueues the
> pending pages), allocating more pages than now may lead to unacceptably
> premature OOM killer invocation.
> 
> It would be possible to make the pending pages visible to the OOM notifier
> path. But there is no need to try to allocate memory so hard from the
> beginning. As of commit 18468d93e53b037e ("mm: introduce a common
> interface for balloon pages mobility"), it made sense to try allocation
> as hard as possible. But after commit 5a10b7dbf904bfe0 ("virtio_balloon:
> free some memory from balloon on OOM"),

However, please not that this behavious is optional.
Can you keep the current behaviour when deflate on OOM is disabled?


> it no longer makes sense to try
> allocation as hard as possible, for fill_balloon() will after all have to
> release just allocated memory if some allocation request hits the OOM
> notifier path. Therefore, this patch disables __GFP_DIRECT_RECLAIM when
> allocating memory for inflating the balloon. Then, memory for inflating
> the balloon can be allocated inside balloon_lock, and we can release just
> allocated memory as needed.
> 
> Also, this patch adds __GFP_NOWARN, for possibility of hitting memory
> allocation failure is increased by removing __GFP_DIRECT_RECLAIM, which
> might spam the kernel log buffer. At the same time, this patch moves
> "puff" messages to outside of balloon_lock, for it is not a good thing to
> block the OOM notifier path for 1/5 of a second. (Moreover, it is better
> to release the workqueue and allow processing other pending items. But
> that change is out of this patch's scope.)
> 
> __GFP_NOMEMALLOC is currently not required because workqueue context
> which calls balloon_page_alloc() won't cause __gfp_pfmemalloc_flags()
> to return ALLOC_OOM. But since some process context might start calling
> balloon_page_alloc() in future, this patch does not remove
> __GFP_NOMEMALLOC.
> 
> (Only compile tested. Please do runtime tests before committing.)

You will have to find someone to test it.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Wei Wang <wei.w.wang@intel.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/virtio/virtio_balloon.c | 23 +++++++++++++----------
>  mm/balloon_compaction.c         |  5 +++--
>  2 files changed, 16 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index dfe5684..4d9409b 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -141,7 +141,7 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> +static unsigned fill_balloon(struct virtio_balloon *vb, size_t num, bool *oom)
>  {
>  	unsigned num_allocated_pages;
>  	unsigned num_pfns;
> @@ -151,24 +151,19 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&vb->balloon_lock);
> +
>  	for (num_pfns = 0; num_pfns < num;
>  	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>  		struct page *page = balloon_page_alloc();
>  
>  		if (!page) {
> -			dev_info_ratelimited(&vb->vdev->dev,
> -					     "Out of puff! Can't get %u pages\n",
> -					     VIRTIO_BALLOON_PAGES_PER_PAGE);
> -			/* Sleep for at least 1/5 of a second before retry. */
> -			msleep(200);
> +			*oom = true;
>  			break;
>  		}
> -
>  		balloon_page_push(&pages, page);
>  	}
>  
> -	mutex_lock(&vb->balloon_lock);
> -
>  	vb->num_pfns = 0;
>  
>  	while ((page = balloon_page_pop(&pages))) {
> @@ -404,17 +399,25 @@ static void update_balloon_size_func(struct work_struct *work)
>  {
>  	struct virtio_balloon *vb;
>  	s64 diff;
> +	bool oom = false;
>  
>  	vb = container_of(work, struct virtio_balloon,
>  			  update_balloon_size_work);
>  	diff = towards_target(vb);
>  
>  	if (diff > 0)
> -		diff -= fill_balloon(vb, diff);
> +		diff -= fill_balloon(vb, diff, &oom);
>  	else if (diff < 0)
>  		diff += leak_balloon(vb, -diff);
>  	update_balloon_size(vb);
>  
> +	if (oom) {
> +		dev_info_ratelimited(&vb->vdev->dev,
> +				     "Out of puff! Can't get %u pages\n",
> +				     VIRTIO_BALLOON_PAGES_PER_PAGE);
> +		/* Sleep for at least 1/5 of a second before retry. */
> +		msleep(200);
> +	}
>  	if (diff)
>  		queue_work(system_freezable_wq, work);
>  }
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index ef858d5..067df56 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -21,8 +21,9 @@
>   */
>  struct page *balloon_page_alloc(void)
>  {
> -	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> -				       __GFP_NOMEMALLOC | __GFP_NORETRY);
> +	struct page *page = alloc_page((balloon_mapping_gfp_mask() |
> +					__GFP_NOMEMALLOC | __GFP_NOWARN) &
> +				       ~__GFP_DIRECT_RECLAIM);
>  	return page;
>  }
>  EXPORT_SYMBOL_GPL(balloon_page_alloc);
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
