Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09A636B4E87
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 20:40:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id a15-v6so6291464qtj.15
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 17:40:25 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 32-v6si5195016qth.354.2018.08.29.17.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 17:40:23 -0700 (PDT)
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz> <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
 <20180829181424.GB3784@redhat.com> <20180829183906.GF10223@dhcp22.suse.cz>
 <20180829211106.GC3784@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8689d0ba-1303-9765-4cae-ad24d2a1435b@oracle.com>
Date: Wed, 29 Aug 2018 17:40:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180829211106.GC3784@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On 08/29/2018 02:11 PM, Jerome Glisse wrote:
> On Wed, Aug 29, 2018 at 08:39:06PM +0200, Michal Hocko wrote:
>> On Wed 29-08-18 14:14:25, Jerome Glisse wrote:
>>> On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
>> [...]
>>>> What would be the best mmu notifier interface to use where there are no
>>>> start/end calls?
>>>> Or, is the best solution to add the start/end calls as is done in later
>>>> versions of the code?  If that is the suggestion, has there been any change
>>>> in invalidate start/end semantics that we should take into account?
>>>
>>> start/end would be the one to add, 4.4 seems broken in respect to THP
>>> and mmu notification. Another solution is to fix user of mmu notifier,
>>> they were only a handful back then. For instance properly adjust the
>>> address to match first address covered by pmd or pud and passing down
>>> correct page size to mmu_notifier_invalidate_page() would allow to fix
>>> this easily.
>>>
>>> This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
>>> with an invalid one (either poison, migration or swap) inside the
>>> function. So anyone racing would synchronize on those special entry
>>> hence why it is fine to delay mmu_notifier_invalidate_page() to after
>>> dropping the page table lock.
>>>
>>> Adding start/end might the solution with less code churn as you would
>>> only need to change try_to_unmap_one().
>>
>> What about dependencies? 369ea8242c0fb sounds like it needs work for all
>> notifiers need to be updated as well.
> 
> This commit remove mmu_notifier_invalidate_page() hence why everything
> need to be updated. But in 4.4 you can get away with just adding start/
> end and keep around mmu_notifier_invalidate_page() to minimize disruption.
> 
> So the new semantic in 369ea8242c0fb is that all page table changes are
> bracketed with mmu notifier start/end calls and invalidate_range right
> after tlb flush. This simplify thing and make it more reliable for mmu
> notifier users like IOMMU or ODP or GPUs drivers.

Here is what I came up with by adding the start/end calls to the 4.4 version
of try_to_unmap_one.  Note that this assumes/uses the new routine
adjust_range_if_pmd_sharing_possible to adjust the notifier/flush range if
huge pmd sharing is possible.  I changed the mmu_notifier_invalidate_page
to a mmu_notifier_invalidate_range, but am not sure if that needs to happen
earlier in the routine (like right after tlb flush as you said above).
Does this look reasonable?

diff --git a/mm/rmap.c b/mm/rmap.c
index b577fbb98d4b..7ba8bfeddb4b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1302,11 +1302,30 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
+	unsigned long start = address, end;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
-		goto out;
+		return ret;
+
+	/*
+	 * For THP, we have to assume the worse case ie pmd for invalidation.
+	 * For hugetlb, it could be much worse if we need to do pud
+	 * invalidation in the case of pmd sharing.
+	 *
+	 * Note that the page can not be free in this function as call of
+	 * try_to_unmap() must hold a reference on the page.
+	 */
+	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
+	if (PageHuge(page)) {
+		/*
+		 * If sharing is possible, start and end will be adjusted
+		 * accordingly.
+		 */
+		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
+	}
+	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1334,6 +1353,29 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
   	}
 
+	if (PageHuge(page) && huge_pmd_unshare(mm, &address, pte)) {
+		/*
+		 * huge_pmd_unshare unmapped an entire PMD page.  There is
+		 * no way of knowing exactly which PMDs may be cached for
+		 * this mm, so flush them all.  start/end were already
+		 * adjusted to cover this range.
+		 */
+		flush_cache_range(vma, start, end);
+		flush_tlb_range(vma, start, end);
+
+		/*
+		 * The ref count of the PMD page was dropped which is part
+		 * of the way map counting is done for shared PMDs.  When
+		 * there is no other sharing, huge_pmd_unshare returns false
+		 * and we will unmap the actual page and drop map count
+		 * to zero.
+		 *
+		 * Note that huge_pmd_unshare modified address and is likely
+		 * not what you would expect.
+		 */
+		goto out_unmap;
+	}
+
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
 	if (should_defer_flush(mm, flags)) {
@@ -1424,10 +1466,11 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_range(mm, start, end);
+	pte_unmap_unlock(pte, ptl);
 out:
+	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
 	return ret;
 }
 
-- 
Mike Kravetz
