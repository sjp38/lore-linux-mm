Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CADE26B00B4
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:57:30 -0400 (EDT)
Date: Mon, 1 Jun 2009 20:32:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090601183225.GS1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601115046.GE5018@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 01:50:46PM +0200, Nick Piggin wrote:
> > Another major complexity is on calling the isolation routines to
> > remove references from
> >         - PTE
> >         - page cache
> >         - swap cache
> >         - LRU list
> > They more or less made some assumptions on their operating environment
> > that we have to take care of.  Unfortunately these complexities are
> > also not easily resolvable.
> > 
> > > (and few comments) of all the files in mm/. If you want to get rid
> > 
> > I promise I'll add more comments :)
> 
> OK, but they should still go in their relevant files. Or as best as
> possible. Right now it's just silly to have all this here when much
> of it could be moved out to filemap.c, swap_state.c, page_alloc.c, etc.

Can you be more specific what that "all this" is? 

> > > of the page and don't care what it's count or dirtyness is, then
> > > truncate_inode_pages_range is the correct API to use.
> > >
> > > (or you could extract out some of it so you can call it directly on
> > > individual locked pages, if that helps).
> >  
> > The patch to move over to truncate_complete_page() would like this.
> > It's not a big win indeed.
> 
> No I don't mean to do this, but to move the truncate_inode_pages
> code for truncating a single, locked, page into another function
> in mm/truncate.c and then call that from here.

I took a look at that.  First there's no direct equivalent of
me_pagecache_clean/dirty in truncate.c and to be honest I don't
see a clean way to refactor any of the existing functions to 
do the same.

Then memory-failure already calls into the other files for
pretty much anything interesting (do_invalidatepage, cancel_dirty_page,
try_to_free_mapping) -- there is very little that memory-failure.c
does on its own.

These are also all already called from all over the kernel, e.g.
there are 15+ callers of try_to_release_page outside truncate.c

For do_invalidatepage and cancel_dirty_page it's not as clear cut, but there's 
already precendence of several callers outside truncate.c.

We could presumably move the swap cache functions, but given how simple
they are and just also calling direct into the swap code anyways, is there
much value in it? Hugh, can you give guidance?

static int me_swapcache_dirty(struct page *p)
{
        ClearPageDirty(p);

        if (!isolate_lru_page(p))
                page_cache_release(p);

        return DELAYED;
}

static int me_swapcache_clean(struct page *p)
{
        ClearPageUptodate(p);

        if (!isolate_lru_page(p))
                page_cache_release(p);

        delete_from_swap_cache(p);

        return RECOVERED;
}


>  
> > > > Clean swap cache pages can be directly isolated. A later page fault will bring
> > > > in the known good data from disk.
> > > 
> > > OK, but why do you ClearPageUptodate if it is just to be deleted from
> > > swapcache anyway?
> > 
> > The ClearPageUptodate() is kind of a careless addition, in the hope
> > that it will stop some random readers. Need more investigations.
> 
> OK. But it just muddies the waters in the meantime, so maybe take
> such things out until there is a case for them.

It's gone

> > > > > You haven't waited on writeback here AFAIKS, and have you
> > > > > *really* verified it is safe to call delete_from_swap_cache?
> > > > 
> > > > Good catch. I'll soon submit patches for handling the under
> > > > read/write IO pages. In this patchset they are simply ignored.
> > > 
> > > Well that's quite important ;) I would suggest you just wait_on_page_writeback.
> > > It is simple and should work. _Unless_ you can show it is a big problem that
> > > needs equivalently big mes to fix ;)
> > 
> > Yes we could do wait_on_page_writeback() if necessary. The downside is,
> > keeping writeback page in page cache opens a small time window for
> > some one to access the page.
> 
> AFAIKS there already is such a window? You're doing lock_page and such.

Yes there already is plenty of window.

> No, it seems rather insane to do something like this here that no other
> code in the mm ever does.

Just because the rest of the VM doesn't do it doesn't mean it might make sense.

But the writeback windows are probably too short to careing. I haven't
done numbers on those, if it's a significant percentage of memory in 
some workload it might be worth it, otherwise not.

But all of that would be in the future, right now I just want to get
the basic facility in.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
