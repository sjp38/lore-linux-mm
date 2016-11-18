Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC76B039F
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:52:25 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 34so158768419uac.6
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 21:52:25 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j23si1880356uaa.103.2016.11.17.21.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 21:52:24 -0800 (PST)
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
References: <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
 <20161116182809.GC26185@redhat.com>
 <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com>
 <20161117154031.GA10229@redhat.com>
 <718434af-d279-445d-e210-201bf02f434f@oracle.com>
 <20161118000527.GB10229@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c9350efa-ca79-c514-0305-22c90fdbb0df@oracle.com>
Date: Thu, 17 Nov 2016 21:52:15 -0800
MIME-Version: 1.0
In-Reply-To: <20161118000527.GB10229@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On 11/17/2016 04:05 PM, Andrea Arcangeli wrote:
> On Thu, Nov 17, 2016 at 11:26:17AM -0800, Mike Kravetz wrote:
>> On 11/17/2016 07:40 AM, Andrea Arcangeli wrote:
>>> On Wed, Nov 16, 2016 at 10:53:39AM -0800, Mike Kravetz wrote:
>>>> I was running some tests with error injection to exercise the error
>>>> path and noticed the reservation leaks as the system eventually ran
>>>> out of huge pages.  I need to think about it some more, but we may
>>>> want to at least do something like the following before put_page (with
>>>> a BIG comment):
>>>>
>>>> 	if (unlikely(PagePrivate(page)))
>>>> 		ClearPagePrivate(page);
>>>>
>>>> That would at least keep the global reservation count from increasing.
>>>> Let me look into that.
>>>
>>> However what happens if the old vma got munmapped
>>
>> When the huge page was allocated, the reservation map associated with
>> the vma was marked to indicate the reservation was consumed.  In addition
>> the global reservation count and subpool count were adjusted to account
>> for the page allocation.  So, when the vma gets unmapped the reservation
>> map will be examined.  Since the map indicates the reservation was consumed,
>> no adjustment will be made to the global or subpool reservation count.
> 
> ClearPagePrivate before put_page, will simply avoid to run
> h->resv_huge_pages++?

Correct

> Not increasing resv_huge_pages means more non reserved allocations
> will pass. That is a global value though, how is it ok to leave it
> permanently lower?

Recall that h->resv_huge_pages is incremented when a mapping/vma is
created to indicate that reservations exist. It is decremented when
a huge page is allocated.  In addition, the reservation map is
initially set up to indicate that reservations exist for the
pages in the mapping. When a page is allocated the map is modified
to indicate a reservation was consumed.

So path, resv_huge_pages was decremented as the page was allocated
and the reserve map indicates the reservation was consumed.  At this
time, resv_huge_pages and the reserve map accurately reflect the
state of reservations in the vma and globally.

In this path, we were unable instantiate the page in the mapping/vma
so we must free the page.  The "ideal" solution would be to adjust the
reserve mat to indicate the reservation was not consumed, and increment
resv_huge_pages.  However, since we dropped mmap_sema we can not adjust
the reserve map.  So, the questions is what should be done with
resv_huge_pages?   There are only two options.
1) Leave it "as is" when the page is free'ed.
   In this case, the reserve map will indicate the reservation was consumed
   but there will not be an associated page in the mapping.  Therefore,
   it is possible that a susbequent fault can happen on the page.  At that
   time, it will appear as though the reservation for the page was already
   consumed.  Therefore, is there are not any available pages the fault will
   fail (ENOMEM).  Note that this only impacts subsequent faults of this
   specific mapping/page.
2) Increment it when the page is free'ed
   As above, the reserve map will still indicate the reservation was
consumed
   and subsequent faults can only be satisfied if there are available pages.
   However, there is now a global reservation as indicated by
resv_huge_pages
   that is not associated with any mapping.  What this means is that there
   is a reserved page and nobody can use.  The reservation is being held for
   a mapping that has already consumed the reservation.

> If PagePrivate was set, it means alloc_huge_page already run this:
> 
> 			SetPagePrivate(page);
> 			h->resv_huge_pages--;
> 
> But it would also have set a reserve map on the vma for that range
> before that.
> 
> When the vma is destroyed the reserve is flushed back to global, minus
> the consumed pages (reserve = (end - start) - region_count(resv,
> start, end)).

Consider a very simply 1 page vma.  Obviously, (end - start) = 1 and
as mentioned above the reserve map was adjusted to indicate the reservation
was consumed.  So, region_count(resv, start, end) is also going to = 1
and reserve will = 0.  Therefore, no adjustment of resv_huge_pages will
be made when the the vma is destroyed.

The same happens for the the single page within a larger vma.

> Why should then we skip h->resv_huge_pages++ for the consumed pages by
> running ClearPagePrivate?
> 
> It's not clear was wrong in the first place considering
> put_page->free_huge_page() acts on the global stuff only?

See the description of 2) above.

> void restore_reserve_on_error(struct hstate *h, struct vm_area_struct *vma,
> 				unsigned long address, struct page *page)
> {
> 	if (unlikely(PagePrivate(page))) {
> 		long rc = vma_needs_reservation(h, vma, address);
> 
> 		if (unlikely(rc < 0)) {
> 			/*
> 			 * Rare out of memory condition in reserve map
> 			 * manipulation.  Clear PagePrivate so that
> 			 * global reserve count will not be incremented
> 			 * by free_huge_page.  This will make it appear
> 			 * as though the reservation for this page was
> 			 * consumed.  This may prevent the task from
> 			 * faulting in the page at a later time.  This
> 			 * is better than inconsistent global huge page
> 			 * accounting of reserve counts.
> 			 */
> 			ClearPagePrivate(page);
> 
> The ClearPagePrivate was run above because vma_needs_reservation run
> out of memory and couldn't be added?

restore_reserve_on_error tries to do the "ideal" cleanup by adjusting
the reserve map to indicate the reservation was not consumed.  If it
can do this, then it does not ClearPagePrivate(page) as the global
reservation count SHOULD be incremented as the reserve map now indicates
the reservation as not consumed.

The only time it can not adjust the reserve map is if the reserve map
map manipulation routines fail.  They would only fail if they can not
allocate a 32 byte structure used to track reservations.  As noted in
the comments this is rare, and if we can't allocate 32 bytes I suspect
there are other issues.  But, in this case ClearPagePrivate is run so
that when the page is free'ed the global count will be consistent with
the reserve map.  This is essentially why I think we should do the same
in __mcopy_atomic_hugetlb.

> So I suppose the vma reservation wasn't possible in the above case, in
> our allocation case alloc_huge_page succeeded at those reserve maps
> allocations:
> 
> 	map_chg = gbl_chg = vma_needs_reservation(h, vma, addr);
> 	if (map_chg < 0)
> 		return ERR_PTR(-ENOMEM);
> 	[..]
> 		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
> 			SetPagePrivate(page);
> 			h->resv_huge_pages--;
> 		}
> 

It is slightly different.  In alloc_huge_page we are adjusting the reserve
map to indicate the reservation was consumed.  In restore_reserve_on_error
we are adjusting the map to indicate the reservation was not consumed.

>>>                                                   and a new compatible
>>> vma was instantiated and passes revalidation fine? The reserved page
>>> of the old vma goes to a different vma then?
>>
>> No, the new vma should get a new reservation.  It can not use the old
>> reservation as it was associated with the old vma.  This is at least
>> the case for private mappings where the reservation maps are associated
>> with the vma.
> 
> You're not suggesting to call ClearPagePrivate in the second pass of
> the "retry" loop if all goes fine and second pass succeeds, but only if
> we end up in a error of revalidation at the second pass?

That is correct.  Only on the error path.  We will only call put_page
on the error path and we only call ClearPagePrivate before put_page.

> 
> So the page with PagePrivate set could go to a different vma despite
> the vma reserve map was accounted for in the original vma? Is that ok?

Yes, see the potential issue with subsequent faults.  It is not the
"ideal" case that would be sone in restore_reserve_on_error, but I
think it is the beast alternative.  And, I'm guessing this error
path is not something we will hit frequently?  Or, do you think it
will be exercised often?

>>> This reservation code is complex and has lots of special cases anyway,
>>> but the main concern at this point is the
>>> set_page_private(subpool_vma(vma)) released by
>>> hugetlb_vm_op_close->unlock_or_release_subpool.
>>
>> Do note that set_page_private(subpool_vma(vma)) just indicates which
>> subpool was used when the huge page was allocated.  I do not believe
>> there is any connection made to the vma.  The vma is only used to get
>> to the inode and superblock which contains subpool information.  With
>> the subpool stored in page_private, the subpool count can be adjusted
>> at free_huge_page time.  Also note that the subpool can not be free'ed
>> in unlock_or_release_subpool until put_page is complete for the page.
>> This is because the page is accounted for in spool->used_hpages.
> 
> Yes I figured myself shortly later used_hpages. So there's no risk of
> use after free on the subpool pointed by the page at least.
> 
> I also considered shutting down this accounting entirely by calling
> alloc_huge_page(allow_reserve = 0) in hugetlbfs mcopy atomic... Can't
> we start that way so we don't have to worry about the reservation
> accounting at all?

Does "allow_reserve = 0" indicate alloc_huge_page(... avoid_reserve = 1)?
I think, that is what you are asking.

Well we could do that.  But, it could cause failures.  Again consider
an overly simple case of a 1 page vma.  Also, suppose there is only one
huge page in the system.  When the vma is created/mapped the one huge
page is reserved.  However, we call alloc_huge_page(...avoid_reserve = 1)
the allocation will fail as we indicated that reservations should not
be used.  If there was another page in the system, or we were configured
to allocate surplus pages then it may succeed.

>>> Aside the accounting, what about the page_private(page) subpool? It's
>>> used by huge_page_free which would get out of sync with vma/inode
>>> destruction if we release the mmap_sem.
>>
>> I do not think that is the case.  Reservation and subpool adjustments
>> made at vma/inode destruction time are based on entries in the reservation
>> map.  Those entries are created/destroyed when holding mmap_sem.
>>
>>> 	struct hugepage_subpool *spool =
>>> 		(struct hugepage_subpool *)page_private(page);
>>>
>>> I think in the revalidation code we need to check if
>>> page_private(page) still matches the subpool_vma(vma), if it doesn't
>>> and it's a stale pointer, we can't even call put_page before fixing up
>>> the page_private first.
>>
>> I do not think that is correct.  page_private(page) points to the subpool
>> used when the page was allocated.  Therefore, adjustments were made to that
>> subpool when the page was allocated.  We need to adjust the same subpool
>> when calling put_page.  I don't think there is any need to look at the
>> vma/subpool_vma(vma).  If it doesn't match, we certainly do not want to
>> adjust counts in a potentially different subpool when calling page_put.
> 
> Isn't the subpool different for every mountpoint of hugetlbfs?

yes.

> 
> The old vma subpool can't be a stale pointer, because of the
> used_hpages but if there are two different hugetlbfs mounts the
> subpool seems to come from the superblock so it may change after we
> release the mmap_sem.
> 
> Don't we have to add a check for the new vma subpool change against
> the page->private?
> 
> Otherwise we'd be putting the page in some other subpool than the one
> it was allocated from, as long as they pass the vma_hpagesize !=
> vma_kernel_pagesize(dst_vma) check.

I don't think there is an issue.  page->private will be set to point to
the subpool where the page was originally charged.  That will not change
until the page_put, and the same subpool will be used to adjust the
count.  The page can't go to another vma, without first passing through
free_huge_page and doing proper subpool accounting.  If it does go to
another vma, then alloc_huge_page will set it to the proper subpool.

>> As you said, this reservation code is complex.  It might be good if
>> Hillf could comment as he understands this code.
>>
>> I still believe a simple call to ClearPagePrivate(page) may be all we
>> need to do in the error path.  If this is the case, the only downside
>> is that it would appear the reservation was consumed for that page.
>> So, subsequent faults 'might' not get a huge page.
> 
> I thought running out of hugepages is what you experienced already
> with the current code if using error injection.

Yes, what I experienced is described in 2) of my first comment in this
e-mail.  I would eventually end up with all huge pages being "reserved"
and unable to use/allocate them.  So, none of the huge pages in the system
(or memory associated with them) could be used until reboot. :(

-- 
Mike Kravetz

> 
>> Good catch.
> 
> Eh, that was an easy part :).
> 
>> Great.  I did review the patch, but did not test as planned.
> 
> Thanks,
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
