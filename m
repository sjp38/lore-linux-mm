Date: Wed, 9 May 2007 15:28:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
In-Reply-To: <4641BFCE.6090200@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705091522110.15345@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
 <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
 <4641BFCE.6090200@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Nick Piggin wrote:
> Hugh Dickins wrote:
> > On Wed, 2 May 2007, Nick Piggin wrote:
> 
> > > >But I'm pretty sure (to use your words!) regular truncate was not racy
> > > >before: I believe Andrea's sequence count was handling that case fine,
> > > >without a second unmap_mapping_range.
> > >
> > >OK, I think you're right. I _think_ it should also be OK with the
> > >lock_page version as well: we should not be able to have any pages
> > >after the first unmap_mapping_range call, because of the i_size
> > >write. So if we have no pages, there is nothing to 'cow' from.
> > 
> > I'd be delighted if you can remove those later unmap_mapping_ranges.
> > As I recall, the important thing for the copy pages is to be holding
> > the page lock (or whatever other serialization) on the copied page
> > still while the copy page is inserted into pagetable: that looks
> > to be so in your __do_fault.
> 
> Hmm, on second thoughts, I think I was right the first time, and do
> need the unmap after the pages are truncated. With the lock_page code,
> after the first unmap, we can get new ptes mapping pages, and
> subsequently they can be COWed and then the original pte zapped before
> the truncate loop checks it.

The filesystem (or page cache) allows pages beyond i_size to come
in there?  That wasn't a problem before, was it?  But now it is?

> 
> However, I wonder if we can't test mapping_mapped before the spinlock,
> which would make most truncates cheaper?

Slightly cheaper, yes, though I doubt it'd be much in comparison with
actually doing any work in unmap_mapping_range or truncate_inode_pages.
Suspect you'd need a barrier of some kind between the i_size_write and
the mapping_mapped test?  But that's a change we could have made at
any time if we'd bothered, it's not really the issue here.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
