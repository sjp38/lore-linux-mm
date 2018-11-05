Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF2056B0281
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:44:48 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id 123-v6so8535210ywt.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:44:48 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g127-v6si27014553ybf.30.2018.11.05.13.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:44:47 -0800 (PST)
Subject: Re: [PATCH] hugetlbfs: fix kernel BUG at fs/hugetlbfs/inode.c:444!
References: <20181105212315.14125-1-mike.kravetz@oracle.com>
 <20181105133013.35fdb58c16d9318538fc0cb6@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8d4b90a9-1e7c-f748-8bd2-fada0175aa31@oracle.com>
Date: Mon, 5 Nov 2018 13:44:32 -0800
MIME-Version: 1.0
In-Reply-To: <20181105133013.35fdb58c16d9318538fc0cb6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>

On 11/5/18 1:30 PM, Andrew Morton wrote:
> On Mon,  5 Nov 2018 13:23:15 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> This bug has been experienced several times by Oracle DB team.
>> The BUG is in the routine remove_inode_hugepages() as follows:
>> 	/*
>> 	 * If page is mapped, it was faulted in after being
>> 	 * unmapped in caller.  Unmap (again) now after taking
>> 	 * the fault mutex.  The mutex will prevent faults
>> 	 * until we finish removing the page.
>> 	 *
>> 	 * This race can only happen in the hole punch case.
>> 	 * Getting here in a truncate operation is a bug.
>> 	 */
>> 	if (unlikely(page_mapped(page))) {
>> 		BUG_ON(truncate_op);
>>
>> In this case, the elevated map count is not the result of a race.
>> Rather it was incorrectly incremented as the result of a bug in the
>> huge pmd sharing code.  Consider the following:
>> - Process A maps a hugetlbfs file of sufficient size and alignment
>>   (PUD_SIZE) that a pmd page could be shared.
>> - Process B maps the same hugetlbfs file with the same size and alignment
>>   such that a pmd page is shared.
>> - Process B then calls mprotect() to change protections for the mapping
>>   with the shared pmd.  As a result, the pmd is 'unshared'.
>> - Process B then calls mprotect() again to chage protections for the
>>   mapping back to their original value.  pmd remains unshared.
>> - Process B then forks and process C is created.  During the fork process,
>>   we do dup_mm -> dup_mmap -> copy_page_range to copy page tables.  Copying
>>   page tables for hugetlb mappings is done in the routine
>>   copy_hugetlb_page_range.
>>
>> In copy_hugetlb_page_range(), the destination pte is obtained by:
>> 	dst_pte = huge_pte_alloc(dst, addr, sz);
>> If pmd sharing is possible, the returned pointer will be to a pte in
>> an existing page table.  In the situation above, process C could share
>> with either process A or process B.  Since process A is first in the
>> list, the returned pte is a pointer to a pte in process A's page table.
>>
>> However, the following check for pmd sharing is in copy_hugetlb_page_range.
>> 	/* If the pagetables are shared don't copy or take references */
>> 	if (dst_pte == src_pte)
>> 		continue;
>>
>> Since process C is sharing with process A instead of process B, the above
>> test fails.  The code in copy_hugetlb_page_range which follows assumes
>> dst_pte points to a huge_pte_none pte.  It copies the pte entry from
>> src_pte to dst_pte and increments this map count of the associated page.
>> This is how we end up with an elevated map count.
>>
>> To solve, check the dst_pte entry for huge_pte_none.  If !none, this
>> implies PMD sharing so do not copy.
>>
> 
> Does it warrant a cc:stable?

My apologies,  yes it does.  Here are the additional tags:

Fixes: c5c99429fa57 ("fix hugepages leak due to pagetable page sharing")
Cc: <stable@vger.kernel.org>

Let me know if you want me to resend with these.
-- 
Mike Kravetz
