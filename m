Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 962666B00B7
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 05:08:56 -0500 (EST)
Date: Tue, 9 Mar 2010 10:08:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] page-allocator: Check zone pressure when batch of
	pages are freed
Message-ID: <20100309100835.GA4883@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-3-git-send-email-mel@csn.ul.ie> <20100309095342.GD8653@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100309095342.GD8653@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 08:53:42PM +1100, Nick Piggin wrote:
> Cool, you found this doesn't hurt performance too much?
> 

Nothing outside the noise was measured. I didn't profile it to be
absolutly sure but I expect it's ok.

> Can't you remove the check from the reclaim code now? (The check
> here should give a more timely wait anyway)
> 

I'll try and see what the timing and total IO figures look like.

> This is good because it should eliminate most all cases of extra
> waiting. I wonder if you've also thought of doing the check in the
> allocation path too as we were discussing? (this would give a better
> FIFO behaviour under memory pressure but I could easily agree it is not
> worth the cost)
> 

I *could* make the check but as I noted in the leader, there isn't
really a good test case that determines if these changes are "good" or
"bad". Removing congestion_wait() seems like an obvious win but other
modifications that alter how and when processes wait are less obvious.

> On Mon, Mar 08, 2010 at 11:48:22AM +0000, Mel Gorman wrote:
> > When a batch of pages have been freed to the buddy allocator, it is possible
> > that it is enough to push a zone above its watermarks. This patch puts a
> > check in the free path for zone pressure. It's in a common path but for
> > the most part, it should only be checking if a linked list is empty and
> > have minimal performance impact.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1383ff9..3c8e8b7 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -562,6 +562,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  		} while (--count && --batch_free && !list_empty(list));
> >  	}
> >  	spin_unlock(&zone->lock);
> > +
> > +	/* A batch of pages have been freed so check zone pressure */
> > +	check_zone_pressure(zone);
> >  }
> >  
> >  static void free_one_page(struct zone *zone, struct page *page, int order,
> > -- 
> > 1.6.5
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
