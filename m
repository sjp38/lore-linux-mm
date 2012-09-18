Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 3FD0F6B0073
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:07:35 -0400 (EDT)
Date: Tue, 18 Sep 2012 11:07:12 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v10 3/5] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20120918140711.GA1645@optiplex.redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
 <39738cbd4b596714210e453440833db7cca73172.1347897793.git.aquini@redhat.com>
 <20120917151552.ffbb9293.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120917151552.ffbb9293.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Sep 17, 2012 at 03:15:52PM -0700, Andrew Morton wrote:
> > +	/* Number of balloon pages isolated from 'pages' list for compaction */
> > +	unsigned int num_isolated_pages;
> 
> Is it utterly inconceivable that this counter could exceed 4G, ever?
> 
> >  	/* Number of balloon pages we've told the Host we're not using. */
> >  	unsigned int num_pages;

I've just followed the same unit the driver writers had used to keep track of
how many pages are 'enlisted' to a given balloon device (num_pages). As
compaction can not isolate more pages than what a balloon device possess, yes,
num_isolated_pages won't get bigger than 4G pages.



> > +	mutex_lock(&vb->balloon_lock);
> >  	for (vb->num_pfns = 0; vb->num_pfns < num;
> >  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > -		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
> > -					__GFP_NOMEMALLOC | __GFP_NOWARN);
> > +		struct page *page = alloc_page(vb_gfp_mask | __GFP_NORETRY |
> > +					       __GFP_NOWARN | __GFP_NOMEMALLOC);
> 
> That looks like an allocation which could easily fail.
>

That's not a big problem. If we fail that allocation and miss the desired 
balloon 'inflation' target at this round, the driver will take care of it
later, as it keeps chasing its targets.


 
> >  		if (!page) {
> >  			if (printk_ratelimit())
> >  				dev_printk(KERN_INFO, &vb->vdev->dev,
> 
> Strangely, we suppressed the core page allocator's warning and
> substituted this less useful one.
> 
> Also, it would be nice if someone could get that printk_ratelimit() out
> of there, for reasons described at the printk_ratelimit() definition
> site.
> 

Despite I agree 100% with you here, (IMHO) that was a change out of the scope 
for this patchseries original purposes and so I didn't propose it.

OTOH, I don't mind in introducing the aforementioned surgery by this patch, 
if the balloon driver folks are OK with it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
