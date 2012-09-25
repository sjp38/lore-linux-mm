Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 816476B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 20:39:09 -0400 (EDT)
Date: Tue, 25 Sep 2012 02:40:24 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v10 3/5] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20120925004024.GA22665@redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
 <39738cbd4b596714210e453440833db7cca73172.1347897793.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39738cbd4b596714210e453440833db7cca73172.1347897793.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Sep 17, 2012 at 01:38:18PM -0300, Rafael Aquini wrote:
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
> introduced by parallel memory compaction threads.
> 
>  - balloon_lock (mutex) : synchronizes the access demand to elements of
>                           struct virtio_balloon and its queue operations;
>  - pages_lock (spinlock): special protection to balloon's pages bookmarking
>                           elements (list and atomic counters) against the
>                           potential memory compaction concurrency;
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c | 305 +++++++++++++++++++++++++++++++++++++---
>  1 file changed, 286 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 0908e60..a52c768 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -27,6 +27,7 @@
>  #include <linux/delay.h>
>  #include <linux/slab.h>
>  #include <linux/module.h>
> +#include <linux/balloon_compaction.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -34,6 +35,7 @@
>   * page units.
>   */
>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> +#define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
>  
>  struct virtio_balloon
>  {
> @@ -46,11 +48,24 @@ struct virtio_balloon
>  	/* The thread servicing the balloon. */
>  	struct task_struct *thread;
>  
> +	/* balloon special page->mapping */
> +	struct address_space *mapping;
> +
> +	/* Synchronize access/update to this struct virtio_balloon elements */
> +	struct mutex balloon_lock;

Please document here nesting rules wrt page lock for this and pages_lock.

> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> +	/* Protect pages list, and pages bookeeping counters */
> +	spinlock_t pages_lock;
> +
> +	/* Number of balloon pages isolated from 'pages' list for compaction */
> +	unsigned int num_isolated_pages;
> +
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
> +
>  	/*
>  	 * The pages we've told the Host we're not using.
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE

...


> @@ -122,13 +137,17 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>  
>  static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
> +	/* Get the proper GFP alloc mask from vb->mapping flags */
> +	gfp_t vb_gfp_mask = mapping_gfp_mask(vb->mapping);
> +
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
> -					__GFP_NOMEMALLOC | __GFP_NOWARN);
> +		struct page *page = alloc_page(vb_gfp_mask | __GFP_NORETRY |
> +					       __GFP_NOWARN | __GFP_NOMEMALLOC);
>  		if (!page) {
>  			if (printk_ratelimit())
>  				dev_printk(KERN_INFO, &vb->vdev->dev,
> @@ -139,9 +158,15 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  			break;
>  		}
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		totalram_pages--;
> +
> +		BUG_ON(!trylock_page(page));

So here page lock is nested within balloon_lock.

> +		spin_lock(&vb->pages_lock);
>  		list_add(&page->lru, &vb->pages);
> +		assign_balloon_mapping(page, vb->mapping);
> +		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		spin_unlock(&vb->pages_lock);
> +		unlock_page(page);
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> @@ -149,6 +174,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		return;
>  
>  	tell_host(vb, vb->inflate_vq);
> +	mutex_unlock(&vb->balloon_lock);
>  }

...


> +/*
> + * virtballoon_migratepage - perform the balloon page migration on behalf of
> + *			     a compation thread.     (called under page lock)
> + * @mapping: the page->mapping which will be assigned to the new migrated page.
> + * @newpage: page that will replace the isolated page after migration finishes.
> + * @page   : the isolated (old) page that is about to be migrated to newpage.
> + * @mode   : compaction mode -- not used for balloon page migration.
> + *
> + * After a ballooned page gets isolated by compaction procedures, this is the
> + * function that performs the page migration on behalf of a compaction thread
> + * The page migration for virtio balloon is done in a simple swap fashion which
> + * follows these two macro steps:
> + *  1) insert newpage into vb->pages list and update the host about it;
> + *  2) update the host about the old page removed from vb->pages list;
> + *
> + * This function preforms the balloon page migration task.
> + * Called through balloon_mapping->a_ops.
> + */
> +int virtballoon_migratepage(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	struct virtio_balloon *vb = __page_balloon_device(page);
> +
> +	BUG_ON(!vb);
> +
> +	mutex_lock(&vb->balloon_lock);


While here balloon_lock is taken and according to documentation
this is called under page lock.

> +
> +	/* balloon's page migration 1st step */
> +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	spin_lock(&vb->pages_lock);
> +	list_add(&newpage->lru, &vb->pages);
> +	assign_balloon_mapping(newpage, mapping);
> +	vb->num_isolated_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	spin_unlock(&vb->pages_lock);
> +	set_page_pfns(vb->pfns, newpage);
> +	tell_host(vb, vb->inflate_vq);
> +
> +	/* balloon's page migration 2nd step */
> +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	clear_balloon_mapping(page);
> +	set_page_pfns(vb->pfns, page);
> +	tell_host(vb, vb->deflate_vq);
> +
> +	mutex_unlock(&vb->balloon_lock);
> +	wake_up(&vb->config_change);
> +
> +	return BALLOON_MIGRATION_RETURN;
> +}

So nesting is reversed which is normally a problem.
Unfortunately lockep does not seem to work for page lock
otherwise it would detect this.
If this reversed nesting is not a problem, please add
comments in code documenting that this is intentional
and how it works.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
