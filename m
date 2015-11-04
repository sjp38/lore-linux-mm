Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6EE6B0255
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 09:21:38 -0500 (EST)
Received: by wikq8 with SMTP id q8so93189484wik.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 06:21:38 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id pu5si1901381wjc.50.2015.11.04.06.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 06:21:37 -0800 (PST)
Received: by wijp11 with SMTP id p11so93325815wij.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 06:21:36 -0800 (PST)
Date: Wed, 4 Nov 2015 16:21:35 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151104142135.GA13303@node.shutemov.name>
References: <20151022090051.GH23631@bbox>
 <20151029002524.GA12018@node.shutemov.name>
 <20151029075829.GA16099@bbox>
 <20151029095206.GB29870@node.shutemov.name>
 <20151030070350.GB16099@bbox>
 <20151102125749.GB7473@node.shutemov.name>
 <20151103030258.GJ17906@bbox>
 <20151103071650.GA21553@node.shutemov.name>
 <20151103073329.GL17906@bbox>
 <20151103152019.GM17906@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151103152019.GM17906@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Nov 04, 2015 at 12:20:19AM +0900, Minchan Kim wrote:
> On Tue, Nov 03, 2015 at 04:33:29PM +0900, Minchan Kim wrote:
> > On Tue, Nov 03, 2015 at 09:16:50AM +0200, Kirill A. Shutemov wrote:
> > > On Tue, Nov 03, 2015 at 12:02:58PM +0900, Minchan Kim wrote:
> > > > Hello Kirill,
> > > > 
> > > > On Mon, Nov 02, 2015 at 02:57:49PM +0200, Kirill A. Shutemov wrote:
> > > > > On Fri, Oct 30, 2015 at 04:03:50PM +0900, Minchan Kim wrote:
> > > > > > On Thu, Oct 29, 2015 at 11:52:06AM +0200, Kirill A. Shutemov wrote:
> > > > > > > On Thu, Oct 29, 2015 at 04:58:29PM +0900, Minchan Kim wrote:
> > > > > > > > On Thu, Oct 29, 2015 at 02:25:24AM +0200, Kirill A. Shutemov wrote:
> > > > > > > > > On Thu, Oct 22, 2015 at 06:00:51PM +0900, Minchan Kim wrote:
> > > > > > > > > > On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> > > > > > > > > > > Hello Hugh,
> > > > > > > > > > > 
> > > > > > > > > > > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > > > > > > > > > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > > > > > > > > > > 
> > > > > > > > > > > > > I added the code to check it and queued it again but I had another oops
> > > > > > > > > > > > > in this time but symptom is related to anon_vma, too.
> > > > > > > > > > > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > > > > > > > > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > > > > > > > > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > > > > > > > > > > to be true.
> > > > > > > > > > > > > 
> > > > > > > > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > > > > > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > > > > > > > > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > > > > > > > > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > > > > > > > > > > 
> > > > > > > > > > > > That's interesting, that's one I added in my page migration series.
> > > > > > > > > > > > Let me think on it, but it could well relate to the one you got before.
> > > > > > > > > > > 
> > > > > > > > > > > I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> > > > > > > > > > > instead of next-20151021 to remove noise from your migration cleanup
> > > > > > > > > > > series and will test it again.
> > > > > > > > > > > If it is fixed, I will test again with your migration patchset, then.
> > > > > > > > > > 
> > > > > > > > > > I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
> > > > > > > > > > Therefore, there is no patchset from Hugh's migration patch in there.
> > > > > > > > > > And I added below debug code with request from Kirill to all test kernels.
> > > > > > > > > 
> > > > > > > > > It took too long time (and a lot of printk()), but I think I track it down
> > > > > > > > > finally.
> > > > > > > > >  
> > > > > > > > > The patch below seems fixes issue for me. It's not yet properly tested, but
> > > > > > > > > looks like it works.
> > > > > > > > > 
> > > > > > > > > The problem was my wrong assumption on how migration works: I thought that
> > > > > > > > > kernel would wait migration to finish on before deconstruction mapping.
> > > > > > > > > 
> > > > > > > > > But turn out that's not true.
> > > > > > > > > 
> > > > > > > > > As result if zap_pte_range() races with split_huge_page(), we can end up
> > > > > > > > > with page which is not mapped anymore but has _count and _mapcount
> > > > > > > > > elevated. The page is on LRU too. So it's still reachable by vmscan and by
> > > > > > > > > pfn scanners (Sasha showed few similar traces from compaction too).
> > > > > > > > > It's likely that page->mapping in this case would point to freed anon_vma.
> > > > > > > > > 
> > > > > > > > > BOOM!
> > > > > > > > > 
> > > > > > > > > The patch modify freeze/unfreeze_page() code to match normal migration
> > > > > > > > > entries logic: on setup we remove page from rmap and drop pin, on removing
> > > > > > > > > we get pin back and put page on rmap. This way even if migration entry
> > > > > > > > > will be removed under us we don't corrupt page's state.
> > > > > > > > > 
> > > > > > > > > Please, test.
> > > > > > > > > 
> > > > > > > > 
> > > > > > > > kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + your new patch, I tested
> > > > > > > > one I sent to you(ie, oops.c + memcg_test.sh)
> > > > > > > > 
> > > > > > > > page:ffffea00016a0000 count:3 mapcount:0 mapping:ffff88007f49d001 index:0x600001800 compound_mapcount: 0
> > > > > > > > flags: 0x4000000000044009(locked|uptodate|head|swapbacked)
> > > > > > > > page dumped because: VM_BUG_ON_PAGE(!page_mapcount(page))
> > > > > > > > page->mem_cgroup:ffff88007f613c00
> > > > > > > 
> > > > > > > Ignore my previous answer. Still sleeping.
> > > > > > > 
> > > > > > > The right way to fix I think is something like:
> > > > > > > 
> > > > > > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > > > > > index 35643176bc15..f2d46792a554 100644
> > > > > > > --- a/mm/rmap.c
> > > > > > > +++ b/mm/rmap.c
> > > > > > > @@ -1173,20 +1173,12 @@ void do_page_add_anon_rmap(struct page *page,
> > > > > > >  	bool compound = flags & RMAP_COMPOUND;
> > > > > > >  	bool first;
> > > > > > >  
> > > > > > > -	if (PageTransCompound(page)) {
> > > > > > > +	if (PageTransCompound(page) && compound) {
> > > > > > > +		atomic_t *mapcount;
> > > > > > >  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > > > > > -		if (compound) {
> > > > > > > -			atomic_t *mapcount;
> > > > > > > -
> > > > > > > -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > > > > > -			mapcount = compound_mapcount_ptr(page);
> > > > > > > -			first = atomic_inc_and_test(mapcount);
> > > > > > > -		} else {
> > > > > > > -			/* Anon THP always mapped first with PMD */
> > > > > > > -			first = 0;
> > > > > > > -			VM_BUG_ON_PAGE(!page_mapcount(page), page);
> > > > > > > -			atomic_inc(&page->_mapcount);
> > > > > > > -		}
> > > > > > > +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > > > > > +		mapcount = compound_mapcount_ptr(page);
> > > > > > > +		first = atomic_inc_and_test(mapcount);
> > > > > > >  	} else {
> > > > > > >  		VM_BUG_ON_PAGE(compound, page);
> > > > > > >  		first = atomic_inc_and_test(&page->_mapcount);
> > > > > > > -- 
> > > > > > 
> > > > > > kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + freeze/unfreeze patch + above patch,
> > > > > > 
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > 
> > > > > > <SNIP>
> > > > > > 
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > BUG: Bad rss-counter state mm:ffff880046980700 idx:1 val:511
> > > > > > BUG: Bad rss-counter state mm:ffff880046980700 idx:2 val:1
> > > > > 
> > > > > Hm. I was not able to trigger this and don't see anything obviuous what can
> > > > > lead to this kind of missmatch :-/
> > > 
> > > I managed to trigger this when switched back from MADV_DONTNEED to
> > > MADV_FREE. Hm..
> > 
> > Hmm,,
> > What version of MADV_FREE do you test on?
> > Old MADV_FREE(ie, before posting MADV_FREE refactoring and fix KSM page)
> > had a bug.
> > 
> > I tried your patches on top of recent my MADV_FREE patches.
> > But when I try it with old THP refcount redesign, I couldn't find
> > any problem so far. However, I'm not saying it's your fault.
> > 
> > I will give it a shot with MADV_DONTNEED to reproduce the problem.
> > But one thing I could say is MADV_DONTNEED is more hard to hit
> > compared to MADV_FREE because memory pressure of MADV_DONTNEED test
> > wouldn't be heavy.
> 
> I reproduced this on the kernel which has no code related to MADV_FREE:
> 
> mmotm-2015-10-15-15-20-no-madvise_free, IOW it means git head for
> 54bad5da4834 arm64: add pmd_[dirty|mkclean] for THP so there is no
> MADV_FREE code in there
> + pte_mkdirty patch
> + freeze/unfreeze patch
> + do_page_add_anon_rmap patch
> 
> Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> BUG: Bad rss-counter state mm:ffff88007fdd5b00 idx:1 val:511
> BUG: Bad rss-counter state mm:ffff88007fdd5b00 idx:2 val:1

I have one idea why it could happen, but not sure yet..

Could you check if it makes any difference for you?

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 5c7b00e88236..194f7f8b8c66 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -103,12 +103,7 @@ void deferred_split_huge_page(struct page *page);
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address);
 
-#define split_huge_pmd(__vma, __pmd, __address)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		if (pmd_trans_huge(*____pmd))				\
-			__split_huge_pmd(__vma, __pmd, __address);	\
-	}  while (0)
+#define split_huge_pmd(__vma, __pmd, __address)	__split_huge_pmd(__vma, __pmd, __address)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
