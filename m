Date: Tue, 17 Apr 2007 05:09:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 6/9] mm: speculative get page
Message-ID: <20070417030916.GB25513@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103254.5564.84494.sendpatchset@linux.site> <Pine.LNX.4.64.0704161939510.12254@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704161939510.12254@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 16, 2007 at 07:54:03PM +0100, Hugh Dickins wrote:
> > --- linux-2.6.orig/include/linux/pagemap.h
> > +++ linux-2.6/include/linux/pagemap.h
> > ...
> > +static inline int page_cache_get_speculative(struct page *page)
> > +{
> > +	VM_BUG_ON(in_interrupt());
> > +
> > +#ifndef CONFIG_SMP
> > +# ifdef CONFIG_PREEMPT
> > +	VM_BUG_ON(!in_atomic());
> > +# endif
> > +	/*
> > +	 * Preempt must be disabled here - we rely on rcu_read_lock doing
> > +	 * this for us.
> > +	 *
> > +	 * Pagecache won't be truncated from interrupt context, so if we have
> > +	 * found a page in the radix tree here, we have pinned its refcount by
> > +	 * disabling preempt, and hence no need for the "speculative get" that
> > +	 * SMP requires.
> > +	 */
> > +	VM_BUG_ON(page_count(page) == 0);
> > +	atomic_inc(&page->_count);
> > +
> > +#else
> > +	if (unlikely(!get_page_unless_zero(page)))
> > +		return 0; /* page has been freed */
> 
> Now you're using get_page_unless_zero() here, you need to remove its
> 	VM_BUG_ON(PageCompound(page));
> since hugetlb_nopage() uses find_lock_page() on huge compound pages
> and so comes here (and you have a superior VM_BUG_ON further down).

Ah yes, I forgot about that assertion in there. Thanks!

> You could move that VM_BUG_ON to its original caller isolate_lru_pages(),
> or you could replace it by your superior check in get_page_unless_zero();
> but I'd be inclined to do the easiest and just cut it out now.

OK I'll do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
