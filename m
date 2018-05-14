Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFB76B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:25:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w26-v6so15772203qto.4
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:25:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w200-v6si9447034qkw.173.2018.05.14.08.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:25:18 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4EFJvev076465
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:25:17 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hya0aharh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:25:16 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 14 May 2018 16:25:13 +0100
Subject: Re: [PATCH v10 09/25] mm: protect VMA modifications using VMA
 sequence count
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423071941.GD114098@rodete-desktop-imager.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 14 May 2018 17:25:02 +0200
MIME-Version: 1.0
In-Reply-To: <20180423071941.GD114098@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <3f655c5b-bc0d-1766-d0a0-5645a8bf27ab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 23/04/2018 09:19, Minchan Kim wrote:
> On Tue, Apr 17, 2018 at 04:33:15PM +0200, Laurent Dufour wrote:
>> The VMA sequence count has been introduced to allow fast detection of
>> VMA modification when running a page fault handler without holding
>> the mmap_sem.
>>
>> This patch provides protection against the VMA modification done in :
>> 	- madvise()
>> 	- mpol_rebind_policy()
>> 	- vma_replace_policy()
>> 	- change_prot_numa()
>> 	- mlock(), munlock()
>> 	- mprotect()
>> 	- mmap_region()
>> 	- collapse_huge_page()
>> 	- userfaultd registering services
>>
>> In addition, VMA fields which will be read during the speculative fault
>> path needs to be written using WRITE_ONCE to prevent write to be split
>> and intermediate values to be pushed to other CPUs.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  fs/proc/task_mmu.c |  5 ++++-
>>  fs/userfaultfd.c   | 17 +++++++++++++----
>>  mm/khugepaged.c    |  3 +++
>>  mm/madvise.c       |  6 +++++-
>>  mm/mempolicy.c     | 51 ++++++++++++++++++++++++++++++++++-----------------
>>  mm/mlock.c         | 13 ++++++++-----
>>  mm/mmap.c          | 22 +++++++++++++---------
>>  mm/mprotect.c      |  4 +++-
>>  mm/swap_state.c    |  8 ++++++--
>>  9 files changed, 89 insertions(+), 40 deletions(-)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index c486ad4b43f0..aeb417f28839 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -1136,8 +1136,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>>  					goto out_mm;
>>  				}
>>  				for (vma = mm->mmap; vma; vma = vma->vm_next) {
>> -					vma->vm_flags &= ~VM_SOFTDIRTY;
>> +					vm_write_begin(vma);
>> +					WRITE_ONCE(vma->vm_flags,
>> +						   vma->vm_flags & ~VM_SOFTDIRTY);
>>  					vma_set_page_prot(vma);
>> +					vm_write_end(vma);
> 
> trivial:
> 
> I think It's tricky to maintain that VMA fields to be read during SPF should be
> (READ|WRITE_ONCE). I think we need some accessor to read/write them rather than
> raw accessing like like vma_set_page_prot. Maybe spf prefix would be helpful. 
> 
> 	vma_spf_set_value(vma, vm_flags, val);
> 
> We also add some markers in vm_area_struct's fileds to indicate that
> people shouldn't access those fields directly.
> 
> Just a thought.

At the beginning I was liking that idea but...

I'm not sure this will change a lot the code, most of the time the
vm_write_begin()/end() are surrounding part of code larger than one VMA
structure's field change. For this particular case and few others this will be
applicable but that's not the majority.

Thanks,
Laurent.

> 
> 
>>  				}
>>  				downgrade_write(&mm->mmap_sem);
> 
> 
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index fe079756bb18..8a8a402ed59f 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -575,6 +575,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
>>   * the readahead.
>>   *
>>   * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
>> + * This is needed to ensure the VMA will not be freed in our back. In the case
>> + * of the speculative page fault handler, this cannot happen, even if we don't
>> + * hold the mmap_sem. Callees are assumed to take care of reading VMA's fields
> 
> I guess reader would be curious on *why* is safe with SPF.
> Comment about the why could be helpful for reviewer.
> 
>> + * using READ_ONCE() to read consistent values.
>>   */
>>  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>  				struct vm_fault *vmf)
>> @@ -668,9 +672,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
>>  				     unsigned long *start,
>>  				     unsigned long *end)
>>  {
>> -	*start = max3(lpfn, PFN_DOWN(vma->vm_start),
>> +	*start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
>>  		      PFN_DOWN(faddr & PMD_MASK));
>> -	*end = min3(rpfn, PFN_DOWN(vma->vm_end),
>> +	*end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
>>  		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
>>  }
>>  
>> -- 
>> 2.7.4
>>
> 
