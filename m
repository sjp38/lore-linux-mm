Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BDAC56B002B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 03:41:56 -0400 (EDT)
Date: Sun, 26 Aug 2012 10:42:44 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v9 3/5] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120826074244.GC19551@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
 <a1ceca79d95bc7de2a6b62a2e565b95286dbdf75.1345869378.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1ceca79d95bc7de2a6b62a2e565b95286dbdf75.1345869378.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sat, Aug 25, 2012 at 02:24:58AM -0300, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> Besides making balloon pages movable at allocation time and introducing
> the necessary primitives to perform balloon page migration/compaction,
> the patch changes the balloon bookeeping pages counter into an atomic
> counter, as well as it introduces the following locking scheme, in order to
> enhance the syncronization methods for accessing elements of struct
> virtio_balloon, thus providing protection against the concurrent accesses
> introduced by parallel memory compaction threads.
> 
>  - balloon_lock (mutex) : synchronizes the access demand to elements of
> 			  struct virtio_balloon and its queue operations;
>  - pages_lock (spinlock): special protection to balloon's pages bookmarking
> 			  elements (list and atomic counters) against the
> 			  potential memory compaction concurrency;
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

OK, this looks better.
Some comments below.

> ---
>  drivers/virtio/virtio_balloon.c | 286 +++++++++++++++++++++++++++++++++++++---
>  1 file changed, 265 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 0908e60..9b0bc46 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -27,6 +27,8 @@
>  #include <linux/delay.h>
>  #include <linux/slab.h>
>  #include <linux/module.h>
> +#include <linux/balloon_compaction.h>
> +#include <linux/atomic.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -34,6 +36,7 @@
>   * page units.
>   */
>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> +#define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
>  
>  struct virtio_balloon
>  {
> @@ -46,11 +49,24 @@ struct virtio_balloon
>  	/* The thread servicing the balloon. */
>  	struct task_struct *thread;
>  
> +	/* balloon special page->mapping */
> +	struct address_space *mapping;
> +
> +	/* Synchronize access/update to this struct virtio_balloon elements */
> +	struct mutex balloon_lock;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> +	/* Number of balloon pages isolated from 'pages' list for compaction */
> +	atomic_t num_isolated_pages;
> +
>  	/* Number of balloon pages we've told the Host we're not using. */
> -	unsigned int num_pages;
> +	atomic_t num_pages;
> +
> +	/* Protect pages list, and pages bookeeping counters */
> +	spinlock_t pages_lock;
> +
>  	/*
>  	 * The pages we've told the Host we're not using.
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
> @@ -60,7 +76,7 @@ struct virtio_balloon
>  
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
> -	u32 pfns[256];
> +	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
>  
>  	/* Memory statistics */
>  	int need_stats_update;
> @@ -122,13 +138,17 @@ static void set_page_pfns(u32 pfns[], struct page *page)
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
> @@ -139,9 +159,15 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  			break;
>  		}
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		totalram_pages--;
> +
> +		BUG_ON(!trylock_page(page));
> +		spin_lock(&vb->pages_lock);
>  		list_add(&page->lru, &vb->pages);
> +		assign_balloon_mapping(page, vb->mapping);
> +		atomic_add(VIRTIO_BALLOON_PAGES_PER_PAGE, &vb->num_pages);
> +		spin_unlock(&vb->pages_lock);
> +		unlock_page(page);
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> @@ -149,6 +175,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		return;
>  
>  	tell_host(vb, vb->inflate_vq);
> +	mutex_unlock(&vb->balloon_lock);
>  }
>  
>  static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
> @@ -162,19 +189,97 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
>  	}
>  }
>  
> +#ifdef CONFIG_BALLOON_COMPACTION
> +/* helper to __wait_on_isolated_pages() getting vb->pages list lenght */
> +static inline int __pages_at_balloon_list(struct virtio_balloon *vb)
> +{
> +	return atomic_read(&vb->num_pages) -
> +		atomic_read(&vb->num_isolated_pages);
> +}
> +

Reading two atomics and doing math? Result can even be negative.
I did not look at use closely but it looks suspicious.
It's already the case everywhere except __wait_on_isolated_pages,
so just fix that, and then we can keep using int instead of atomics.


> +/*
> + * __wait_on_isolated_pages - check if leak_balloon() must wait on isolated
> + *			      pages before proceeding with the page release.
> + * @vb         : pointer to the struct virtio_balloon describing this device.
> + * @leak_target: how many pages we are attempting to release this round.
> + *
> + * Shall only be called by leak_balloon() and under spin_lock(&vb->pages_lock);
> + */
> +static inline void __wait_on_isolated_pages(struct virtio_balloon *vb,
> +					    size_t leak_target)
> +{
> +	/*
> +	 * There are no isolated pages for this balloon device, or
> +	 * the leak target is smaller than # of pages on vb->pages list.
> +	 * No need to wait, then.
> +	 */

This just repeats what's below. So it does not help
at all, better drop it. But maybe you could explain
why does it make sense?

> +	if (!atomic_read(&vb->num_isolated_pages) ||
> +	    leak_target < __pages_at_balloon_list(vb))
> +		return;
> +	else {
> +		/*
> +		 * isolated pages are making our leak target bigger than the
> +		 * total pages that we can release this round. Let's wait for
> +		 * migration returning enough pages back to balloon's list.
> +		 */
> +		spin_unlock(&vb->pages_lock);
> +		wait_event(vb->config_change,
> +			   (!atomic_read(&vb->num_isolated_pages) ||
> +			    leak_target <= __pages_at_balloon_list(vb)));

Why did we repeat the logic above? optimization to skip lock/unlock?

> +		spin_lock(&vb->pages_lock);
> +	}
> +}
> +#else
> +#define __wait_on_isolated_pages(a, b)	do { } while (0)
> +#endif /* CONFIG_BALLOON_COMPACTION */
> +
>  static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
> -	struct page *page;
> +	int i;
> +	/* The array of pfns we tell the Host about. */
> +	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];

That's 1K on stack - and can become more if we increase
VIRTIO_BALLOON_ARRAY_PFNS_MAX.  Probably too much - this is the reason
we use vb->pfns.

> +	unsigned int num_pfns = 0;
>  
>  	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	size_t leak_target = num = min(num, ARRAY_SIZE(pfns));
>  
> -	for (vb->num_pfns = 0; vb->num_pfns < num;
> -	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		page = list_first_entry(&vb->pages, struct page, lru);
> -		list_del(&page->lru);
> -		set_page_pfns(vb->pfns + vb->num_pfns, page);
> -		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	while (num_pfns < num) {
> +		struct page *page = NULL;
> +
> +		spin_lock(&vb->pages_lock);
> +		/*
> +		 * leak_balloon() works releasing balloon pages by groups
> +		 * of 'VIRTIO_BALLOON_ARRAY_PFNS_MAX' size at each round.
> +		 * When compaction isolates pages from balloon page list,
> +		 * we might end up finding less pages on balloon's list than
> +		 * what is our desired 'leak_target'. If such occurrence
> +		 * happens, we shall wait for enough pages being re-inserted
> +		 * into balloon's page list before we proceed releasing them.
> +		 */
> +		__wait_on_isolated_pages(vb, leak_target);
> +
> +		if (!list_empty(&vb->pages))
> +			page = list_first_entry(&vb->pages, struct page, lru);
> +		/*
> +		 * Grab the page lock to avoid racing against threads isolating
> +		 * pages from, or migrating pages back to vb->pages list.
> +		 * (both tasks are done under page lock protection)
> +		 *
> +		 * Failing to grab the page lock here means this page is being
> +		 * isolated already, or its migration has not finished yet.
> +		 */
> +		if (page && trylock_page(page)) {
> +			clear_balloon_mapping(page);
> +			list_del(&page->lru);
> +			set_page_pfns(pfns + num_pfns, page);
> +			atomic_sub(VIRTIO_BALLOON_PAGES_PER_PAGE,
> +				   &vb->num_pages);
> +			num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
> +			unlock_page(page);
> +			/* compensate leak_target for this released page */
> +			leak_target--;
> +		}
> +		spin_unlock(&vb->pages_lock);
>  	}
>  
>  	/*
> @@ -182,8 +287,15 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> +	mutex_lock(&vb->balloon_lock);
> +
> +	for (i = 0; i < num; i++)
> +		vb->pfns[i] = pfns[i];
> +
> +	vb->num_pfns = num_pfns;
>  	tell_host(vb, vb->deflate_vq);
> -	release_pages_by_pfn(vb->pfns, vb->num_pfns);
> +	release_pages_by_pfn(pfns, num_pfns);
> +	mutex_unlock(&vb->balloon_lock);
>  }
>  
>  static inline void update_stat(struct virtio_balloon *vb, int idx,
> @@ -239,6 +351,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	struct scatterlist sg;
>  	unsigned int len;
>  
> +	mutex_lock(&vb->balloon_lock);
>  	vb->need_stats_update = 0;
>  	update_balloon_stats(vb);
>  
> @@ -249,6 +362,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
>  		BUG();
>  	virtqueue_kick(vq);
> +	mutex_unlock(&vb->balloon_lock);
>  }
>  
>  static void virtballoon_changed(struct virtio_device *vdev)
> @@ -267,12 +381,12 @@ static inline s64 towards_target(struct virtio_balloon *vb)
>  			      offsetof(struct virtio_balloon_config, num_pages),
>  			      &v, sizeof(v));
>  	target = le32_to_cpu(v);
> -	return target - vb->num_pages;
> +	return target - atomic_read(&vb->num_pages);
>  }
>  
>  static void update_balloon_size(struct virtio_balloon *vb)
>  {
> -	__le32 actual = cpu_to_le32(vb->num_pages);
> +	__le32 actual = cpu_to_le32(atomic_read(&vb->num_pages));
>  
>  	vb->vdev->config->set(vb->vdev,
>  			      offsetof(struct virtio_balloon_config, actual),
> @@ -339,9 +453,124 @@ static int init_vqs(struct virtio_balloon *vb)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_BALLOON_COMPACTION
> +/*
> + * virtballoon_isolatepage - perform the balloon page isolation on behalf of
> + *			     a compation thread.
> + *			     (must be called under page lock)

Better 'called under page lock' - driver is not supposed
to call this.

> + * @page: the page to isolated from balloon's page list.
> + * @mode: not used for balloon page isolation.
> + *
> + * A memory compaction thread works isolating pages from private lists,

by isolating pages

> + * like LRUs or the balloon's page list (here), to a privative pageset that
> + * will be migrated subsequently. After the mentioned pageset gets isolated
> + * compaction relies on page migration procedures to do the heavy lifting.
> + *
> + * This function populates a balloon_mapping->a_ops callback method to help
> + * a compaction thread on isolating a page from the balloon page list, and
> + * thus allowing its posterior migration.

This function isolates a page from the balloon private page list.
Called through balloon_mapping->a_ops.

> + */
> +void virtballoon_isolatepage(struct page *page, unsigned long mode)
> +{
> +	struct virtio_balloon *vb = __page_balloon_device(page);
> +
> +	BUG_ON(!vb);
> +
> +	spin_lock(&vb->pages_lock);
> +	list_del(&page->lru);
> +	atomic_inc(&vb->num_isolated_pages);
> +	spin_unlock(&vb->pages_lock);
> +}
> +
> +/*
> + * virtballoon_migratepage - perform the balloon page migration on behalf of
> + *			     a compation thread.
> + *			     (must be called under page lock)
> + * @mapping: the page->mapping which will be assigned to the new migrated page.
> + * @newpage: page that will replace the isolated page after migration finishes.
> + * @page   : the isolated (old) page that is about to be migrated to newpage.
> + * @mode   : compaction mode -- not used for balloon page migration.
> + *
> + * After a ballooned page gets isolated by compaction procedures, this is the
> + * function that performs the page migration on behalf of a compaction running
> + * thread.

of a compaction thread

> The page migration for virtio balloon is done in a simple swap
> + * fashion which follows these two macro steps:
> + *  1) insert newpage into vb->pages list and update the host about it;
> + *  2) update the host about the removed old page from vb->pages list;

the old page removed from

> + *
> + * This function populates a balloon_mapping->a_ops callback method to allow
> + * a compaction thread to perform the balloon page migration task.

This function preforms the balloon page migration task.
Called through balloon_mapping->a_ops.


> + */
> +int virtballoon_migratepage(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	struct virtio_balloon *vb = __page_balloon_device(page);
> +
> +	BUG_ON(!vb);
> +
> +	mutex_lock(&vb->balloon_lock);
> +
> +	/* balloon's page migration 1st step */
> +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	spin_lock(&vb->pages_lock);
> +	list_add(&newpage->lru, &vb->pages);
> +	assign_balloon_mapping(newpage, mapping);
> +	atomic_dec(&vb->num_isolated_pages);
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
> +
> +/*
> + * virtballoon_putbackpage - insert an isolated page back into the list it was
> + *			     once taken off by a compaction thread.
> + *			     (must be called under page lock)
> + * @page: page that will be re-inserted into balloon page list.
> + *
> + * If by any mean,

If for some reason

> a compaction thread cannot finish all its job on its round,

in one round

> + * and some isolated pages are still remaining at compaction's thread privative
> + * pageset (waiting for migration), then those pages will get re-inserted into
> + * their appropriate lists

appropriate -> private balloon

> before the compaction thread exits.

will exit.

> + *
> + * This function populates a balloon_mapping->a_ops callback method to help
> + * compaction on inserting back into the appropriate list an isolated but
> + * not migrated balloon page.

This function inserts an isolated but not migrated balloon page
back into private balloon list.
Called through balloon_mapping->a_ops.

> + */
> +void virtballoon_putbackpage(struct page *page)
> +{
> +	struct virtio_balloon *vb = __page_balloon_device(page);
> +
> +	BUG_ON(!vb);
> +
> +	spin_lock(&vb->pages_lock);
> +	list_add(&page->lru, &vb->pages);
> +	atomic_dec(&vb->num_isolated_pages);
> +	spin_unlock(&vb->pages_lock);
> +	wake_up(&vb->config_change);
> +}
> +#endif /* CONFIG_BALLOON_COMPACTION */
> +
> +/* define the balloon_mapping->a_ops callbacks to allow compaction/migration */
> +static DEFINE_BALLOON_MAPPING_AOPS(virtio_balloon_aops,
> +				   virtballoon_isolatepage,
> +				   virtballoon_migratepage,
> +				   virtballoon_putbackpage);
> +
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	struct address_space *vb_mapping;
>  	int err;
>  
>  	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
> @@ -351,15 +580,26 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	}
>  
>  	INIT_LIST_HEAD(&vb->pages);
> -	vb->num_pages = 0;
> +	mutex_init(&vb->balloon_lock);
> +	spin_lock_init(&vb->pages_lock);
> +
> +	atomic_set(&vb->num_pages, 0);
> +	atomic_set(&vb->num_isolated_pages, 0);
>  	init_waitqueue_head(&vb->config_change);
>  	init_waitqueue_head(&vb->acked);
>  	vb->vdev = vdev;
>  	vb->need_stats_update = 0;
>  
> +	vb_mapping = alloc_balloon_mapping(vb, &virtio_balloon_aops);
> +	if (!vb_mapping) {
> +		err = -ENOMEM;
> +		goto out_free_vb;
> +	}
> +	vb->mapping = vb_mapping;
> +
>  	err = init_vqs(vb);
>  	if (err)
> -		goto out_free_vb;
> +		goto out_free_vb_mapping;
>  
>  	vb->thread = kthread_run(balloon, vb, "vballoon");
>  	if (IS_ERR(vb->thread)) {
> @@ -371,6 +611,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
> +out_free_vb_mapping:
> +	kfree(vb_mapping);

We have alloc_balloon_mapping, it would be cleaner to have
free_balloon_mapping.

>  out_free_vb:
>  	kfree(vb);
>  out:
> @@ -379,9 +621,11 @@ out:
>  
>  static void remove_common(struct virtio_balloon *vb)
>  {
> +	size_t num_pages;
>  	/* There might be pages left in the balloon: free them. */
> -	while (vb->num_pages)
> -		leak_balloon(vb, vb->num_pages);
> +	while ((num_pages = atomic_read(&vb->num_pages)) > 0)
> +		leak_balloon(vb, num_pages);
> +
>  	update_balloon_size(vb);
>  
>  	/* Now we reset the device so we can clean up the queues. */
> @@ -396,6 +640,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
>  
>  	kthread_stop(vb->thread);
>  	remove_common(vb);
> +	kfree(vb->mapping);
>  	kfree(vb);
>  }
>  
> @@ -408,7 +653,6 @@ static int virtballoon_freeze(struct virtio_device *vdev)
>  	 * The kthread is already frozen by the PM core before this
>  	 * function is called.
>  	 */
> -
>  	remove_common(vb);
>  	return 0;
>  }
> -- 
> 1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
