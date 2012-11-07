Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4BCF76B002B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 14:58:12 -0500 (EST)
Date: Wed, 7 Nov 2012 11:58:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 5/7] virtio_balloon: introduce migration primitives
 to balloon pages
Message-Id: <20121107115810.1ae286ac.akpm@linux-foundation.org>
In-Reply-To: <265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
	<265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed,  7 Nov 2012 01:05:52 -0200
Rafael Aquini <aquini@redhat.com> wrote:

> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> Besides making balloon pages movable at allocation time and introducing
> the necessary primitives to perform balloon page migration/compaction,
> this patch also introduces the following locking scheme, in order to
> enhance the syncronization methods for accessing elements of struct
> virtio_balloon, thus providing protection against concurrent access
> introduced by parallel memory migration threads.
> 
> ...
>
> @@ -122,18 +128,25 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>  
>  static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
> +	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> +
> +	static DEFINE_RATELIMIT_STATE(fill_balloon_rs,
> +				      DEFAULT_RATELIMIT_INTERVAL,
> +				      DEFAULT_RATELIMIT_BURST);
> +
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
> -					__GFP_NOMEMALLOC | __GFP_NOWARN);
> +		struct page *page = balloon_page_enqueue(vb_dev_info);
> +
>  		if (!page) {
> -			if (printk_ratelimit())
> +			if (__ratelimit(&fill_balloon_rs))
>  				dev_printk(KERN_INFO, &vb->vdev->dev,
>  					   "Out of puff! Can't get %zu pages\n",
> -					   num);
> +					   VIRTIO_BALLOON_PAGES_PER_PAGE);
>  			/* Sleep for at least 1/5 of a second before retry. */
>  			msleep(200);
>  			break;

linux-next's fill_balloon() has already been converted to
dev_info_ratelimited().  I fixed everything up.  Please check the result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
