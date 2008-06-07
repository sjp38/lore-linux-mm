Date: Sat, 07 Jun 2008 14:38:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
In-Reply-To: <20080606180746.6c2b5288.akpm@linux-foundation.org>
References: <20080606202859.522708682@redhat.com> <20080606180746.6c2b5288.akpm@linux-foundation.org>
Message-Id: <20080607142504.9C4F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Hi

> > +	if (!isolate_lru_page(page)) {
> > +		putback_lru_page(page);
> > +	} else {
> > +		/*
> > +		 * Try hard not to leak this page ...
> > +		 */
> > +		lru_add_drain_all();
> > +		if (!isolate_lru_page(page))
> > +			putback_lru_page(page);
> > +	}
> > +}
> 
> When I review code I often come across stuff which I don't understand
> (at least, which I don't understand sufficiently easily).  So I'll ask
> questions, and I do think the best way in which those questions should
> be answered is by adding a code comment to fix the problem for ever.
> 
> When I look at the isolate_lru_page()-failed cases above I wonder what
> just happened.  We now have a page which is still on the LRU (how did
> it get there in the first place?). Well no.  I _think_ what happened is
> that this function is using isolate_lru_page() and putback_lru_page()
> to move a page off a now-inappropriate LRU list and to put it back onto
> the proper one.  But heck, maybe I just don't know what this function
> is doing at all?
> 
> If I _am_ right, and if the isolate_lru_page() _did_ fail (and under
> what circumstances?) then...  what?  We now have a page which is on an
> inappropriate LRU?  Why is this OK?  Do we handle it elsewhere?  How?

I think this code is OK, 
but "Try hard not to leak this page ..." is wrong comment and not true.

isolate_lru_page() failure mean this page is isolated by another one.
later, Another one put back page to proper LRU by putback_lru_page().
(putback_lru_page() alway put back right LRU.)

no leak happebnd.



> > +static int __mlock_vma_pages_range(struct vm_area_struct *vma,
> > +			unsigned long start, unsigned long end)
> > +{
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	unsigned long addr = start;
> > +	struct page *pages[16]; /* 16 gives a reasonable batch */
> > +	int write = !!(vma->vm_flags & VM_WRITE);
> > +	int nr_pages = (end - start) / PAGE_SIZE;
> > +	int ret;
> > +
> > +	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
> > +	VM_BUG_ON(start < vma->vm_start || end > vma->vm_end);
> > +	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
> > +
> > +	lru_add_drain_all();	/* push cached pages to LRU */
> > +
> > +	while (nr_pages > 0) {
> > +		int i;
> > +
> > +		cond_resched();
> > +
> > +		/*
> > +		 * get_user_pages makes pages present if we are
> > +		 * setting mlock.
> > +		 */
> > +		ret = get_user_pages(current, mm, addr,
> > +				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> > +				write, 0, pages, NULL);
> 
> Doesn't mlock already do a make_pages_present(), or did that get
> removed and moved to here?

I think, 

vanilla:     call make_pages_present() when mlock.
this series: call __mlock_vma_pages_range() when mlock.

thus, this code is right.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
