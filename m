Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 75D7F6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:22:29 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:22:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
Message-ID: <20130402022227.GE30444@blaptop>
References: <20130401132605.GA2996@kernel.org>
 <20130402012422.GB30444@blaptop>
 <20130402020357.GA832@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130402020357.GA832@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com

On Tue, Apr 02, 2013 at 10:03:57AM +0800, Shaohua Li wrote:
> On Tue, Apr 02, 2013 at 10:24:22AM +0900, Minchan Kim wrote:
> > Hi Shaohua,
> > 
> > On Mon, Apr 01, 2013 at 09:26:05PM +0800, Shaohua Li wrote:
> > > In page reclaim, huge page is split. split_huge_page() adds tail pages to LRU
> > > list. Since we are reclaiming a huge page, it's better we reclaim all subpages
> > > of the huge page instead of just the head page. This patch adds split tail
> > > pages to shrink page list so the tail pages can be reclaimed soon.
> > > 
> > > Before this patch, run a swap workload:
> > > thp_fault_alloc 3492
> > > thp_fault_fallback 608
> > > thp_collapse_alloc 6
> > > thp_collapse_alloc_failed 0
> > > thp_split 916
> > > 
> > > With this patch:
> > > thp_fault_alloc 4085
> > > thp_fault_fallback 16
> > > thp_collapse_alloc 90
> > > thp_collapse_alloc_failed 0
> > > thp_split 1272
> > > 
> > > fallback allocation is reduced a lot.
> > 
> > What I have a concern is that there is about spatial locality about 2M all pages
> > expecially, THP-always case. But yes, THP already have done it via
> > lru_add_page_tail and yours makes more sense if we really intended it.
> > 
> > But I didn't like passing page_list to split_huge_page, either.
> > Couldn't we do it in isolate_lru_pages in shrink_inactive_list?
> > Maybe, we can add new isolate_mode, ISOLATE_SPLIT_HUGEPAGE.
> > One problem I can see is deadlock of zone->lru_lock so maybe we have to
> > release the lock the work and re-hold it.
> 
> I'd prefer split huge page after page_check_references like what we do now.
> It's possible we don't want to reclaim (so split) the page at all.

Absolutely right you are!

We can check refereced bit in split_huge_page easily instead of
page_check_reference but for it, we have to introudce another
argument like split_huge_page(struct page, bool force) and moreover,
it needs additional argument for handling memcg aware.  

        splut_huge_page(struct page, struct mem_cgroup *memcg, bool force);

It's very ugly so I don't have any objection.
Sorry for the noise.

Acked-by: Minchan Kim <minchan@kernel.org>


> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
