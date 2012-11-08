Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AE8E56B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 19:32:24 -0500 (EST)
Date: Wed, 7 Nov 2012 22:32:01 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 5/7] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20121108003159.GD10444@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
 <87625h3tl1.fsf@rustcorp.com.au>
 <20121107161146.b99dc4a8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121107161146.b99dc4a8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Nov 07, 2012 at 04:11:46PM -0800, Andrew Morton wrote:
> On Thu, 08 Nov 2012 09:32:18 +1030
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > Rafael Aquini <aquini@redhat.com> writes:
> > > + * virtballoon_migratepage - perform the balloon page migration on behalf of
> > > + *			     a compation thread.     (called under page lock)
> > 
> > > +	if (!mutex_trylock(&vb->balloon_lock))
> > > +		return -EAGAIN;
> > 
> > Erk, OK...
> 
> Not really.  As is almost always the case with a trylock, it needs a
> comment explaining why we couldn't use the far superior mutex_lock(). 
> Data: this reader doesn't know!
>


That was just to alleviate balloon_lock contention if we're migrating pages
concurrently with balloon_fill() or balloon_leak(), as it's easier to retry
the page migration later (in the contended case).

 
> > > +	/* balloon's page migration 1st step  -- inflate "newpage" */
> > > +	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
> > > +	balloon_page_insert(newpage, mapping, &vb_dev_info->pages);
> > > +	vb_dev_info->isolated_pages--;
> > > +	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> > > +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> > > +	set_page_pfns(vb->pfns, newpage);
> > > +	tell_host(vb, vb->inflate_vq);
> > 
> > tell_host does wait_event(), so you can't call it under the page_lock.
> > Right?
> 
> Sleeping inside lock_page() is OK.  More problematic is that GFP_KERNEL
> allocation.  iirc it _should_ be OK.  Core VM uses trylock_page() and
> the filesystems shouldn't be doing a synchronous lock_page() in the
> pageout path.  But I suspect it isn't a well-tested area.


The locked page under migration is not contended by any other FS / core VM path,
as it is already isolated by compaction to a private migration page list.
OTOH, there's a chance of another parallel compaction thread hitting this page
while scanning page blocks for isolation, but that path can be considered safe
as it uses trylock_page()



> 
> > You probably get away with it because current qemu will service you
> > immediately.  You could spin here in this case for the moment.
> > 
> > There's a second call to tell_host():
> > 
> > > +	/*
> > > +	 * balloon's page migration 2nd step -- deflate "page"
> > > +	 *
> > > +	 * It's safe to delete page->lru here because this page is at
> > > +	 * an isolated migration list, and this step is expected to happen here
> > > +	 */
> > > +	balloon_page_delete(page);
> > > +	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> > > +	set_page_pfns(vb->pfns, page);
> > > +	tell_host(vb, vb->deflate_vq);
> > 
> > The first one can be delayed, the second one can be delayed if the host
> > didn't ask for VIRTIO_BALLOON_F_MUST_TELL_HOST (qemu doesn't).
> > 
> > We could implement a proper request queue for these, and return -EAGAIN
> > if the queue fills.  Though in practice, it's not important (it might
> > help performance).
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
