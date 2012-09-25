Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 07E926B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 14:08:20 -0400 (EDT)
Date: Tue, 25 Sep 2012 15:07:49 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v10 3/5] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20120925180749.GB1638@optiplex.redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
 <39738cbd4b596714210e453440833db7cca73172.1347897793.git.aquini@redhat.com>
 <20120925004024.GA22665@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120925004024.GA22665@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Sep 25, 2012 at 02:40:24AM +0200, Michael S. Tsirkin wrote:
> > @@ -139,9 +158,15 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
> >  			break;
> >  		}
> >  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> > -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> >  		totalram_pages--;
> > +
> > +		BUG_ON(!trylock_page(page));
> 
> So here page lock is nested within balloon_lock.
> 
This page is coming from Buddy free-lists and as such, fill_balloon does not
race against page migration (which takes pages from an already isolated page list).
We need to grab page lock here, to prevent page isolation from happening while
this page is yet under "balloon insertion" step (mapping assign). Also, failing
to grab the page lock here (remember this page is coming from Buddy) means a
BUG.

I'll make sure to comment that on the code. Thanks for the nit.

> > +int virtballoon_migratepage(struct address_space *mapping,
> > +		struct page *newpage, struct page *page, enum migrate_mode mode)
> > +{
> > +	struct virtio_balloon *vb = __page_balloon_device(page);
> > +
> > +	BUG_ON(!vb);
> > +
> > +	mutex_lock(&vb->balloon_lock);
> 
> 
> While here balloon_lock is taken and according to documentation
> this is called under page lock.
> 
> So nesting is reversed which is normally a problem.
> Unfortunately lockep does not seem to work for page lock
> otherwise it would detect this.
> If this reversed nesting is not a problem, please add
> comments in code documenting that this is intentional
> and how it works.
>

The scheme works because we do not invert the page locking, actually. If we
stumble accross a locked page while holding mutex(balloon_lock) we just give up
that page for that round. The comment @ __leak_balloon explains that already:
----
+               /*
+                * Grab the page lock to avoid racing against threads isolating
+                * pages from, or migrating pages back to vb->pages list.
+                * (both tasks are done under page lock protection)
+                *
+                * Failing to grab the page lock here means this page is being
+                * isolated already, or its migration has not finished yet.
+                *
+                * We simply cannot afford to keep waiting on page lock here,
+                * otherwise we might cause a lock inversion and remain dead-
+                * locked with threads isolating/migrating pages.
+                * So, we give up this round if we fail to grab the page lock.
+                */
+               if (!trylock_page(page))
+                       break;
----

The otherwise is true as well. If the thread trying to isolate pages stumbles
across a balloon page already locked at leak_balloon, it gives up the isolation
step and mutex(&balloon_lock) is never attempted down the code path. Check this
isolate_balloon_page() snippet out:
----
+               /*
+                * As balloon pages are not isolated from LRU lists, concurrent
+                * compaction threads can race against page migration functions
+                * move_to_new_page() & __unmap_and_move().
+                * In order to avoid having an already isolated balloon page
+                * being (wrongly) re-isolated while it is under migration,
+                * lets be sure we have the page lock before proceeding with
+                * the balloon page isolation steps.
+                */
+               if (likely(trylock_page(page))) {
----

I'll rework the comment to indicate the leak_balloon() case as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
