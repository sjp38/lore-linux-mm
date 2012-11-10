Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8B1A56B0044
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 10:51:33 -0500 (EST)
Date: Sat, 10 Nov 2012 17:53:59 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 5/7] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20121110155359.GB13846@redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Nov 07, 2012 at 01:05:52AM -0200, Rafael Aquini wrote:
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
>  - balloon_lock (mutex) : synchronizes the access demand to elements of
>                           struct virtio_balloon and its queue operations;
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
>  drivers/virtio/virtio_balloon.c | 135 ++++++++++++++++++++++++++++++++++++----
>  1 file changed, 123 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 0908e60..69eede7 100644
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
> @@ -52,15 +54,19 @@ struct virtio_balloon
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
>  	/*
> -	 * The pages we've told the Host we're not using.
> +	 * The pages we've told the Host we're not using are enqueued
> +	 * at vb_dev_info->pages list.
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
>  	 * to num_pages above.
>  	 */
> -	struct list_head pages;
> +	struct balloon_dev_info *vb_dev_info;
> +
> +	/* Synchronize access/update to this struct virtio_balloon elements */
> +	struct mutex balloon_lock;
>  
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
> -	u32 pfns[256];
> +	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
>  
>  	/* Memory statistics */
>  	int need_stats_update;
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
> @@ -141,7 +154,6 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		totalram_pages--;
> -		list_add(&page->lru, &vb->pages);
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> @@ -149,6 +161,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		return;
>  
>  	tell_host(vb, vb->inflate_vq);
> +	mutex_unlock(&vb->balloon_lock);
>  }
>  
>  static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
> @@ -165,14 +178,17 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
>  static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct page *page;
> +	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
>  
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		page = list_first_entry(&vb->pages, struct page, lru);
> -		list_del(&page->lru);
> +		page = balloon_page_dequeue(vb_dev_info);
> +		if (!page)
> +			break;
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -183,6 +199,7 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * is true, we *have* to do it in this order
>  	 */
>  	tell_host(vb, vb->deflate_vq);
> +	mutex_unlock(&vb->balloon_lock);
>  	release_pages_by_pfn(vb->pfns, vb->num_pfns);
>  }
>  
> @@ -339,9 +356,76 @@ static int init_vqs(struct virtio_balloon *vb)
>  	return 0;
>  }
>  
> +static const struct address_space_operations virtio_balloon_aops;
> +#ifdef CONFIG_BALLOON_COMPACTION
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
> + * Called through balloon_mapping->a_ops->migratepage
> + */
> +int virtballoon_migratepage(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	struct balloon_dev_info *vb_dev_info = balloon_page_device(page);
> +	struct virtio_balloon *vb;
> +	unsigned long flags;
> +
> +	BUG_ON(!vb_dev_info);
> +
> +	vb = vb_dev_info->balloon_device;
> +
> +	if (!mutex_trylock(&vb->balloon_lock))
> +		return -EAGAIN;
> +
> +	/* balloon's page migration 1st step  -- inflate "newpage" */
> +	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
> +	balloon_page_insert(newpage, mapping, &vb_dev_info->pages);
> +	vb_dev_info->isolated_pages--;
> +	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	set_page_pfns(vb->pfns, newpage);
> +	tell_host(vb, vb->inflate_vq);
> +
> +	/*
> +	 * balloon's page migration 2nd step -- deflate "page"
> +	 *
> +	 * It's safe to delete page->lru here because this page is at
> +	 * an isolated migration list, and this step is expected to happen here
> +	 */
> +	balloon_page_delete(page);
> +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	set_page_pfns(vb->pfns, page);
> +	tell_host(vb, vb->deflate_vq);
> +
> +	mutex_unlock(&vb->balloon_lock);
> +
> +	return MIGRATEPAGE_BALLOON_SUCCESS;
> +}
> +
> +/* define the balloon_mapping->a_ops callback to allow balloon page migration */
> +static const struct address_space_operations virtio_balloon_aops = {
> +			.migratepage = virtballoon_migratepage,
> +};
> +#endif /* CONFIG_BALLOON_COMPACTION */
> +
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	struct address_space *vb_mapping;
> +	struct balloon_dev_info *vb_devinfo;
>  	int err;
>  
>  	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
> @@ -350,16 +434,37 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		goto out;
>  	}
>  
> -	INIT_LIST_HEAD(&vb->pages);
>  	vb->num_pages = 0;
> +	mutex_init(&vb->balloon_lock);
>  	init_waitqueue_head(&vb->config_change);
>  	init_waitqueue_head(&vb->acked);
>  	vb->vdev = vdev;
>  	vb->need_stats_update = 0;
>  
> +	vb_devinfo = balloon_devinfo_alloc(vb);
> +	if (IS_ERR(vb_devinfo)) {
> +		err = PTR_ERR(vb_devinfo);
> +		goto out_free_vb;
> +	}
> +
> +	vb_mapping = balloon_mapping_alloc(vb_devinfo,
> +					   (balloon_compaction_check()) ?
> +					   &virtio_balloon_aops : NULL);
> +	if (IS_ERR(vb_mapping)) {
> +		/*
> +		 * IS_ERR(vb_mapping) && PTR_ERR(vb_mapping) == -EOPNOTSUPP
> +		 * This means !CONFIG_BALLOON_COMPACTION, otherwise we get off.
> +		 */
> +		err = PTR_ERR(vb_mapping);
> +		if (err != -EOPNOTSUPP)
> +			goto out_free_vb_devinfo;
> +	}
> +
> +	vb->vb_dev_info = vb_devinfo;
> +
>  	err = init_vqs(vb);
>  	if (err)
> -		goto out_free_vb;
> +		goto out_free_vb_mapping;
>  
>  	vb->thread = kthread_run(balloon, vb, "vballoon");
>  	if (IS_ERR(vb->thread)) {
> @@ -371,6 +476,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
> +out_free_vb_mapping:
> +	balloon_mapping_free(vb_mapping);
> +out_free_vb_devinfo:
> +	balloon_devinfo_free(vb_devinfo);
>  out_free_vb:
>  	kfree(vb);
>  out:
> @@ -396,6 +505,8 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
>  
>  	kthread_stop(vb->thread);
>  	remove_common(vb);
> +	balloon_mapping_free(vb->vb_dev_info->mapping);
> +	balloon_devinfo_free(vb->vb_dev_info);
>  	kfree(vb);
>  }
>  
> -- 
> 1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
