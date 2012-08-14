Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id ACD206B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 15:50:41 -0400 (EDT)
Date: Tue, 14 Aug 2012 22:51:39 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120814195139.GA28870@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
 <20120813084123.GF14081@redhat.com>
 <20120814182244.GB13338@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120814182244.GB13338@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 14, 2012 at 03:22:45PM -0300, Rafael Aquini wrote:
> On Mon, Aug 13, 2012 at 11:41:23AM +0300, Michael S. Tsirkin wrote:
> > > @@ -141,7 +151,10 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
> > >  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> > >  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > >  		totalram_pages--;
> > > +		spin_lock(&pages_lock);
> > >  		list_add(&page->lru, &vb->pages);
> > 
> > If list_add above is reordered with mapping assignment below,
> > then nothing bad happens because balloon_mapping takes
> > pages_lock.
> > 
> > > +		page->mapping = balloon_mapping;
> > > +		spin_unlock(&pages_lock);
> > >  	}
> > >  
> > >  	/* Didn't get any?  Oh well. */
> > > @@ -149,6 +162,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
> > >  		return;
> > >  
> > >  	tell_host(vb, vb->inflate_vq);
> > > +	mutex_unlock(&balloon_lock);
> > >  }
> > >  
> > >  static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
> > > @@ -169,10 +183,22 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
> > >  	/* We can only do one array worth at a time. */
> > >  	num = min(num, ARRAY_SIZE(vb->pfns));
> > >  
> > > +	mutex_lock(&balloon_lock);
> > >  	for (vb->num_pfns = 0; vb->num_pfns < num;
> > >  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > > +		/*
> > > +		 * We can race against virtballoon_isolatepage() and end up
> > > +		 * stumbling across a _temporarily_ empty 'pages' list.
> > > +		 */
> > > +		spin_lock(&pages_lock);
> > > +		if (unlikely(list_empty(&vb->pages))) {
> > > +			spin_unlock(&pages_lock);
> > > +			break;
> > > +		}
> > >  		page = list_first_entry(&vb->pages, struct page, lru);
> > > +		page->mapping = NULL;
> > 
> > Unlike the case above, here
> > if = NULL write above is reordered with list_del below,
> > then isolate_page can run on a page that is not
> > on lru.
> > 
> > So I think this needs a wmb().
> > And maybe a comment above explaining why it is safe?
> 
> Good point. Presumably, this nit has potential to explain your guessing on the
> read barrier stuff at movable_balloon_page() on the other patch.
> 


What I think you should do is use rcu for access.
And here sync rcu before freeing.
Maybe an overkill but at least a documented synchronization
primitive, and it is very light weight.

> > >  		list_del(&page->lru);
> > 
> > I wonder why changing page->lru here is safe against
> > races with unmap_and_move in the previous patch.
> 
> leak_balloon() doesn't race against unmap_and_move() because the later works on
> an isolated page set. So, theoretically, pages being dequeued from balloon page
> list here are either migrated (already) or they were not isolated yet.
> 

So add a comment explaining why it is safe pls.

> > > +/*
> > > + * '*vb_ptr' allows virtballoon_migratepage() & virtballoon_putbackpage() to
> > > + * access pertinent elements from struct virtio_balloon
> > > + */
> > 
> > What if there is more than one balloon device?
> 
> Is it possible to load this driver twice, or are you foreseeing a future case
> where this driver will be able to manage several distinct memory balloons for
> the same guest?
> 

Second.
It is easy to create several balloons they are just
pci devices.

> > > +	/* Init the ballooned page->mapping special balloon_mapping */
> > > +	balloon_mapping = kmalloc(sizeof(*balloon_mapping), GFP_KERNEL);
> > > +	if (!balloon_mapping) {
> > > +		err = -ENOMEM;
> > > +		goto out_free_vb;
> > > +	}
> > 
> > Can balloon_mapping be dereferenced at this point?
> > Then what happens?
> 
> Since there's no balloon page enqueued for this balloon driver yet, there's no
> chance of balloon_mapping being dereferenced at this point.
> 
>  
> > > +
> > > +	INIT_RADIX_TREE(&balloon_mapping->page_tree, GFP_ATOMIC | __GFP_NOWARN);
> > > +	INIT_LIST_HEAD(&balloon_mapping->i_mmap_nonlinear);
> > > +	spin_lock_init(&balloon_mapping->tree_lock);
> > > +	balloon_mapping->a_ops = &virtio_balloon_aops;
> > >  
> > >  	err = init_vqs(vb);
> > >  	if (err)
> > > @@ -373,6 +493,7 @@ out_del_vqs:
> > >  	vdev->config->del_vqs(vdev);
> > >  out_free_vb:
> > >  	kfree(vb);
> > > +	kfree(balloon_mapping);
> > 
> > No need to set it to NULL? It seems if someone else allocates a mapping
> > and gets this chunk of memory by chance, the logic in mm will get
> > confused.
> 
> Good point. It surely doesn't hurt be asured of this sort of safety.
> 
> > >  out:
> > >  	return err;
> > >  }
> > > @@ -397,6 +518,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
> > >  	kthread_stop(vb->thread);
> > >  	remove_common(vb);
> > >  	kfree(vb);
> > > +	kfree(balloon_mapping);
> > 
> > Neither here?
> 
> ditto.
> 
>  
> > >  }
> > >  
> > >  #ifdef CONFIG_PM
> > > diff --git a/include/linux/virtio_balloon.h b/include/linux/virtio_balloon.h
> > > index 652dc8b..930f1b7 100644
> > > --- a/include/linux/virtio_balloon.h
> > > +++ b/include/linux/virtio_balloon.h
> > > @@ -56,4 +56,8 @@ struct virtio_balloon_stat {
> > >  	u64 val;
> > >  } __attribute__((packed));
> > >  
> > > +#if !defined(CONFIG_COMPACTION)
> > > +struct address_space *balloon_mapping;
> > > +#endif
> > > +
> > 
> > Anyone including this header will get a different copy of
> > balloon_mapping. Besides, need to be ifdef KERNEL.
> 
> Good point. I'll move this hunk to the balloon driver itself.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
