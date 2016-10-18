Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDD1D6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 21:19:05 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w141so100704186itc.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 18:19:05 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v80si19509472ioi.180.2016.10.17.18.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 18:19:01 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
 <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
 <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
 <58009BE2.5010805@redhat.com>
 <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
 <87h98btvk4.fsf@linux.vnet.ibm.com>
 <f8821116-dfe2-4c47-2add-c6e18f2e9fa6@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d90321d5-f81a-2752-fea2-fae11556bdba@oracle.com>
Date: Mon, 17 Oct 2016 18:18:50 -0700
MIME-Version: 1.0
In-Reply-To: <f8821116-dfe2-4c47-2add-c6e18f2e9fa6@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com

On 10/17/2016 03:53 PM, Mike Kravetz wrote:
> On 10/16/2016 10:04 PM, Aneesh Kumar K.V wrote:
>>
>> looking at that commit, I am not sure region_chg output indicate a hole
>> punched. ie, w.r.t private mapping when we mmap, we don't do a
>> region_chg (hugetlb_reserve_page()). So with a fault later when we
>> call vma_needs_reservation, we will find region_chg returning >= 0 right ?
>>
> 
> Let me try to explain.
> 
> When a private mapping is created, hugetlb_reserve_pages to reserve
> huge pages for the mapping.  A reserve map is created and installed
> in the (vma_private) VMA.  No reservation entries are actually created
> for the mapping.  But, hugetlb_acct_memory() is called to reserve
> pages for the mapping in the global pool.  This will adjust (increment)
> the global reserved huge page counter (resv_huge_pages).
> 
> As pages within the private mapping are faulted in, huge_page_alloc() is
> called to allocate the pages.  Within alloc_huge_page, vma_needs_reservation
> is called to determine if there is a reservation for this allocation.
> If there is a reservation, the global count is adjusted (decremented).
> In any case where a page is returned to the caller, vma_commit_reservation
> is called and an entry for the page is created in the reserve map (VMA
> vma_private) of the mapping.
> 
> Once a page is instantiated within the private mapping, an entry exists
> in the reserve map and the reserve count has been adjusted to indicate
> that the reserve has been consumed.  Subsequent faults will not instantiate
> a new page unless the original is somehow removed from the mapping.  The
> only way a user can remove a page from the mapping is via a hole punch or
> truncate operation.  Note that hole punch and truncate for huge pages
> only to apply to hugetlbfs backed mappings and not anonymous mappings.
> 
> hole punch and truncate will unmap huge pages from any private private
> mapping associated with the same offset in the hugetlbfs file.  However,
> they will not remove entries from the VMA private_data reserve maps.
> Nor, will they adjust global reserve counts based on private mappings.

Question.  Should hole punch and truncate unmap private mappings?
Commit 67961f9db8c4 is just trying to correctly handle that situation.
If we do not unmap the private pages, then there is no need for this code.

-- 
Mike Kravetz

> 
> Now suppose a subsequent fault happened for a page private mapping removed
> via hole punch or truncate.  Prior to commit 67961f9db8c4,
> vma_needs_reservation ALWAYS returned false to indicate that a reservation
> existed for the page.  So, alloc_huge_page would consume a reserved page.
> The problem is that the reservation was consumed at the time of the first
> fault and no longer exist.  This caused the global reserve count to be
> incorrect.
> 
> Commit 67961f9db8c4 looks at the VMA private reserve map to determine if
> the original reservation was consumed.  If an entry exists in the map, it
> is assumed the reservation was consumed and no longer exists.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
