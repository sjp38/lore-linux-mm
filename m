Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5A4D56B002B
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 10:51:10 -0500 (EST)
Date: Sat, 10 Nov 2012 17:53:19 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 5/7] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20121110155319.GA13846@redhat.com>
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
Cc: Rusty Russell <rusty@rustcorp.com.au>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

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
> allocation.

Do you mean this one:
        if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
 ?

In practice it never triggers an allocation, we can pass in
GFP_ATOMIC just as well.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
