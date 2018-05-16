Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 338E16B02D3
	for <linux-mm@kvack.org>; Tue, 15 May 2018 20:42:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c4-v6so1293171pfg.22
        for <linux-mm@kvack.org>; Tue, 15 May 2018 17:42:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x25-v6si1353225pfj.347.2018.05.15.17.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 17:42:47 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
References: <20180515005756.28942-1-ying.huang@intel.com>
	<20180515103812.aapv4b4hbzno52zl@kshutemo-mobl1>
Date: Wed, 16 May 2018 08:42:43 +0800
In-Reply-To: <20180515103812.aapv4b4hbzno52zl@kshutemo-mobl1> (Kirill
	A. Shutemov's message of "Tue, 15 May 2018 13:38:12 +0300")
Message-ID: <878t8kzb0c.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, May 15, 2018 at 08:57:56AM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This is to take better advantage of huge page clearing
>> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
>> when clearing huge page").  Which will clear to access sub-page last
>> to avoid the cache lines of to access sub-page to be evicted when
>> clearing other sub-pages.  This needs to get the address of the
>> sub-page to access, that is, the fault address inside of the huge
>> page.  So the hugetlb no page fault handler is changed to pass that
>> information.  This will benefit workloads which don't access the begin
>> of the huge page after page fault.
>> 
>> With this patch, the throughput increases ~28.1% in vm-scalability
>> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
>> system (44 cores, 88 threads).  The test case creates 88 processes,
>> each process mmap a big anonymous memory area and writes to it from
>> the end to the begin.  For each process, other processes could be seen
>> as other workload which generates heavy cache pressure.  At the same
>> time, the cache miss rate reduced from ~36.3% to ~25.6%, the
>> IPC (instruction per cycle) increased from 0.3 to 0.37, and the time
>> spent in user space is reduced ~19.3%
>> 
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Andi Kleen <andi.kleen@intel.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Shaohua Li <shli@fb.com>
>> Cc: Christopher Lameter <cl@linux.com>
>> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb.c | 12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 129088710510..3de6326abf39 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3677,7 +3677,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>>  
>>  static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  			   struct address_space *mapping, pgoff_t idx,
>> -			   unsigned long address, pte_t *ptep, unsigned int flags)
>> +			   unsigned long faddress, pte_t *ptep, unsigned int flags)
>>  {
>>  	struct hstate *h = hstate_vma(vma);
>>  	int ret = VM_FAULT_SIGBUS;
>> @@ -3686,6 +3686,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	struct page *page;
>>  	pte_t new_pte;
>>  	spinlock_t *ptl;
>> +	unsigned long address = faddress & huge_page_mask(h);
>
> faddress? I would rather keep it address and rename maked out variable to
> 'haddr'. We use 'haddr' for the cause in other places.

I found haddr is popular in huge_memory.c but not used in hugetlb.c at
all.  Is it desirable to start to use "haddr" in hugetlb.c?

Best Regards,
Huang, Ying
