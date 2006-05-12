Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060511213045.32b41aa6.akpm@osdl.org>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	 <1147116034.16600.2.camel@lappy>
	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
	 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
	 <4463EA16.5090208@cyberone.com.au>  <20060511213045.32b41aa6.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 12 May 2006 09:06:01 +0200
Message-Id: <1147417561.8951.17.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, clameter@sgi.com, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-11 at 21:30 -0700, Andrew Morton wrote:
> Nick Piggin <piggin@cyberone.com.au> wrote:
> >
> >  >So let's see.  We take a write fault, we mark the page dirty then we return
> >  >to userspace which will proceed with the write and will mark the pte dirty.
> >  >
> >  >Later, the VM will write the page out.
> >  >
> >  >Later still, the pte will get cleaned by reclaim or by munmap or whatever
> >  >and the page will be marked dirty and the page will again be written out. 
> >  >Potentially needlessly.
> >  >
> > 
> >  page_wrprotect also marks the page clean,
> 
> Oh.  I missed that when reading the comment which describes
> page_wrprotect() (I do go on).

Yes, this name is not the best of names :-(

I was aware of this, but since in my mind the counting through
protection 
faults was the prime idea, I stuck to page_wrprotect().

But I'm hard pressed to come up with a better one. Nick proposes:
 page_mkclean()
But that also doesn't cover the whole of it from my perspective.

> > so this window is very small.
> >  The window is that the fault path might set_page_dirty, then throttle
> >  on writeout, and the page gets written out before it really gets dirtied
> >  by the application (which then has to fault again).
> 
> : int test_clear_page_dirty(struct page *page)
> : {
> : 	struct address_space *mapping = page_mapping(page);
> : 	unsigned long flags;
> : 
> : 	if (mapping) {
> : 		write_lock_irqsave(&mapping->tree_lock, flags);
> : 		if (TestClearPageDirty(page)) {
> : 			radix_tree_tag_clear(&mapping->page_tree,
> : 						page_index(page),
> : 						PAGECACHE_TAG_DIRTY);
> : 			write_unlock_irqrestore(&mapping->tree_lock, flags);
> : 			/*
> : 			 * We can continue to use `mapping' here because the
> : 			 * page is locked, which pins the address_space
> : 			 */
> 
> So if userspace modifies the page right here, and marks the pte dirty.
> 
> : 			if (mapping_cap_account_dirty(mapping)) {
> : 				page_wrprotect(page);
> 
> We just lost that pte dirty bit, and hence the user's data.

I thought that at the time we clean PAGECACHE_TAG_DIRTY the page is in
flight to disk.
Now that I look at it again, perhaps the page_wrprotect() call in
clear_page_dirty_for_io()
should be in test_set_page_writeback().

> : 				dec_page_state(nr_dirty);
> : 			}
> : 			return 1;
> : 		}
> : 		write_unlock_irqrestore(&mapping->tree_lock, flags);
> : 		return 0;
> : 	}
> : 	return TestClearPageDirty(page);
> : }
> : 
> 
> Which is just the sort of subtle and nasty problem I was referring to...
> 
> If that's correct then I guess we need the
> 
>                 if (ptep_clear_flush_dirty(vma, addr, pte) ||
>                                 page_test_and_clear_dirty(page))
>                         ret += set_page_dirty(page);
> 
> treatment in page_wrprotect().

I would make that a BUG_ON(); the only way for a pte of a shared mapping
to become 
dirty is through the fault handler, and that should already call
set_page_dirty() on it.

> Now I suppose it's not really a dataloss race, because in practice the
> kernel is about to write this page to backing store anwyay.  I guess.  I
> cannot immediately think of any clear_page_dirty() callers for whom that
> won't be true.
> 
> Someone please convince me that this has all been thought about and is solid
> as a rock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
