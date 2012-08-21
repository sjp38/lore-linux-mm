Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 671556B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 16:46:18 -0400 (EDT)
Date: Tue, 21 Aug 2012 17:45:56 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120821204556.GF12294@t510.redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
 <1345562411.23018.111.camel@twins>
 <20120821162432.GG2456@linux.vnet.ibm.com>
 <20120821172819.GA12294@t510.redhat.com>
 <20120821191330.GA8324@redhat.com>
 <20120821192357.GD12294@t510.redhat.com>
 <20120821193031.GC9027@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120821193031.GC9027@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 21, 2012 at 10:30:31PM +0300, Michael S. Tsirkin wrote:
> On Tue, Aug 21, 2012 at 04:23:58PM -0300, Rafael Aquini wrote:
> > On Tue, Aug 21, 2012 at 10:13:30PM +0300, Michael S. Tsirkin wrote:
> > > > 
> > > > I believe rcu_dereference_protected() is what I want/need here, since this code
> > > > is always called for pages which we hold locked (PG_locked bit).
> > > 
> > > It would only help if we locked the page while updating the mapping,
> > > as far as I can see we don't.
> > >
> > 
> > But we can do it. In fact, by doing it (locking the page) we can easily avoid
> > the nasty race balloon_isolate_page / leak_balloon, in a much simpler way, IMHO.
> 
> Absolutely. Further, we should look hard at whether most RCU uses
> in this patchset can be replaced with page lock.
>

Yeah, In fact, by testing/grabbing the page lock at leak_balloon() even the
module unload X migration / putback race seems to fade away, since migration
code holds the page locked all the way.

And that seems a quite easy task to be accomplished:

....
@@ -169,21 +197,61 @@ static void leak_balloon(struct virtio_balloon *vb, size_t
num)
        /* We can only do one array worth at a time. */
        num = min(num, ARRAY_SIZE(vb->pfns));

+       mutex_lock(&vb->balloon_lock);
        for (vb->num_pfns = 0; vb->num_pfns < num;
             vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
+               spin_lock(&vb->pages_lock);
+               /*
+                * 'virtballoon_isolatepage()' can drain vb->pages list
+                * making us to stumble across a _temporarily_ empty list.
+                *
+                * Release the spinlock and resume from here in order to
+                * give page migration a shot to refill vb->pages list.
+                */
+               if (unlikely(list_empty(&vb->pages))) {
+                       spin_unlock(&vb->pages_lock);
+                       break;
+               }
+
                page = list_first_entry(&vb->pages, struct page, lru);
+
+               /*
+                * Grab the page lock to avoid racing against threads isolating
+                * pages from vb->pages list (it's done under page lock).
+                *
+                * Failing to grab the page lock here means this page has been
+                * selected for isolation already.
+                */
+               if (!trylock_page(page)) {
+                       spin_unlock(&vb->pages_lock);
+                       break;
+               }
+
+               clear_balloon_mapping(page);
                list_del(&page->lru);
                set_page_pfns(vb->pfns + vb->num_pfns, page);
                vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
+               unlock_page(page);
+               spin_unlock(&vb->pages_lock);
        }

.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
