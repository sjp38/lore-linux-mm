Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B3B586B00D9
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:47:59 -0400 (EDT)
Date: Tue, 2 Jun 2009 19:14:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090602111407.GA17234@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601140553.GA1979@localhost> <20090601144050.GA12099@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601144050.GA12099@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 10:40:51PM +0800, Nick Piggin wrote:
> On Mon, Jun 01, 2009 at 10:05:53PM +0800, Wu Fengguang wrote:
> > On Mon, Jun 01, 2009 at 07:50:46PM +0800, Nick Piggin wrote:
> > > The problem is that then you have lost synchronization in the
> > > pagecache. Nothing then prevents a new page from being put
> > > in there and trying to do IO to or from the same device as the
> > > currently running writeback.
> > 
> > [ I'm not setting mine mind to get rid of wait_on_page_writeback(),
> >   however I'm curious about the consequences of not doing it :)     ]
> > 
> > You are right in that IO can happen for a new page at the same file offset.
> > But I have analyzed that in another email:
> > 
> > : The reason truncate_inode_pages_range() has to wait on writeback page
> > : is to ensure data integrity. Otherwise if there comes two events:
> > :         truncate page A at offset X
> > :         populate page B at offset X
> > : If A and B are all writeback pages, then B can hit disk first and then
> > : be overwritten by A. Which corrupts the data at offset X from user's POV.
> > :
> > : But for hwpoison, there are no such worries. If A is poisoned, we do
> > : our best to isolate it as well as intercepting its IO. If the interception
> > : fails, it will trigger another machine check before hitting the disk.
> > :
> > : After all, poisoned A means the data at offset X is already corrupted.
> > : It doesn't matter if there comes another B page.
> > 
> > Does that make sense?
> 
> But you just said that you try to intercept the IO. So the underlying
> data is not necessarily corrupt. And even if it was then what if it
> was reinitialized to something else in the meantime (such as filesystem
> metadata blocks?) You'd just be introducing worse possibilities for
> coruption.

The IO interception will be based on PFN instead of file offset, so it
won't affect innocent pages such as your example of reinitialized data.

poisoned dirty page == corrupt data      => process shall be killed
poisoned clean page == recoverable data  => process shall survive

In the case of dirty hwpoison page, if we reload the on disk old data
and let application proceed with it, it may lead to *silent* data
corruption/inconsistency, because the application will first see v2
then v1, which is illogical and hence may mess up its internal data
structure.

> You will need to demonstrate a *big* advantage before doing crazy things
> with writeback ;)

OK. We can do two things about poisoned writeback pages:

1) to stop IO for them, thus avoid corrupted data to hit disk and/or
   trigger further machine checks
2) to isolate them from page cache, thus preventing possible
   references in the writeback time window

1) is important, because there may be many writeback pages in a
   production system.

2) is good to have if possible, because the time window may grow large
   when the writeback IO queue is congested or the async write
   requests are hold off by many sync read/write requests.

> > > > > But I just don't like this one file having all that required knowledge
> > > >
> > > > Yes that's a big problem.
> > > >
> > > > One major complexity involves classify the page into different known
> > > > types, by testing page flags, page_mapping, page_mapped, etc. This
> > > > is not avoidable.
> > >
> > > No.
> > 
> > If you don't know kind of page it is, how do we know to properly
> > isolate it? Or do you mean the current classifying code can be
> > simplified? Yeah that's kind of possible.
> 
> No I just was agreeing that it is not avoidable ;)

Ah OK.

> > > > Another major complexity is on calling the isolation routines to
> > > > remove references from
> > > >         - PTE
> > > >         - page cache
> > > >         - swap cache
> > > >         - LRU list
> > > > They more or less made some assumptions on their operating environment
> > > > that we have to take care of.  Unfortunately these complexities are
> > > > also not easily resolvable.
> > > >
> > > > > (and few comments) of all the files in mm/. If you want to get rid
> > > >
> > > > I promise I'll add more comments :)
> > >
> > > OK, but they should still go in their relevant files. Or as best as
> > > possible. Right now it's just silly to have all this here when much
> > > of it could be moved out to filemap.c, swap_state.c, page_alloc.c, etc.
> > 
> > OK, I'll bear that point in mind.
> > 
> > > > > of the page and don't care what it's count or dirtyness is, then
> > > > > truncate_inode_pages_range is the correct API to use.
> > > > >
> > > > > (or you could extract out some of it so you can call it directly on
> > > > > individual locked pages, if that helps).
> > > >
> > > > The patch to move over to truncate_complete_page() would like this.
> > > > It's not a big win indeed.
> > >
> > > No I don't mean to do this, but to move the truncate_inode_pages
> > > code for truncating a single, locked, page into another function
> > > in mm/truncate.c and then call that from here.
> > 
> > It seems to me that truncate_complete_page() is already the code
> > you want to move ;-) Or you mean more code around the call site of
> > truncate_complete_page()?
> > 
> >                         lock_page(page);
> > 
> >                         wait_on_page_writeback(page);
> > We could do this.
> > 
> >                         if (page_mapped(page)) {
> >                                 unmap_mapping_range(mapping,
> >                                   (loff_t)page->index<<PAGE_CACHE_SHIFT,
> >                                   PAGE_CACHE_SIZE, 0);
> >                         }
> > We need a rather complex unmap logic.
> > 
> >                         if (page->index > next)
> >                                 next = page->index;
> >                         next++;
> >                         truncate_complete_page(mapping, page);
> >                         unlock_page(page);
> > 
> > Now it's obvious that reusing more code than truncate_complete_page()
> > is not easy (or natural).
> 
> Just lock the page and wait for writeback, then do the truncate
> work in another function. In your case if you've already unmapped
> the page then it won't try to unmap again so no problem.
> 
> Truncating from pagecache does not change ->index so you can
> move the loop logic out.

Right. So effectively the reusable function is exactly
truncate_complete_page(). As I said this reuse is not a big gain.

> > > > Yes we could do wait_on_page_writeback() if necessary. The downside is,
> > > > keeping writeback page in page cache opens a small time window for
> > > > some one to access the page.
> > >
> > > AFAIKS there already is such a window? You're doing lock_page and such.
> > 
> > You know I'm such a crazy guy - I'm going to do try_lock_page() for
> > intercepting under read IOs 8-)
> > 
> > > No, it seems rather insane to do something like this here that no other
> > > code in the mm ever does.
> > 
> > Yes it's kind of insane.  I'm interested in reasoning it out though.
> 
> I guess it is a good idea to start simple.

Agreed.

> Considering that there are so many other types of pages that are
> impossible to deal with or have holes, then I very strongly doubt
> it will be worth so much complexity for closing the gap from 90%
> to 90.1%. But we'll see.

Yes, the plan is to first focus on the more important cases.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
