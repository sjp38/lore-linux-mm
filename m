Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6469B6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:27:38 -0400 (EDT)
Date: Mon, 15 Jun 2009 18:16:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/22] HWPOISON: check and isolate corrupted free pages
	v2
Message-ID: <20090615101620.GA7216@localhost>
References: <20090615024520.786814520@intel.com> <20090615031253.715406280@intel.com> <20090615184112.ed8e2f03.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615184112.ed8e2f03.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 05:41:12PM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 15 Jun 2009 10:45:30 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > If memory corruption hits the free buddy pages, we can safely ignore them.
> > No one will access them until page allocation time, then prep_new_page()
> > will automatically check and isolate PG_hwpoison page for us (for 0-order
> > allocation).
> > 
> > This patch expands prep_new_page() to check every component page in a high
> > order page allocation, in order to completely stop PG_hwpoison pages from
> > being recirculated.
> > 
> > Note that the common case -- only allocating a single page, doesn't
> > do any more work than before. Allocating > order 0 does a bit more work,
> > but that's relatively uncommon.
> > 
> > This simple implementation may drop some innocent neighbor pages, hopefully
> > it is not a big problem because the event should be rare enough.
> > 
> > This patch adds some runtime costs to high order page users.
> > 
> > [AK: Improved description]
> > 
> > v2: Andi Kleen:
> > Port to -mm code
> > Move check into separate function.
> > Don't dump stack in bad_pages for hwpoisoned pages.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > ---
> >  mm/page_alloc.c |   20 +++++++++++++++++++-
> >  1 file changed, 19 insertions(+), 1 deletion(-)
> > 
> > --- sound-2.6.orig/mm/page_alloc.c
> > +++ sound-2.6/mm/page_alloc.c
> > @@ -233,6 +233,12 @@ static void bad_page(struct page *page)
> >  	static unsigned long nr_shown;
> >  	static unsigned long nr_unshown;
> >  
> > +	/* Don't complain about poisoned pages */
> > +	if (PageHWPoison(page)) {
> > +		__ClearPageBuddy(page);
> > +		return;
> > +	}
> 
> Hmm ? why __ClearPageBuddy() is necessary ?

Because this page is considered to be "allocated" out of the buddy
system, even though we fail the allocation here.

The page is now owned by no one, especially not owned by the buddy
allocator.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
