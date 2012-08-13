Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 581056B0069
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 04:40:29 -0400 (EDT)
Date: Mon, 13 Aug 2012 11:41:23 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120813084123.GF14081@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Fri, Aug 10, 2012 at 02:55:15PM -0300, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> Besides making balloon pages movable at allocation time and introducing
> the necessary primitives to perform balloon page migration/compaction,
> this patch also introduces the following locking scheme to provide the
> proper synchronization and protection for struct virtio_balloon elements
> against concurrent accesses due to parallel operations introduced by
> memory compaction / page migration.
>  - balloon_lock (mutex) : synchronizes the access demand to elements of
> 			  struct virtio_balloon and its queue operations;
>  - pages_lock (spinlock): special protection to balloon pages list against
> 			  concurrent list handling operations;
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c | 138 +++++++++++++++++++++++++++++++++++++---
>  include/linux/virtio_balloon.h  |   4 ++
>  2 files changed, 134 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 0908e60..7c937a0 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -27,6 +27,7 @@
>  #include <linux/delay.h>
>  #include <linux/slab.h>
>  #include <linux/module.h>
> +#include <linux/fs.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -35,6 +36,12 @@
>   */
>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
>  
> +/* Synchronizes accesses/updates to the struct virtio_balloon elements */
> +DEFINE_MUTEX(balloon_lock);
> +
> +/* Protects 'virtio_balloon->pages' list against concurrent handling */
> +DEFINE_SPINLOCK(pages_lock);
> +
>  struct virtio_balloon
>  {
>  	struct virtio_device *vdev;
> @@ -51,6 +58,7 @@ struct virtio_balloon
>  
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
> +
>  	/*
>  	 * The pages we've told the Host we're not using.
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
> @@ -125,10 +133,12 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
> -					__GFP_NOMEMALLOC | __GFP_NOWARN);
> +		struct page *page = alloc_page(GFP_HIGHUSER_MOVABLE |
> +						__GFP_NORETRY | __GFP_NOWARN |
> +						__GFP_NOMEMALLOC);
>  		if (!page) {
>  			if (printk_ratelimit())
>  				dev_printk(KERN_INFO, &vb->vdev->dev,
> @@ -141,7 +151,10 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		totalram_pages--;
> +		spin_lock(&pages_lock);
>  		list_add(&page->lru, &vb->pages);

If list_add above is reordered with mapping assignment below,
then nothing bad happens because balloon_mapping takes
pages_lock.

> +		page->mapping = balloon_mapping;
> +		spin_unlock(&pages_lock);
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> @@ -149,6 +162,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		return;
>  
>  	tell_host(vb, vb->inflate_vq);
> +	mutex_unlock(&balloon_lock);
>  }
>  
>  static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
> @@ -169,10 +183,22 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  	/* We can only do one array worth at a time. */
>  	num = min(num, ARRAY_SIZE(vb->pfns));
>  
> +	mutex_lock(&balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> +		/*
> +		 * We can race against virtballoon_isolatepage() and end up
> +		 * stumbling across a _temporarily_ empty 'pages' list.
> +		 */
> +		spin_lock(&pages_lock);
> +		if (unlikely(list_empty(&vb->pages))) {
> +			spin_unlock(&pages_lock);
> +			break;
> +		}
>  		page = list_first_entry(&vb->pages, struct page, lru);
> +		page->mapping = NULL;

Unlike the case above, here
if = NULL write above is reordered with list_del below,
then isolate_page can run on a page that is not
on lru.

So I think this needs a wmb().
And maybe a comment above explaining why it is safe?

>  		list_del(&page->lru);

I wonder why changing page->lru here is safe against
races with unmap_and_move in the previous patch.

> +		spin_unlock(&pages_lock);
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -182,8 +208,11 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	tell_host(vb, vb->deflate_vq);
> -	release_pages_by_pfn(vb->pfns, vb->num_pfns);
> +	if (vb->num_pfns > 0) {
> +		tell_host(vb, vb->deflate_vq);
> +		release_pages_by_pfn(vb->pfns, vb->num_pfns);
> +	}
> +	mutex_unlock(&balloon_lock);
>  }
>  
>  static inline void update_stat(struct virtio_balloon *vb, int idx,
> @@ -239,6 +268,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	struct scatterlist sg;
>  	unsigned int len;
>  
> +	mutex_lock(&balloon_lock);
>  	vb->need_stats_update = 0;
>  	update_balloon_stats(vb);
>  
> @@ -249,6 +279,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
>  		BUG();
>  	virtqueue_kick(vq);
> +	mutex_unlock(&balloon_lock);
>  }
>  
>  static void virtballoon_changed(struct virtio_device *vdev)
> @@ -261,22 +292,27 @@ static void virtballoon_changed(struct virtio_device *vdev)
>  static inline s64 towards_target(struct virtio_balloon *vb)
>  {
>  	__le32 v;
> -	s64 target;
> +	s64 target, actual;
>  
> +	mutex_lock(&balloon_lock);
> +	actual = vb->num_pages;
>  	vb->vdev->config->get(vb->vdev,
>  			      offsetof(struct virtio_balloon_config, num_pages),
>  			      &v, sizeof(v));
>  	target = le32_to_cpu(v);
> -	return target - vb->num_pages;
> +	mutex_unlock(&balloon_lock);
> +	return target - actual;
>  }
>  
>  static void update_balloon_size(struct virtio_balloon *vb)
>  {
> -	__le32 actual = cpu_to_le32(vb->num_pages);
> -
> +	__le32 actual;
> +	mutex_lock(&balloon_lock);
> +	actual = cpu_to_le32(vb->num_pages);
>  	vb->vdev->config->set(vb->vdev,
>  			      offsetof(struct virtio_balloon_config, actual),
>  			      &actual, sizeof(actual));
> +	mutex_unlock(&balloon_lock);
>  }
>  
>  static int balloon(void *_vballoon)
> @@ -339,6 +375,76 @@ static int init_vqs(struct virtio_balloon *vb)
>  	return 0;
>  }
>  
> +/*
> + * '*vb_ptr' allows virtballoon_migratepage() & virtballoon_putbackpage() to
> + * access pertinent elements from struct virtio_balloon
> + */

What if there is more than one balloon device?

> +struct virtio_balloon *vb_ptr;
> +
> +/*
> + * Populate balloon_mapping->a_ops->migratepage method to perform the balloon
> + * page migration task.
> + *
> + * After a ballooned page gets isolated by compaction procedures, this is the
> + * function that performs the page migration on behalf of move_to_new_page(),
> + * when the last calls (page)->mapping->a_ops->migratepage.
> + *
> + * Page migration for virtio balloon is done in a simple swap fashion which
> + * follows these two steps:
> + *  1) insert newpage into vb->pages list and update the host about it;
> + *  2) update the host about the removed old page from vb->pages list;
> + */
> +int virtballoon_migratepage(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	mutex_lock(&balloon_lock);
> +
> +	/* balloon's page migration 1st step */
> +	vb_ptr->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	spin_lock(&pages_lock);
> +	list_add(&newpage->lru, &vb_ptr->pages);
> +	spin_unlock(&pages_lock);
> +	set_page_pfns(vb_ptr->pfns, newpage);
> +	tell_host(vb_ptr, vb_ptr->inflate_vq);
> +
> +	/* balloon's page migration 2nd step */
> +	vb_ptr->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +	set_page_pfns(vb_ptr->pfns, page);
> +	tell_host(vb_ptr, vb_ptr->deflate_vq);
> +
> +	mutex_unlock(&balloon_lock);
> +
> +	return 0;
> +}
> +
> +/*
> + * Populate balloon_mapping->a_ops->invalidatepage method to help compaction on
> + * isolating a page from the balloon page list.
> + */
> +void virtballoon_isolatepage(struct page *page, unsigned long mode)
> +{
> +	spin_lock(&pages_lock);
> +	list_del(&page->lru);
> +	spin_unlock(&pages_lock);
> +}
> +
> +/*
> + * Populate balloon_mapping->a_ops->freepage method to help compaction on
> + * re-inserting an isolated page into the balloon page list.
> + */
> +void virtballoon_putbackpage(struct page *page)
> +{
> +	spin_lock(&pages_lock);
> +	list_add(&page->lru, &vb_ptr->pages);
> +	spin_unlock(&pages_lock);

Could the following race trigger:
migration happens while module unloading is in progress,
module goes away between here and when the function
returns, then code for this function gets overwritten?
If yes we need locking external to module to prevent this.
Maybe add a spinlock to struct address_space?

> +}
> +
> +static const struct address_space_operations virtio_balloon_aops = {
> +	.migratepage = virtballoon_migratepage,
> +	.invalidatepage = virtballoon_isolatepage,
> +	.freepage = virtballoon_putbackpage,
> +};
> +
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> @@ -351,11 +457,25 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	}
>  
>  	INIT_LIST_HEAD(&vb->pages);
> +
>  	vb->num_pages = 0;
>  	init_waitqueue_head(&vb->config_change);
>  	init_waitqueue_head(&vb->acked);
>  	vb->vdev = vdev;
>  	vb->need_stats_update = 0;
> +	vb_ptr = vb;
> +
> +	/* Init the ballooned page->mapping special balloon_mapping */
> +	balloon_mapping = kmalloc(sizeof(*balloon_mapping), GFP_KERNEL);
> +	if (!balloon_mapping) {
> +		err = -ENOMEM;
> +		goto out_free_vb;
> +	}

Can balloon_mapping be dereferenced at this point?
Then what happens?

> +
> +	INIT_RADIX_TREE(&balloon_mapping->page_tree, GFP_ATOMIC | __GFP_NOWARN);
> +	INIT_LIST_HEAD(&balloon_mapping->i_mmap_nonlinear);
> +	spin_lock_init(&balloon_mapping->tree_lock);
> +	balloon_mapping->a_ops = &virtio_balloon_aops;
>  
>  	err = init_vqs(vb);
>  	if (err)
> @@ -373,6 +493,7 @@ out_del_vqs:
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
>  	kfree(vb);
> +	kfree(balloon_mapping);

No need to set it to NULL? It seems if someone else allocates a mapping
and gets this chunk of memory by chance, the logic in mm will get
confused.

>  out:
>  	return err;
>  }
> @@ -397,6 +518,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
>  	kthread_stop(vb->thread);
>  	remove_common(vb);
>  	kfree(vb);
> +	kfree(balloon_mapping);

Neither here?

>  }
>  
>  #ifdef CONFIG_PM
> diff --git a/include/linux/virtio_balloon.h b/include/linux/virtio_balloon.h
> index 652dc8b..930f1b7 100644
> --- a/include/linux/virtio_balloon.h
> +++ b/include/linux/virtio_balloon.h
> @@ -56,4 +56,8 @@ struct virtio_balloon_stat {
>  	u64 val;
>  } __attribute__((packed));
>  
> +#if !defined(CONFIG_COMPACTION)
> +struct address_space *balloon_mapping;
> +#endif
> +

Anyone including this header will get a different copy of
balloon_mapping. Besides, need to be ifdef KERNEL.

>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> -- 
> 1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
