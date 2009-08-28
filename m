Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC306B00B3
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:57:10 -0400 (EDT)
Date: Fri, 28 Aug 2009 13:57:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
Message-ID: <20090828125719.GE5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie> <1251449067-3109-3-git-send-email-mel@csn.ul.ie> <84144f020908280516y6473a531n3f11f3e86251eba4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020908280516y6473a531n3f11f3e86251eba4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 03:16:34PM +0300, Pekka Enberg wrote:
> Hi Mel,
> 
> On Fri, Aug 28, 2009 at 11:44 AM, Mel Gorman<mel@csn.ul.ie> wrote:
> > -               page = list_entry(list->prev, struct page, lru);
> > -               /* have to delete it as __free_one_page list manipulates */
> > -               list_del(&page->lru);
> > -               trace_mm_page_pcpu_drain(page, 0, migratetype);
> > -               __free_one_page(page, zone, 0, migratetype);
> > +               do {
> > +                       page = list_entry(list->prev, struct page, lru);
> > +                       /* must delete as __free_one_page list manipulates */
> > +                       list_del(&page->lru);
> > +                       __free_one_page(page, zone, 0, migratetype);
> > +                       trace_mm_page_pcpu_drain(page, 0, migratetype);
> 
> This calls trace_mm_page_pcpu_drain() *after* __free_one_page(). It's
> probably not a good idea as __free_one_page() can alter the struct
> page in various ways.
> 

While true, does it alter the struct page in any way that matters?

> 
> > +               } while (--count && --batch_free && !list_empty(list));
> >        }
> >        spin_unlock(&zone->lock);
> >  }
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
