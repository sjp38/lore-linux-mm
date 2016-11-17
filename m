Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8AE66B0342
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:26:28 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 12so148261715uas.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:26:28 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e16si1277683uaa.123.2016.11.17.11.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:26:28 -0800 (PST)
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
 <20161116182809.GC26185@redhat.com>
 <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com>
 <20161117154031.GA10229@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <718434af-d279-445d-e210-201bf02f434f@oracle.com>
Date: Thu, 17 Nov 2016 11:26:17 -0800
MIME-Version: 1.0
In-Reply-To: <20161117154031.GA10229@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On 11/17/2016 07:40 AM, Andrea Arcangeli wrote:
> On Wed, Nov 16, 2016 at 10:53:39AM -0800, Mike Kravetz wrote:
>> I was running some tests with error injection to exercise the error
>> path and noticed the reservation leaks as the system eventually ran
>> out of huge pages.  I need to think about it some more, but we may
>> want to at least do something like the following before put_page (with
>> a BIG comment):
>>
>> 	if (unlikely(PagePrivate(page)))
>> 		ClearPagePrivate(page);
>>
>> That would at least keep the global reservation count from increasing.
>> Let me look into that.
> 
> However what happens if the old vma got munmapped

When the huge page was allocated, the reservation map associated with
the vma was marked to indicate the reservation was consumed.  In addition
the global reservation count and subpool count were adjusted to account
for the page allocation.  So, when the vma gets unmapped the reservation
map will be examined.  Since the map indicates the reservation was consumed,
no adjustment will be made to the global or subpool reservation count.

>                                                   and a new compatible
> vma was instantiated and passes revalidation fine? The reserved page
> of the old vma goes to a different vma then?

No, the new vma should get a new reservation.  It can not use the old
reservation as it was associated with the old vma.  This is at least
the case for private mappings where the reservation maps are associated
with the vma.

> This reservation code is complex and has lots of special cases anyway,
> but the main concern at this point is the
> set_page_private(subpool_vma(vma)) released by
> hugetlb_vm_op_close->unlock_or_release_subpool.

Do note that set_page_private(subpool_vma(vma)) just indicates which
subpool was used when the huge page was allocated.  I do not believe
there is any connection made to the vma.  The vma is only used to get
to the inode and superblock which contains subpool information.  With
the subpool stored in page_private, the subpool count can be adjusted
at free_huge_page time.  Also note that the subpool can not be free'ed
in unlock_or_release_subpool until put_page is complete for the page.
This is because the page is accounted for in spool->used_hpages.

> Aside the accounting, what about the page_private(page) subpool? It's
> used by huge_page_free which would get out of sync with vma/inode
> destruction if we release the mmap_sem.

I do not think that is the case.  Reservation and subpool adjustments
made at vma/inode destruction time are based on entries in the reservation
map.  Those entries are created/destroyed when holding mmap_sem.

> 	struct hugepage_subpool *spool =
> 		(struct hugepage_subpool *)page_private(page);
> 
> I think in the revalidation code we need to check if
> page_private(page) still matches the subpool_vma(vma), if it doesn't
> and it's a stale pointer, we can't even call put_page before fixing up
> the page_private first.

I do not think that is correct.  page_private(page) points to the subpool
used when the page was allocated.  Therefore, adjustments were made to that
subpool when the page was allocated.  We need to adjust the same subpool
when calling put_page.  I don't think there is any need to look at the
vma/subpool_vma(vma).  If it doesn't match, we certainly do not want to
adjust counts in a potentially different subpool when calling page_put.

As you said, this reservation code is complex.  It might be good if
Hillf could comment as he understands this code.

I still believe a simple call to ClearPagePrivate(page) may be all we
need to do in the error path.  If this is the case, the only downside
is that it would appear the reservation was consumed for that page.
So, subsequent faults 'might' not get a huge page.

> The other way to solve this is not to release the mmap_sem at all and
> in the slow path call __get_user_pages(nonblocking=NULL). That's
> slower than using the CPU TLB to reach the source data and it'd
> prevent also to handle a userfault in the source address of
> UFFDIO_COPY, because an userfault in the source would require the
> mmap_sem to be released (i.e. it'd require get_user_pages_fast that
> would again recurse on the mmap_sem and in turn we could as well stick
> to the current nonblocking copy-user). We currently don't handle
> nesting with non-cooperative anyway so it'd be ok for now not to
> release the mmap_sem while copying in UFFDIO_COPY.
> 
> 
> Offtopic here but while reading this code I also noticed
> free_huge_page is wasting CPU and then noticed other places wasting
> CPU.

Good catch.

> 
> From 9f3966c5bbf88cb8f702393d6a78abf1b8f960f9 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 17 Nov 2016 15:28:20 +0100
> Subject: [PATCH 1/1] hugetlbfs: use non atomic ops when the page is private
> 
> After the page has been freed it's fully private and no other CPU can
> manipulate the page structure anymore (other than get_page_unless_zero
> from speculative lookups, but those will fail because of the zero
> refcount).
> 
> The same is true when the page has been newly allocated.
> 
> So we can use faster non atomic ops for those cases.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/hugetlb.c | 44 ++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 36 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 022750d..7c422c1 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1216,16 +1216,44 @@ bool page_huge_active(struct page *page)
>  }
>  
>  /* never called for tail page */
> +static __always_inline void ____set_page_huge_active(struct page *page,
> +						     bool atomic)
> +{
> +	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
> +	if (atomic)
> +		SetPagePrivate(&page[1]);
> +	else
> +		__SetPagePrivate(&page[1]);
> +}
> +
>  static void set_page_huge_active(struct page *page)
>  {
> +	____set_page_huge_active(page, true);
> +}
> +
> +static void __set_page_huge_active(struct page *page)
> +{
> +	____set_page_huge_active(page, false);
> +}
> +
> +static __always_inline void ____clear_page_huge_active(struct page *page,
> +						       bool atomic)
> +{
>  	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
> -	SetPagePrivate(&page[1]);
> +	if (atomic)
> +		ClearPagePrivate(&page[1]);
> +	else
> +		__ClearPagePrivate(&page[1]);
>  }
>  
>  static void clear_page_huge_active(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
> -	ClearPagePrivate(&page[1]);
> +	____clear_page_huge_active(page, true);
> +}
> +
> +static void __clear_page_huge_active(struct page *page)
> +{
> +	____clear_page_huge_active(page, false);
>  }
>  
>  void free_huge_page(struct page *page)
> @@ -1245,7 +1273,7 @@ void free_huge_page(struct page *page)
>  	VM_BUG_ON_PAGE(page_count(page), page);
>  	VM_BUG_ON_PAGE(page_mapcount(page), page);
>  	restore_reserve = PagePrivate(page);
> -	ClearPagePrivate(page);
> +	__ClearPagePrivate(page);
>  
>  	/*
>  	 * A return code of zero implies that the subpool will be under its
> @@ -1256,7 +1284,7 @@ void free_huge_page(struct page *page)
>  		restore_reserve = true;
>  
>  	spin_lock(&hugetlb_lock);
> -	clear_page_huge_active(page);
> +	__clear_page_huge_active(page);
>  	hugetlb_cgroup_uncharge_page(hstate_index(h),
>  				     pages_per_huge_page(h), page);
>  	if (restore_reserve)
> @@ -3534,7 +3562,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	copy_user_huge_page(new_page, old_page, address, vma,
>  			    pages_per_huge_page(h));
>  	__SetPageUptodate(new_page);
> -	set_page_huge_active(new_page);
> +	__set_page_huge_active(new_page);
>  
>  	mmun_start = address & huge_page_mask(h);
>  	mmun_end = mmun_start + huge_page_size(h);
> @@ -3697,7 +3725,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));
>  		__SetPageUptodate(page);
> -		set_page_huge_active(page);
> +		__set_page_huge_active(page);
>  
>  		if (vma->vm_flags & VM_MAYSHARE) {
>  			int err = huge_add_to_page_cache(page, mapping, idx);
> @@ -4000,7 +4028,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	 * the set_pte_at() write.
>  	 */
>  	__SetPageUptodate(page);
> -	set_page_huge_active(page);
> +	__set_page_huge_active(page);
>  
>  	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
>  	spin_lock(ptl);
> 
> 
> 
>> I will take a look, and 'may' have a test that can be modified for this.
> 
> Overnight stress of postcopy live migration over hugetlbfs passed
> without a single glitch with the patch applied, so it's tested
> now. It'd still be good to add an O_DIRECT test to the selftest.

Great.  I did review the patch, but did not test as planned.

> The previous issue with the mmap_sem release and accounting and
> potential subpool use after free, is only about malicious apps, it'd
> be impossible to reproduce it with qemu or the current selftest, but
> we've to take care of it before I can resubmit for upstream.

Of course.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
