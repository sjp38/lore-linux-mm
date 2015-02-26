Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBBD6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 19:42:18 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so8736790pdb.9
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:42:18 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id kn11si7844983pbd.148.2015.02.25.16.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 16:42:17 -0800 (PST)
Received: by pdbfl12 with SMTP id fl12so8792267pdb.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:42:17 -0800 (PST)
Date: Thu, 26 Feb 2015 09:42:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150226004206.GA16773@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <20150225071118.GA19115@blaptop>
 <20150225183748.GA2551@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150225183748.GA2551@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Yalin.Wang@sonymobile.com

Hello,

On Wed, Feb 25, 2015 at 10:37:48AM -0800, Shaohua Li wrote:
> On Wed, Feb 25, 2015 at 04:11:18PM +0900, Minchan Kim wrote:
> > On Wed, Feb 25, 2015 at 09:08:09AM +0900, Minchan Kim wrote:
> > > Hi Michal,
> > > 
> > > On Tue, Feb 24, 2015 at 04:43:18PM +0100, Michal Hocko wrote:
> > > > On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> > > > > Recently, Shaohua reported that MADV_FREE is much slower than
> > > > > MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> > > > > applications went to stall with direct reclaim since kswapd's
> > > > > reclaim speed isn't fast than applications's allocation speed
> > > > > so that it causes lots of stall and lock contention.
> > > > 
> > > > I am not sure I understand this correctly. So the issue is that there is
> > > > huge number of MADV_FREE on the LRU and they are not close to the tail
> > > > of the list so the reclaim has to do a lot of work before it starts
> > > > dropping them?
> > > 
> > > No, Shaohua already tested deactivating of hinted pages to head/tail
> > > of inactive anon LRU and he said it didn't solve his problem.
> > > I thought main culprit was scanning/rotating/throttling in
> > > direct reclaim path.
> > 
> > I investigated my workload and found most of slowness came from swapin.
> > 
> > 1) dontneed: 1,612 swapin
> > 2) madvfree: 879,585 swapin
> > 
> > If we find hinted pages were already swapped out when syscall is called,
> > it's pointless to keep the pages in pte. Instead, free the cold page
> > because swapin is more expensive than (alloc page + zeroing).
> > 
> > I tested below quick fix and reduced swapin from 879,585 to 1,878.
> > Elapsed time was
> > 
> > 1) dontneed: 6.10user 233.50system 0:50.44elapsed
> > 2) madvfree + below patch: 6.70user 339.14system 1:04.45elapsed
> > 
> > Although it was not good as throttling, it's better than old and
> > it's orthogoral with throttling so I hope to merge this first
> > than arguable throttling. Any comments?
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 6d0fcb8921c2..d41ae76d3e54 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -274,7 +274,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  	spinlock_t *ptl;
> >  	pte_t *pte, ptent;
> >  	struct page *page;
> > +	swp_entry_t entry;
> >  	unsigned long next;
> > +	int rss = 0;
> >  
> >  	next = pmd_addr_end(addr, end);
> >  	if (pmd_trans_huge(*pmd)) {
> > @@ -293,9 +295,19 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  	for (; addr != end; pte++, addr += PAGE_SIZE) {
> >  		ptent = *pte;
> >  
> > -		if (!pte_present(ptent))
> > +		if (pte_none(ptent))
> >  			continue;
> >  
> > +		if (!pte_present(ptent)) {
> > +			entry = pte_to_swp_entry(ptent);
> > +			if (non_swap_entry(entry))
> > +				continue;
> > +			rss--;
> > +			free_swap_and_cache(entry);
> > +			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> > +			continue;
> > +		}
> > +
> >  		page = vm_normal_page(vma, addr, ptent);
> >  		if (!page)
> >  			continue;
> > @@ -326,6 +338,14 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  		set_pte_at(mm, addr, pte, ptent);
> >  		tlb_remove_tlb_entry(tlb, pte, addr);
> >  	}
> > +
> > +	if (rss) {
> > +		if (current->mm == mm)
> > +			sync_mm_rss(mm);
> > +
> > +		add_mm_counter(mm, MM_SWAPENTS, rss);
> > +	}
> > +
> 
> This looks make sense, but I'm wondering why it can help and if this can help
> real workload.  Let me have an example. Say there is 1G memory, workload uses

void *ptr1 = malloc(len); /* allocator mmap new chunk */
touch_iow_dirty(ptr1, len);
..
..
..
..                      /* swapout happens */
free(ptr1);             /* allocator calls MADV_FREE on the chunk */

void *ptr2 = malloc(len) /* allocator reuses previous chunk */
touch_iow_dirty(ptr2, len); /* swapin happens to read garbage and application overwrite the garbage */

It's really unnecessary cost.


> 800M memory with DONTNEED, there should be no swap. With FREE, workload might
> use more than 1G memory and trigger swap. I thought the case (DONTNEED doesn't
> trigger swap) is more suitable to evaluate the performance of the patch.

I think above example is really clear and possible scenario.
Could you give me more concrete example to test if you want?

Thanks.

> 
> Thanks,
> Shaohua
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
