Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5818E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:09:24 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id k7so48646ybh.14
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:09:24 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id b4si698450ybo.485.2019.01.14.11.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 11:09:22 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <fdece7f8-7e4f-f679-821f-1d05ed748c15@nvidia.com>
Date: Mon, 14 Jan 2019 11:09:20 -0800
MIME-Version: 1.0
In-Reply-To: <20190114172124.GA3702@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/14/19 9:21 AM, Jerome Glisse wrote:
> On Mon, Jan 14, 2019 at 03:54:47PM +0100, Jan Kara wrote:
>> On Fri 11-01-19 19:06:08, John Hubbard wrote:
>>> On 1/11/19 6:46 PM, Jerome Glisse wrote:
>>>> On Fri, Jan 11, 2019 at 06:38:44PM -0800, John Hubbard wrote:
>>>> [...]
>>>>
>>>>>>> The other idea that you and Dan (and maybe others) pointed out was a debug
>>>>>>> option, which we'll certainly need in order to safely convert all the call
>>>>>>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
>>>>>>> and put_user_page() can verify that the right call was made.)  That will be
>>>>>>> a separate patchset, as you recommended.
>>>>>>>
>>>>>>> I'll even go as far as recommending the page lock itself. I realize that this 
>>>>>>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
>>>>>>> that this (below) has similar overhead to the notes above--but is *much* easier
>>>>>>> to verify correct. (If the page lock is unacceptable due to being so widely used,
>>>>>>> then I'd recommend using another page bit to do the same thing.)
>>>>>>
>>>>>> Please page lock is pointless and it will not work for GUP fast. The above
>>>>>> scheme do work and is fine. I spend the day again thinking about all memory
>>>>>> ordering and i do not see any issues.
>>>>>>
>>>>>
>>>>> Why is it that page lock cannot be used for gup fast, btw?
>>>>
>>>> Well it can not happen within the preempt disable section. But after
>>>> as a post pass before GUP_fast return and after reenabling preempt then
>>>> it is fine like it would be for regular GUP. But locking page for GUP
>>>> is also likely to slow down some workload (with direct-IO).
>>>>
>>>
>>> Right, and so to crux of the matter: taking an uncontended page lock
>>> involves pretty much the same set of operations that your approach does.
>>> (If gup ends up contended with the page lock for other reasons than these
>>> paths, that seems surprising.) I'd expect very similar performance.
>>>
>>> But the page lock approach leads to really dramatically simpler code (and
>>> code reviews, let's not forget). Any objection to my going that
>>> direction, and keeping this idea as a Plan B? I think the next step will
>>> be, once again, to gather some performance metrics, so maybe that will
>>> help us decide.
>>
>> FWIW I agree that using page lock for protecting page pinning (and thus
>> avoid races with page_mkclean()) looks simpler to me as well and I'm not
>> convinced there will be measurable difference to the more complex scheme
>> with barriers Jerome suggests unless that page lock contended. Jerome is
>> right that you cannot just do lock_page() in gup_fast() path. There you
>> have to do trylock_page() and if that fails just bail out to the slow gup
>> path.
>>

Yes, understood about gup fast.

>> Regarding places other than page_mkclean() that need to check pinned state:
>> Definitely page migration will want to check whether the page is pinned or
>> not so that it can deal differently with short-term page references vs
>> longer-term pins.

OK.

>>
>> Also there is one more idea I had how to record number of pins in the page:
>>
>> #define PAGE_PIN_BIAS	1024
>>
>> get_page_pin()
>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>
>> put_page_pin();
>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>
>> page_pinned(page)
>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>
>> This is pretty trivial scheme. It still gives us 22-bits for page pins
>> which should be plenty (but we should check for that and bail with error if
>> it would overflow). Also there will be no false negatives and false
>> positives only if there are more than 1024 non-page-table references to the
>> page which I expect to be rare (we might want to also subtract
>> hpage_nr_pages() for radix tree references to avoid excessive false
>> positives for huge pages although at this point I don't think they would
>> matter). Thoughts?
> 
> Racing PUP are as likely to cause issues:
> 
> CPU0                        | CPU1       | CPU2
>                             |            |
>                             | PUP()      |
>     page_pinned(page)       |            |
>       (page_count(page) -   |            |
>        page_mapcount(page)) |            |
>                             |            | GUP()
> 
> So here the refcount snap-shot does not include the second GUP and
> we can have a false negative ie the page_pinned() will return false
> because of the PUP happening just before on CPU1 despite the racing
> GUP on CPU2 just after.
> 
> I believe only either lock or memory ordering with barrier can
> guarantee that we do not miss GUP ie no false negative. Still the
> bias idea might be usefull as with it we should not need a flag.
> 
> So to make the above safe it would still need the page write back
> double check that i described so that GUP back-off if it raced with
> page_mkclean,clear_page_dirty_for_io and the fs write page call back
> which call test_set_page_writeback() (yes it is very unlikely but
> might still happen).
> 
> 
> I still need to ponder some more on all the races.
> 

Tentatively, so far I prefer the _mapcount scheme, because it seems more
accurate to add mapcounts than to overload the _refcount field. And the 
implementation is going to be cleaner. And we've already figured out the
races.

For example, the following already survives a basic boot to graphics mode.
It requires a bunch of callsite conversions, and a page flag (neither of which
is shown here), and may also have "a few" gross conceptual errors, but take a 
peek:

>From 1b6e611238a45badda7e63d3ffc089cefb621cb2 Mon Sep 17 00:00:00 2001
From: John Hubbard <jhubbard@nvidia.com>
Date: Sun, 13 Jan 2019 15:10:31 -0800
Subject: [PATCH 2/2] mm: track gup-pinned pages
X-NVConfidentiality: public
Cc: John Hubbard <jhubbard@nvidia.com>

Track GUP-pinned pages.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h |  8 ++++---
 mm/gup.c           | 59 +++++++++++++++++++++++++++++++++++++++++++---
 mm/rmap.c          | 23 ++++++++++++++----
 3 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 809b7397d41e..3221a13b4891 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1004,12 +1004,14 @@ static inline void put_page(struct page *page)
  * particular, interactions with RDMA and filesystems need special
  * handling.
  *
- * put_user_page() and put_page() are not interchangeable, despite this early
- * implementation that makes them look the same. put_user_page() calls must
- * be perfectly matched up with get_user_page() calls.
+ * put_user_page() and put_page() are not interchangeable. put_user_page()
+ * calls must be perfectly matched up with get_user_page() calls.
  */
 static inline void put_user_page(struct page *page)
 {
+	page = compound_head(page);
+
+	atomic_dec(&page->_mapcount);
 	put_page(page);
 }
 
diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e2eb22..af3909814be7 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -615,6 +615,48 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 	return 0;
 }
 
+/*
+ * Manages the PG_gup_pinned flag.
+ *
+ * Note that page->_mapcount counting part of managing that flag, because the
+ * _mapcount is used to determine if PG_gup_pinned can be cleared, in
+ * page_mkclean().
+ */
+static void track_gup_page(struct page *page)
+{
+	page = compound_head(page);
+
+	lock_page(page);
+
+	wait_on_page_writeback(page);
+
+	atomic_inc(&page->_mapcount);
+	SetPageGupPinned(page);
+
+	unlock_page(page);
+}
+
+/*
+ * A variant of track_gup_page() that returns -EBUSY, instead of waiting.
+ */
+static int track_gup_page_atomic(struct page *page)
+{
+	page = compound_head(page);
+
+	if (PageWriteback(page) || !trylock_page(page))
+		return -EBUSY;
+
+	if (PageWriteback(page)) {
+		unlock_page(page);
+		return -EBUSY;
+	}
+	atomic_inc(&page->_mapcount);
+	SetPageGupPinned(page);
+
+	unlock_page(page);
+	return 0;
+}
+
 /**
  * __get_user_pages() - pin user pages in memory
  * @tsk:	task_struct of target task
@@ -761,6 +803,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			ret = PTR_ERR(page);
 			goto out;
 		}
+
+		track_gup_page(page);
+
 		if (pages) {
 			pages[i] = page;
 			flush_anon_page(vma, page, start);
@@ -1439,6 +1484,11 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
+		if (track_gup_page_atomic(page)) {
+			put_page(head);
+			goto pte_unmap;
+		}
+
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -1574,7 +1624,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 	}
 
-	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
+	if (unlikely(pmd_val(orig) != pmd_val(*pmdp)) ||
+	    track_gup_page_atomic(head)) {
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
@@ -1612,7 +1663,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 	}
 
-	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
+	if (unlikely(pud_val(orig) != pud_val(*pudp)) ||
+	    track_gup_page_atomic(head)) {
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
@@ -1649,7 +1701,8 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		return 0;
 	}
 
-	if (unlikely(pgd_val(orig) != pgd_val(*pgdp))) {
+	if (unlikely(pgd_val(orig) != pgd_val(*pgdp)) ||
+	    track_gup_page_atomic(head)) {
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537..434283898bb0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -880,6 +880,11 @@ int page_referenced(struct page *page,
 	return pra.referenced;
 }
 
+struct page_mkclean_args {
+	int cleaned;
+	int mapcount;
+};
+
 static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
@@ -890,7 +895,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.flags = PVMW_SYNC,
 	};
 	struct mmu_notifier_range range;
-	int *cleaned = arg;
+	struct page_mkclean_args *pma = arg;
 
 	/*
 	 * We have to assume the worse case ie pmd for invalidation. Note that
@@ -940,6 +945,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 #endif
 		}
 
+		pma->mapcount++;
+
 		/*
 		 * No need to call mmu_notifier_invalidate_range() as we are
 		 * downgrading page table protection not changing it to point
@@ -948,7 +955,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		if (ret)
-			(*cleaned)++;
+			pma->cleaned++;
 	}
 
 	mmu_notifier_invalidate_range_end(&range);
@@ -966,10 +973,13 @@ static bool invalid_mkclean_vma(struct vm_area_struct *vma, void *arg)
 
 int page_mkclean(struct page *page)
 {
-	int cleaned = 0;
+	struct page_mkclean_args pma = {
+		.cleaned = 0,
+		.mapcount = 0
+	};
 	struct address_space *mapping;
 	struct rmap_walk_control rwc = {
-		.arg = (void *)&cleaned,
+		.arg = (void *)&pma,
 		.rmap_one = page_mkclean_one,
 		.invalid_vma = invalid_mkclean_vma,
 	};
@@ -985,7 +995,10 @@ int page_mkclean(struct page *page)
 
 	rmap_walk(page, &rwc);
 
-	return cleaned;
+	if (pma.mapcount == page_mapcount(page))
+		ClearPageGupPinned(page);
+
+	return pma.cleaned;
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
-- 
2.20.1



thanks,
-- 
John Hubbard
NVIDIA
