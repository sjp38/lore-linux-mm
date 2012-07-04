Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 025AE6B006C
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 02:57:08 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 2/4] virtio_balloon: handle concurrent accesses to virtio_balloon struct elements
In-Reply-To: <e5f3c6d456f04adeac9fd714a6278424d71a97a0.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com> <e5f3c6d456f04adeac9fd714a6278424d71a97a0.1341353014.git.aquini@redhat.com>
Date: Wed, 04 Jul 2012 16:08:23 +0930
Message-ID: <87vci4uj34.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue,  3 Jul 2012 20:48:50 -0300, Rafael Aquini <aquini@redhat.com> wrote:
> This patch introduces access sychronization to critical elements of struct
> virtio_balloon, in order to allow the thread concurrency compaction/migration
> bits might ended up imposing to the balloon driver on several situations.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

That's pretty vague, and it's almost impossible to audit this.

It looks very suspicious though:

> -static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> -{
> -	struct scatterlist sg;
> -
> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> +/* Protection for concurrent accesses to balloon virtqueues and vb->acked */
> +DEFINE_MUTEX(vb_queue_completion);
>  
> +static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq,
> +		      struct scatterlist *sg)
> +{
> +	mutex_lock(&vb_queue_completion);
>  	init_completion(&vb->acked);
>  
>  	/* We should always be able to add one buffer to an empty queue. */
> -	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
> +	if (virtqueue_add_buf(vq, sg, 1, 0, vb, GFP_KERNEL) < 0)
>  		BUG();
>  	virtqueue_kick(vq);
>  
>  	/* When host has read buffer, this completes via balloon_ack */
>  	wait_for_completion(&vb->acked);
> +	mutex_unlock(&vb_queue_completion);
>  }

OK, this lock is superceded by Michael's patch, and AFAICT is not due to
any requirement introduced by these patches.

>  static void set_page_pfns(u32 pfns[], struct page *page)
> @@ -126,9 +132,12 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>  
>  static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
> +	struct scatterlist sg;
> +	int alloc_failed = 0;
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	spin_lock(&vb->pfn_list_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>  		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
> @@ -138,8 +147,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  				dev_printk(KERN_INFO, &vb->vdev->dev,
>  					   "Out of puff! Can't get %zu pages\n",
>  					   num);
> -			/* Sleep for at least 1/5 of a second before retry. */
> -			msleep(200);
> +			alloc_failed = 1;
>  			break;
>  		}
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> @@ -149,10 +157,19 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> -	if (vb->num_pfns == 0)
> +	if (vb->num_pfns == 0) {
> +		spin_unlock(&vb->pfn_list_lock);
>  		return;
> +	}
> +
> +	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> +	spin_unlock(&vb->pfn_list_lock);
>  
> -	tell_host(vb, vb->inflate_vq);
> +	/* alloc_page failed, sleep for at least 1/5 of a sec before retry. */
> +	if (alloc_failed)
> +		msleep(200);
> +
> +	tell_host(vb, vb->inflate_vq, &sg);

So, we drop the lock which procects vp->pfns[] and vb->num_pfns, then
use it in tell_host?  Surely it could be corrupted between there.

> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index bfbc15c..d47c5c2 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -51,6 +51,10 @@ struct virtio_balloon
>  
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
> +
> +	/* Protect 'pages', 'pfns' & 'num_pnfs' against concurrent updates */
> +	spinlock_t pfn_list_lock;
> +
>  	/*
>  	 * The pages we've told the Host we're not using.
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE

You might be better of taking num_pfns and pfns[] out of struct
virtio_balloon, and putting them on the stack (maybe 64, not 256).

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
