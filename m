Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 031E56B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 22:34:37 -0500 (EST)
Date: Mon, 2 Nov 2009 04:34:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] [PATCH] Avoid livelock for fsync
Message-ID: <20091102033429.GB28207@wotan.suse.de>
References: <20091026181314.GE7233@duck.suse.cz> <20091028144731.b46a3341.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028144731.b46a3341.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, WU Fengguang <wfg@mail.ustc.edu.cn>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 02:47:31PM -0700, Andrew Morton wrote:
> On Mon, 26 Oct 2009 19:13:14 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> >   Hi,
> > 
> >   on my way back from Kernel Summit, I've coded the attached patch which
> > implements livelock avoidance for write_cache_pages. We tag patches that
> > should be written in the beginning of write_cache_pages and then write
> > only tagged pages (see the patch for details). The patch is based on Nick's
> > idea.
> >   The next thing I've aimed at with this patch is a simplification of
> > current writeback code. Basically, with this patch I think we can just rip
> > out all the range_cyclic and nr_to_write (or other "fairness logic"). The
> > rationalle is following:
> >   What we want to achieve with fairness logic is that when a page is
> > dirtied, it gets written to disk within some reasonable time (like 30s or
> > so). We track dirty time on per-inode basis only because keeping it
> > per-page is simply too expensive. So in this setting fairness between
> > inodes really does not make any sence - why should be a page in a file
> > penalized and written later only because there are lots of other dirty
> > pages in the file? It is enough to make sure that we don't write one file
> > indefinitely when there are new dirty pages continuously created - and my
> > patch achieves that.
> >   So with my patch we can make write_cache_pages always write from
> > range_start (or 0) to range_end (or EOF) and write all tagged pages. Also
> > after changing balance_dirty_pages() so that a throttled process does not
> > directly submit the IO (Fengguang has the patches for this), we can
> > completely remove the nr_to_write logic because nothing really uses it
> > anymore. Thus also the requeue_io logic should go away etc...
> >   Fengguang, do you have the series somewhere publicly available? You had
> > there a plenty of changes and quite some of them are not needed when the
> > above is done. So could you maybe separate out the balance_dirty_pages
> > change and I'd base my patch and further simplifications on top of that?
> > Thanks.
> > 
> 
> I need to think about this.  Hard.
> 
> So I'll defer that and nitpick the implementation instead ;)
> 
> My MUA doesn't understand text/x-patch.  Please use text/plain if you
> must use attachments?
> 
> 	
>  /**
> > + * tag_pages_for_writeback - tag pages to be written by write_cache_pages
> > + * @mapping: address space structure to write
> > + * @start: starting page index
> > + * @end: ending page index (inclusive)
> > + *
> > + * This function scans the page range from @start to @end and tags all pages
> > + * that have DIRTY tag set with a special TOWRITE tag. The idea is that
> > + * write_cache_pages (or whoever calls this function) will then use TOWRITE tag
> > + * to identify pages eligible for writeback.  This mechanism is used to avoid
> > + * livelocking of writeback by a process steadily creating new dirty pages in
> > + * the file (thus it is important for this function to be damn quick so that it
> > + * can tag pages faster than a dirtying process can create them).
> > + */
> > +void tag_pages_for_writeback(struct address_space *mapping,
> > +			     pgoff_t start, pgoff_t end)
> > +{
> > +	struct pagevec pvec;
> > +	int nr_pages, i;
> > +	struct page *page;
> > +
> > +	pagevec_init(&pvec, 0);
> > +	while (start <= end) {
> > +		nr_pages = pagevec_lookup_tag(&pvec, mapping, &start,
> > +			      PAGECACHE_TAG_DIRTY,
> > +			      min(end - start, (pgoff_t)PAGEVEC_SIZE-1) + 1);
> > +		if (!nr_pages)
> > +			return;
> > +
> > +		spin_lock_irq(&mapping->tree_lock);
> > +		for (i = 0; i < nr_pages; i++) {
> > +			page = pvec.pages[i];
> > +			/* Raced with someone freeing the page? */
> > +			if (page->mapping != mapping)
> > +				continue;
> > +			if (page->index > end)
> > +				break;
> > +			radix_tree_tag_set(&mapping->page_tree,
> > +				page_index(page), PAGECACHE_TAG_TOWRITE);
> > +		}
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +	}
> > +}
> > +EXPORT_SYMBOL(tag_pages_for_writeback);
> 
> This is really inefficient.  We do a full tree descent for each dirty
> page.
> 
> It would be far more efficient to do a combined lookup and set
> operation.  Bascially that's the same as pagevec_lookup_tag(), only we
> set the PAGECACHE_TAG_TOWRITE on each page instead of taking a copy
> into the pagevec.

I had a radix_tree_gang_set_if_tagged operation in my earlier
patchset, which should basically do this.

 
> Which makes one wonder: would such an operation require ->tree_lock? 
> pagevec_lookup_tag() just uses rcu_read_lock() - what do we need to do
> to use lighter locking in the new
> radix_tree_gang_lookup_tag_slot_then_set_a_flag()?  Convert tag_set()
> and tag_clear() to atomic ops, perhaps?

Well that, but the hard part is propagating the tag back to the root
in a coherent way (when other guys are setting and clearing tags in
other nodes). Also, if we have more than a couple of atomic bitops,
then the spinlock will win out in straight line performance (although
scalability could still be better with an unlocked version... but I
think the propagation is the hard part).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
