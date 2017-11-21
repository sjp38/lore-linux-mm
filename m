Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B55D96B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:06:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j6so5945133wre.16
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:06:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m21si933229edb.415.2017.11.21.07.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 Nov 2017 07:06:54 -0800 (PST)
Date: Tue, 21 Nov 2017 10:06:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, mlock, vmscan: no more skipping pagevecs
Message-ID: <20171121150632.GA23460@cmpxchg.org>
References: <20171104224312.145616-1-shakeelb@google.com>
 <577ab7e8-b079-125b-80ca-6168dd24720a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <577ab7e8-b079-125b-80ca-6168dd24720a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 21, 2017 at 01:39:57PM +0100, Vlastimil Babka wrote:
> On 11/04/2017 11:43 PM, Shakeel Butt wrote:
> > When a thread mlocks an address space backed by file, a new
> > page is allocated (assuming file page is not in memory), added
> > to the local pagevec (lru_add_pvec), I/O is triggered and the
> > thread then sleeps on the page. On I/O completion, the thread
> > can wake on a different CPU, the mlock syscall will then sets
> > the PageMlocked() bit of the page but will not be able to put
> > that page in unevictable LRU as the page is on the pagevec of
> > a different CPU. Even on drain, that page will go to evictable
> > LRU because the PageMlocked() bit is not checked on pagevec
> > drain.
> > 
> > The page will eventually go to right LRU on reclaim but the
> > LRU stats will remain skewed for a long time.
> > 
> > However, this issue does not happen for anon pages on swap
> > because unlike file pages, anon pages are not added to pagevec
> > until they have been fully swapped in. Also the fault handler
> > uses vm_flags to set the PageMlocked() bit of such anon pages
> > even before returning to mlock() syscall and mlocked pages will
> > skip pagevecs and directly be put into unevictable LRU. No such
> > luck for file pages.
> > 
> > One way to resolve this issue, is to somehow plumb vm_flags from
> > filemap_fault() to add_to_page_cache_lru() which will then skip
> > the pagevec for pages of VM_LOCKED vma and directly put them to
> > unevictable LRU. However this patch took a different approach.
> > 
> > All the pages, even unevictable, will be added to the pagevecs
> > and on the drain, the pages will be added on their LRUs correctly
> > by checking their evictability. This resolves the mlocked file
> > pages on pagevec of other CPUs issue because when those pagevecs
> > will be drained, the mlocked file pages will go to unevictable
> > LRU. Also this makes the race with munlock easier to resolve
> > because the pagevec drains happen in LRU lock.
> > 
> > There is one (good) side effect though. Without this patch, the
> > pages allocated for System V shared memory segment are added to
> > evictable LRUs even after shmctl(SHM_LOCK) on that segment. This
> > patch will correctly put such pages to unevictable LRU.
> > 
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> 
> I like the approach in general, as it seems to make the code simpler,
> and the diffstats support that. I found no bugs, but I can't say that
> with certainty that there aren't any, though. This code is rather
> tricky. But it should be enough for an ack, so.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> A question below, though.
> 
> ...
> 
> > @@ -883,15 +855,41 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
> >  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
> >  				 void *arg)
> >  {
> > -	int file = page_is_file_cache(page);
> > -	int active = PageActive(page);
> > -	enum lru_list lru = page_lru(page);
> > +	enum lru_list lru;
> > +	int was_unevictable = TestClearPageUnevictable(page);
> >  
> >  	VM_BUG_ON_PAGE(PageLRU(page), page);
> >  
> >  	SetPageLRU(page);
> > +	/*
> > +	 * Page becomes evictable in two ways:
> > +	 * 1) Within LRU lock [munlock_vma_pages() and __munlock_pagevec()].
> > +	 * 2) Before acquiring LRU lock to put the page to correct LRU and then
> > +	 *   a) do PageLRU check with lock [check_move_unevictable_pages]
> > +	 *   b) do PageLRU check before lock [isolate_lru_page]
> > +	 *
> > +	 * (1) & (2a) are ok as LRU lock will serialize them. For (2b), if the
> > +	 * other thread does not observe our setting of PG_lru and fails
> > +	 * isolation, the following page_evictable() check will make us put
> > +	 * the page in correct LRU.
> > +	 */
> > +	smp_mb();
> 
> Could you elaborate on the purpose of smp_mb() here? Previously there
> was "The other side is TestClearPageMlocked() or shmem_lock()" in
> putback_lru_page(), which seems rather unclear to me (neither has an
> explicit barrier?).

The TestClearPageMlocked() is an RMW operation with return value, and
thus an implicit full barrier (see Documentation/atomic_bitops.txt).

The ordering is between putback and munlock:

#0                         #1
list_add(&page->lru,...)   if (TestClearPageMlock())
SetPageLRU()                 __munlock_isolate_lru_page()
smp_mb()
if (page_evictable())
  rescue

The scenario that the barrier prevents from happening is:

list_add(&page->lru,...)
if (page_evictable())
   rescue
                           if (TestClearPageMlock())
                               __munlock_isolate_lru_page() // FAILS on !PageLRU
SetPageLRU()

and now an evictable page is stranded on the unevictable LRU.

The barrier guarantees that if #0 doesn't see the page evictable yet,
#1 WILL see the PageLRU and succeed in isolation and rescue.

Shakeel, please don't drop that "the other side" comment. You mention
the places that make the page evictable - which is great, and please
keep that as well - but for barriers it's always good to know exactly
which operation guarantees the ordering on the other side. In fact, it
would be great if you could add comments to the TestClearPageMlocked()
sites that mention how they order against the smp_mb() in LRU putback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
