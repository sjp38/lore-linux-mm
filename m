Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 84F7E6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 20:26:31 -0400 (EDT)
Date: Thu, 23 Aug 2012 21:26:09 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120824002607.GF10777@t510.redhat.com>
References: <20120822093317.GC10680@redhat.com>
 <20120823021903.GA23660@x61.redhat.com>
 <20120823100107.GA17409@redhat.com>
 <20120823121338.GA3062@t510.redhat.com>
 <20120823123432.GA25659@redhat.com>
 <20120823130606.GB3746@t510.redhat.com>
 <20120823135328.GB25709@redhat.com>
 <20120823162504.GA1522@redhat.com>
 <20120823172844.GC10777@t510.redhat.com>
 <20120823233616.GB2775@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120823233616.GB2775@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Fri, Aug 24, 2012 at 02:36:16AM +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 23, 2012 at 02:28:45PM -0300, Rafael Aquini wrote:
> > On Thu, Aug 23, 2012 at 07:25:05PM +0300, Michael S. Tsirkin wrote:
> > > On Thu, Aug 23, 2012 at 04:53:28PM +0300, Michael S. Tsirkin wrote:
> > > > Basically it was very simple: we assumed page->lru was never
> > > > touched for an allocated page, so it's safe to use it for
> > > > internal book-keeping by the driver.
> > > > 
> > > > Now, this is not the case anymore, you add some logic in mm/ that might
> > > > or might not touch page->lru depending on things like reference count.
> > > 
> > > Another thought: would the issue go away if balloon used
> > > page->private to link pages instead of LRU?
> > > mm core could keep a reference on page to avoid it
> > > being used while mm handles it (maybe it does already?).
> > >
> > I don't think so. That would be a lot more trikier and complex, IMHO.
> 
> What's tricky? Linking pages through a void * orivate pointer?
> I can code it up in a couple of minutes.
> It's middle of the night so too tired to test but still:
> 
> > > If we do this, will not the only change to balloon be to tell mm that it
> > > can use compaction for these pages when it allocates the page: using
> > > some GPF flag or a new API?
> > > 
> > 
> > What about keep a conter at virtio_balloon structure on how much pages are
> > isolated from balloon's list and check it at leak time?
> > if the counter gets > 0 than we can safely put leak_balloon() to wait until
> > balloon page list gets completely refilled. I guess that is simple to get
> > accomplished and potentially addresses all your concerns on this issue.
> > 
> > Cheers!
> 
> I would wake it each time after adding a page, then it
> can stop waiting when it leaks enough.
> But again, it's cleaner to just keep tracking all
> pages, let mm hang on to them by keeping a reference.
> 
> --->
> 
> virtio-balloon: replace page->lru list with page->private.
> 
> The point is to free up page->lru for use by compaction.
> Warning: completely untested, will provide tested version
> if we agree on this direction.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>

This way balloon driver will potentially release pages that were already
migrated and doesn't belong to it anymore, since the page under migration never
gets isolated from balloon's page list. It's a lot more dangerous than it was
before. 

I'm working on having leak_balloon on the right way, as you correctly has
pointed. I was blind and biased. So, thank you for pointing me the way.


> ---
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 0908e60..b38f57ce 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -56,7 +56,7 @@ struct virtio_balloon
>  	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
>  	 * to num_pages above.
>  	 */
> -	struct list_head pages;
> +	void *pages;
>  
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
> @@ -141,7 +141,9 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		totalram_pages--;
> -		list_add(&page->lru, &vb->pages);
> +		/* Add to list of pages */
> +		page->private = vb->pages;
> +		vb->pages = page->private;
>  	}
>  
>  	/* Didn't get any?  Oh well. */
> @@ -171,8 +173,9 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		page = list_first_entry(&vb->pages, struct page, lru);
> -		list_del(&page->lru);
> +		/* Delete from list of pages */
> +		page = vb->pages;
> +		vb->pages = page->private;
>  		set_page_pfns(vb->pfns + vb->num_pfns, page);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -350,7 +353,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		goto out;
>  	}
>  
> -	INIT_LIST_HEAD(&vb->pages);
> +	vb->pages = NULL;
>  	vb->num_pages = 0;
>  	init_waitqueue_head(&vb->config_change);
>  	init_waitqueue_head(&vb->acked);
> -- 
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
