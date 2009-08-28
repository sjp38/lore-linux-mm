Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E221A6B00B5
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:02:46 -0400 (EDT)
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
 free from the PCP
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090828125719.GE5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
	 <84144f020908280516y6473a531n3f11f3e86251eba4@mail.gmail.com>
	 <20090828125719.GE5054@csn.ul.ie>
Date: Fri, 28 Aug 2009 16:02:44 +0300
Message-Id: <1251464564.8514.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Fri, 2009-08-28 at 13:57 +0100, Mel Gorman wrote:
> On Fri, Aug 28, 2009 at 03:16:34PM +0300, Pekka Enberg wrote:
> > Hi Mel,
> > 
> > On Fri, Aug 28, 2009 at 11:44 AM, Mel Gorman<mel@csn.ul.ie> wrote:
> > > -               page = list_entry(list->prev, struct page, lru);
> > > -               /* have to delete it as __free_one_page list manipulates */
> > > -               list_del(&page->lru);
> > > -               trace_mm_page_pcpu_drain(page, 0, migratetype);
> > > -               __free_one_page(page, zone, 0, migratetype);
> > > +               do {
> > > +                       page = list_entry(list->prev, struct page, lru);
> > > +                       /* must delete as __free_one_page list manipulates */
> > > +                       list_del(&page->lru);
> > > +                       __free_one_page(page, zone, 0, migratetype);
> > > +                       trace_mm_page_pcpu_drain(page, 0, migratetype);
> > 
> > This calls trace_mm_page_pcpu_drain() *after* __free_one_page(). It's
> > probably not a good idea as __free_one_page() can alter the struct
> > page in various ways.
> > 
> 
> While true, does it alter the struct page in any way that matters?

Page flags and order are probably interesting for tracing?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
