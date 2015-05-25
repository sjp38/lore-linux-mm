Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 641956B0131
	for <linux-mm@kvack.org>; Mon, 25 May 2015 15:58:31 -0400 (EDT)
Received: by wgme6 with SMTP id e6so11458246wgm.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 12:58:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si14151486wic.112.2015.05.25.12.58.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 May 2015 12:58:29 -0700 (PDT)
Message-ID: <1432583887.2185.53.camel@stgolabs.net>
Subject: Re: [PATCH v2 0/2] alloc_huge_page/hugetlb_reserve_pages race
From: Davidlohr Bueso <dave@stgolabs.net>
In-Reply-To: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 25 May 2015 12:58:07 -0700
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2015-05-22 at 20:55 -0700, Mike Kravetz wrote:
> This updated patch set includes new documentation for the region/
> reserve map routines.  Since I am not the original author of this
> code, comments would be appreciated.
> 
> While working on hugetlbfs fallocate support, I noticed the following
> race in the existing code.  It is unlikely that this race is hit very
> often in the current code.

Have you actually run into this issue? Can you produce a testcase?

>   However, if more functionality to add and
> remove pages to hugetlbfs mappings (such as fallocate) is added the
> likelihood of hitting this race will increase.
> 
> alloc_huge_page and hugetlb_reserve_pages use information from the
> reserve map to determine if there are enough available huge pages to
> complete the operation, as well as adjust global reserve and subpool
> usage counts.  The order of operations is as follows:
> - call region_chg() to determine the expected change based on reserve map
> - determine if enough resources are available for this operation
> - adjust global counts based on the expected change
> - call region_add() to update the reserve map
> The issue is that reserve map could change between the call to region_chg
> and region_add.  In this case, the counters which were adjusted based on
> the output of region_chg will not be correct.
> 
> In order to hit this race today, there must be an existing shared hugetlb
> mmap created with the MAP_NORESERVE flag.  A page fault to allocate a huge
> page via this mapping must occur at the same another task is mapping the
> same region without the MAP_NORESERVE flag.

In the past file regions were serialized by either mmap_sem (exclusive)
or the hugetlb instantiation mutex (when mmap_sem was shared). With
finer grained locking, however, we now rely on the resv_map->lock. So I
guess you are referring to something like this, no?

CPU0 (via vma_[needs/commit]_reservation)  CPU1
hugetlb_fault				
  mutex_lock(hash_A)			  
  hugetlb_no_page			
    alloc_huge_page			shm_get  
       region_chg			  hugetlb_file_setup
       <accounting updates>		    hugetlb_reserve_pages
					      region_chg
       region_add			      <accounting updates>
					      region_add

Couldn't this race also occur upon concurrent faults on two different
hashes backed by the same vma?

Anyway, it's memorial day, so I'll take a closer look during the week,
but you seem to be correct. An alternative could be to continue holding
the spinlock until the after region_add, but I like your "fixup"
approach.

> The patch set does not prevent the race from happening.  Rather, it adds
> simple functionality to detect when the race has occurred.  If a race is
> detected, then the incorrect counts are adjusted.
> 
> v2:
>   Added documentation for the region/reserve map routines

Thanks for doing this, as akpm mentioned, it is much needed. However,
this should be a new, separate patch.

>   Created common routine for vma_commit_reservation and
>     vma_commit_reservation to help prevent them from drifting
>     apart in the future.
> 
> Mike Kravetz (2):
>   mm/hugetlb: compute/return the number of regions added by region_add()
>   mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages

Ah, so these two patches are duplicates from your fallocate series,
right? You should drop those from that patchset then, as bugfixes should
be separate.

Could you rename patch 2 to something more meaningful? ie:

mm/hugetlb: account for races between region_chg and region_add

Also, gosh those function names are nasty and unclear -- I would change
them to region_prepare and region_commit, or something like that where
the purpose is more obvious.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
