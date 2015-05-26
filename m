Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFE796B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:18:57 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so97429157pac.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:18:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r8si21834286pds.154.2015.05.26.10.18.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:18:57 -0700 (PDT)
Message-ID: <5564A921.2090509@oracle.com>
Date: Tue, 26 May 2015 10:10:57 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/2] alloc_huge_page/hugetlb_reserve_pages race
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com> <1432583887.2185.53.camel@stgolabs.net>
In-Reply-To: <1432583887.2185.53.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/25/2015 12:58 PM, Davidlohr Bueso wrote:
> On Fri, 2015-05-22 at 20:55 -0700, Mike Kravetz wrote:
>> This updated patch set includes new documentation for the region/
>> reserve map routines.  Since I am not the original author of this
>> code, comments would be appreciated.
>>
>> While working on hugetlbfs fallocate support, I noticed the following
>> race in the existing code.  It is unlikely that this race is hit very
>> often in the current code.
>
> Have you actually run into this issue? Can you produce a testcase?

I have not hit this with the current code.  However, the race is as
you describe below.  So, from code examination it is pretty easy to
see.

I have hit this with fallocate testing.  Note that this is a race with
the fault code which instantiates a page and mmap.  In the existing
code, you can only fault in/instantiate a page at a specific virtual
address once.  Therefore, there are a finite number of races possible
for each VMA.  With fallocate, you can hole punch to release the page
and then fault another back in.  My stress testing has this hole punch
then fault sequence happening in several processes while others are
doing mmap/munmap.

I suspect it would also be easy to recreate on a big system with
something like a TB of huge pages.  One process could just fault
in the TB of huge pages while the other mmap/unmap.

>>    However, if more functionality to add and
>> remove pages to hugetlbfs mappings (such as fallocate) is added the
>> likelihood of hitting this race will increase.
>>
>> alloc_huge_page and hugetlb_reserve_pages use information from the
>> reserve map to determine if there are enough available huge pages to
>> complete the operation, as well as adjust global reserve and subpool
>> usage counts.  The order of operations is as follows:
>> - call region_chg() to determine the expected change based on reserve map
>> - determine if enough resources are available for this operation
>> - adjust global counts based on the expected change
>> - call region_add() to update the reserve map
>> The issue is that reserve map could change between the call to region_chg
>> and region_add.  In this case, the counters which were adjusted based on
>> the output of region_chg will not be correct.
>>
>> In order to hit this race today, there must be an existing shared hugetlb
>> mmap created with the MAP_NORESERVE flag.  A page fault to allocate a huge
>> page via this mapping must occur at the same another task is mapping the
>> same region without the MAP_NORESERVE flag.
>
> In the past file regions were serialized by either mmap_sem (exclusive)
> or the hugetlb instantiation mutex (when mmap_sem was shared). With
> finer grained locking, however, we now rely on the resv_map->lock. So I
> guess you are referring to something like this, no?
>
> CPU0 (via vma_[needs/commit]_reservation)  CPU1
> hugetlb_fault				
>    mutex_lock(hash_A)			
>    hugetlb_no_page			
>      alloc_huge_page			shm_get
>         region_chg			  hugetlb_file_setup
>         <accounting updates>		    hugetlb_reserve_pages
> 					      region_chg
>         region_add			      <accounting updates>
> 					      region_add

Yes, that is exactly what I am referring to.  The issue is that the
accounting updates are based on the return value of region_chg.

> Couldn't this race also occur upon concurrent faults on two different
> hashes backed by the same vma?

I do not think we will race in this case.  Two different hashes,
implies two different virtual addresses (mapping index, huge pages).
In this case, the ranges passed to region_chg/region_add will not
intersect.  The race only happens when there is an intersection
of the ranges.

> Anyway, it's memorial day, so I'll take a closer look during the week,
> but you seem to be correct. An alternative could be to continue holding
> the spinlock until the after region_add, but I like your "fixup"
> approach.
>
>> The patch set does not prevent the race from happening.  Rather, it adds
>> simple functionality to detect when the race has occurred.  If a race is
>> detected, then the incorrect counts are adjusted.
>>
>> v2:
>>    Added documentation for the region/reserve map routines
>
> Thanks for doing this, as akpm mentioned, it is much needed. However,
> this should be a new, separate patch.

OK, I can break that out.

>>    Created common routine for vma_commit_reservation and
>>      vma_commit_reservation to help prevent them from drifting
>>      apart in the future.
>>
>> Mike Kravetz (2):
>>    mm/hugetlb: compute/return the number of regions added by region_add()
>>    mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages
>
> Ah, so these two patches are duplicates from your fallocate series,
> right? You should drop those from that patchset then, as bugfixes should
> be separate.

Yes, I will drop them from future versions of fallocate patch set.

> Could you rename patch 2 to something more meaningful? ie:
>
> mm/hugetlb: account for races between region_chg and region_add

Sure.  I'm not sure if I like that name as region_chg and region_add
are not really racing IMO.  Rather, it is the callers of those
routines which expect the reserve map not to change between region_chg
and region_add.

> Also, gosh those function names are nasty and unclear -- I would change
> them to region_prepare and region_commit, or something like that where
> the purpose is more obvious.

Let me think about this.  After staring at the code for several days
the names sort of make sense to me.  However, you are correct in that
they may not make much sense when first looking at the code.

Thanks for the review and all the comments.
-- 
Mike Kravetz

>
> Thanks,
> Davidlohr
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
