Date: Tue, 26 Oct 2004 10:24:19 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041026122419.GD27014@logos.cnet>
References: <20041025213923.GD23133@logos.cnet> <20041026.181504.38310112.taka@valinux.co.jp> <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041026.230110.21315175.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2004 at 11:01:10PM +0900, Hirokazu Takahashi wrote:
> Hi, Marcelo,
> 
> > > > diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
> > > > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-05 15:08:23.000000000 -0300
> > > > +++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-25 19:15:56.000000000 -0200
> > > > @@ -459,7 +457,9 @@ int shrink_list(struct list_head *page_l
> > > >  		}
> > > >  
> > > >  #ifdef CONFIG_SWAP
> > > > -		if (PageSwapCache(page)) {
> > > > +		// FIXME: allow relocation of migrate cache pages 
> > > > +		// into real swap pages for swapout.
> > > 
> > > 
> > > In my thought, it would be better to remove a target page from the
> > > LRU lists prior to migration. So that it makes the swap code not to
> > > grab the page, which is in the migration cache.
> > 
> > I dont see a problem with having the pages on LRU - the reclaiming 
> > code sees it, but its unfreeable, so it doesnt touch it. 
> > 
> > The reclaiming path should see its a migration page, unmap the pte's
> > to it, remap them to swapcache pages (and ptes), so they can be
> > swapped out on pressure.
> > 
> > Can you please expand your thoughts?
> 
> I thought the easiest way to avoid the race condition was
> removing the page from LRU during memory migration.
> But there may be no problem about the page, which is unfreeable
> as you mentioned.
> 
> BTW, I wonder how the migration code avoid to choose some pages
> on LRU, which may have count == 0. This may happen the pages
> are going to be removed. We have to care about it.

AFAICS its already done by __steal_page_from_lru(), which is used
by grab_capturing_pages():

static int
grab_capturing_pages(struct list_head *page_list, unsigned long start_pfn,
                                                        unsigned long nr_pages)
{
        struct page *page;
        struct zone *zone;
        int rest = 0;
        int i;
                                                                                    
        for (i = 0; i < nr_pages; i++) {
                page = pfn_to_page(start_pfn + i);
                zone = page_zone(page);
                spin_lock_irq(&zone->lru_lock);
                if (page_under_capture(page)) {
                        if (PageLRU(page) && __steal_page_from_lru(zone, page))
                                list_add(&page->lru, page_list);
                        else
                                rest++;
                }
                spin_unlock_irq(&zone->lru_lock);
        }
        return rest;
}


Pages with reference count zero will be not be moved to the page
list, and truncated pages seem to be handled nicely later on the
migration codepath.

A quick search on Iwamoto's test utils shows no sign of truncate(). 

It would be nice to add more testcases (such as truncate() 
intensive application) to his testsuite.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
