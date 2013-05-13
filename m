Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id EB5BD6B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 01:22:22 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id i23so3342633dad.23
        for <linux-mm@kvack.org>; Sun, 12 May 2013 22:22:22 -0700 (PDT)
Date: Mon, 13 May 2013 13:22:16 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH] swap: add a simple detector for inappropriate swapin
 readahead
Message-ID: <20130513052216.GB1339@kernel.org>
References: <20130415040116.GA29875@kernel.org>
 <20130510125906.ae8fccaf8bc57bfd4fd59daa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130510125906.ae8fccaf8bc57bfd4fd59daa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hughd@google.com, khlebnikov@openvz.org, riel@redhat.com, fengguang.wu@intel.com, minchan@kernel.org

On Fri, May 10, 2013 at 12:59:06PM -0700, Andrew Morton wrote:
> On Mon, 15 Apr 2013 12:01:16 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> > This is a patch to improve swap readahead algorithm. It's from Hugh and I
> > slightly changed it.
> > 
> > ...
> >
> 
> I find the new code a bit harder to follow that it needs to be.

The patch detects random workload to avoid false readahead. For sequential
workload, it's known to be hard to do readahead, because we can't guarantee
memory of sequential workload live together in disk. The original blind
readahead doesn't work very well for sequential worload too. So the goal is to
not regress for sequential workload. There are some magics here for this. I'd
say I can't prove the magics are ok, but it just happens to work for simple
workload, sorry :)!

> > --- linux.orig/include/linux/page-flags.h	2013-04-12 15:07:05.011112763 +0800
> > +++ linux/include/linux/page-flags.h	2013-04-15 11:48:12.161080804 +0800
> > @@ -228,9 +228,9 @@ PAGEFLAG(OwnerPriv1, owner_priv_1) TESTC
> >  TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
> >  PAGEFLAG(MappedToDisk, mappedtodisk)
> >  
> > -/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
> > +/* PG_readahead is only used for reads; PG_reclaim is only for writes */
> >  PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
> > -PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
> > +PAGEFLAG(Readahead, reclaim) TESTCLEARFLAG(Readahead, reclaim)
> >  
> >  #ifdef CONFIG_HIGHMEM
> >  /*
> > Index: linux/mm/swap_state.c
> > ===================================================================
> > --- linux.orig/mm/swap_state.c	2013-04-12 15:07:05.003112912 +0800
> > +++ linux/mm/swap_state.c	2013-04-15 11:48:12.165078764 +0800
> > @@ -63,6 +63,8 @@ unsigned long total_swapcache_pages(void
> >  	return ret;
> >  }
> >  
> > +static atomic_t swapin_readahead_hits = ATOMIC_INIT(4);
> 
> Some documentation is needed here explaining this variable's role.  If
> that is understood then perhaps the reader will be able to work out why
> it was initialised to "4".  Or perhaps not. 

Ok, explained it, but the '4' is still a magic.

> >  void show_swap_cache_info(void)
> >  {
> >  	printk("%lu pages in swap cache\n", total_swapcache_pages());
> > @@ -286,8 +288,11 @@ struct page * lookup_swap_cache(swp_entr
> >  
> >  	page = find_get_page(swap_address_space(entry), entry.val);
> >  
> > -	if (page)
> > +	if (page) {
> >  		INC_CACHE_INFO(find_success);
> > +		if (TestClearPageReadahead(page))
> > +			atomic_inc(&swapin_readahead_hits);
> > +	}
> >  
> >  	INC_CACHE_INFO(find_total);
> >  	return page;
> > @@ -373,6 +378,50 @@ struct page *read_swap_cache_async(swp_e
> >  	return found_page;
> >  }
> >  
> > +unsigned long swapin_nr_pages(unsigned long offset)
> 
> Should be static.
> 
> Needs documentation explaining what it does and why.
> 
> It would probably be clearer to make `offset' have type pgoff_t. 
> What's what swp_offset() returned.  Ditto `entry_offset' in
> swapin_readahead().  It's not *really* a pgoff_t, but that's what we
> have and it's more informative than a bare ulong.
> 
> The documentation should describe the meaning of this function's return
> value.

done.
 
> > +{
> > +	static unsigned long prev_offset;
> > +	unsigned int pages, max_pages, last_ra;
> > +	static atomic_t last_readahead_pages;
> > +
> > +	max_pages = 1 << ACCESS_ONCE(page_cluster);
> > +	if (max_pages <= 1)
> > +		return 1;
> > +
> > +	/*
> > +	 * This heuristic has been found to work well on both sequential and
> > +	 * random loads, swapping to hard disk or to SSD: please don't ask
> > +	 * what the "+ 2" means, it just happens to work well, that's all.
> 
> OK, I won't.

Thanks :)
 
> > +	 */
> > +	pages = atomic_xchg(&swapin_readahead_hits, 0) + 2;
> > +	if (pages == 2) {
> > +		/*
> > +		 * We can have no readahead hits to judge by: but must not get
> > +		 * stuck here forever, so check for an adjacent offset instead
> > +		 * (and don't even bother to check whether swap type is same).
> > +		 */
> > +		if (offset != prev_offset + 1 && offset != prev_offset - 1)
> > +			pages = 1;
> > +		prev_offset = offset;
> > +	} else {
> > +		unsigned int roundup = 4;
> 
> What does the "4" mean?

The same magic.
 
> > +		while (roundup < pages)
> > +			roundup <<= 1;
> 
> Can use something like
> 
> 		roundup = ilog2(pages) + 2;
> 
> And what does the "2" mean?

ilog2 doesn't work here.
 
> > +		pages = roundup;
> > +	}
> > +
> > +	if (pages > max_pages)
> > +		pages = max_pages;
> 
> min()

ok
 
> > +	/* Don't shrink readahead too fast */
> > +	last_ra = atomic_read(&last_readahead_pages) / 2;
> 
> Why not "3"?

A magic again

> > +	if (pages < last_ra)
> > +		pages = last_ra;
> > +	atomic_set(&last_readahead_pages, pages);
> > +
> > +	return pages;
> > +}
> > +
> >  /**
> >   * swapin_readahead - swap in pages in hope we need them soon
> >   * @entry: swap entry of this memory
> > @@ -396,11 +445,16 @@ struct page *swapin_readahead(swp_entry_
> >  			struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	struct page *page;
> > -	unsigned long offset = swp_offset(entry);
> > +	unsigned long entry_offset = swp_offset(entry);
> > +	unsigned long offset = entry_offset;
> >  	unsigned long start_offset, end_offset;
> > -	unsigned long mask = (1UL << page_cluster) - 1;
> > +	unsigned long mask;
> >  	struct blk_plug plug;
> >  
> > +	mask = swapin_nr_pages(offset) - 1;
> 
> This I in fact found to be the most obscure part of the patch. 
> swapin_nr_pages() returns a count, but here we're copying it into a
> variable which appears to hold a bitmask.  That's a weird thing to do
> and only makes sense if it is assured (and designed) that
> swapin_nr_pages() returns a power of 2.

Yes, it's guaranteed to return a power of 2, now commented in patch.


---
 mm/swap_state.c |   33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2013-05-13 11:43:00.137490065 +0800
+++ linux/mm/swap_state.c	2013-05-13 13:18:44.573272832 +0800
@@ -63,6 +63,11 @@ unsigned long total_swapcache_pages(void
 	return ret;
 }
 
+/*
+ * Track how many swap readahead pages are truly hit. We readahead at least
+ * swapin_readahead_hits pages. The "4" is arbitary, if there are hits, at
+ * least readahead 4 pages.
+ */
 static atomic_t swapin_readahead_hits = ATOMIC_INIT(4);
 
 void show_swap_cache_info(void)
@@ -378,9 +383,20 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
-unsigned long swapin_nr_pages(unsigned long offset)
+/*
+ * Return how many swap pages should be readahead. This detects random workload
+ * to avoid false readahead. It's hard to correctly do readahead for sequential
+ * workload, as we can't guarantee memory of sequential workload live in disk
+ * sequentially. This still tries to readahead as more pages as possible if
+ * swapin readahead hits (for example, any hit causes at least 4 pages
+ * readahead; shrinking only allows shrink to half of last readahead pages).
+ *
+ * This is guaranteed to return power of 2 pages, as swapin_readahead reads
+ * ahead an aligned cluster.
+ */
+static unsigned long swapin_nr_pages(pgoff_t offset)
 {
-	static unsigned long prev_offset;
+	static pgoff_t prev_offset;
 	unsigned int pages, max_pages, last_ra;
 	static atomic_t last_readahead_pages;
 
@@ -410,13 +426,12 @@ unsigned long swapin_nr_pages(unsigned l
 		pages = roundup;
 	}
 
-	if (pages > max_pages)
-		pages = max_pages;
+	pages = min(pages, max_pages);
 
 	/* Don't shrink readahead too fast */
 	last_ra = atomic_read(&last_readahead_pages) / 2;
-	if (pages < last_ra)
-		pages = last_ra;
+	pages = max(pages, last_ra);
+
 	atomic_set(&last_readahead_pages, pages);
 
 	return pages;
@@ -445,9 +460,9 @@ struct page *swapin_readahead(swp_entry_
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
-	unsigned long entry_offset = swp_offset(entry);
-	unsigned long offset = entry_offset;
-	unsigned long start_offset, end_offset;
+	pgoff_t entry_offset = swp_offset(entry);
+	pgoff_t offset = entry_offset;
+	pgoff_t start_offset, end_offset;
 	unsigned long mask;
 	struct blk_plug plug;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
