Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89FC46B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:45:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u9-v6so13504698qtg.2
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:45:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x188si876663qkb.268.2018.05.03.07.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:45:23 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w43Eia8r051577
	for <linux-mm@kvack.org>; Thu, 3 May 2018 10:45:22 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hr2pcdsvb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 May 2018 10:45:22 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 3 May 2018 15:45:17 +0100
Subject: Re: [PATCH v10 08/25] mm: VMA sequence count
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-9-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423064259.GC114098@rodete-desktop-imager.corp.google.com>
 <06b996b0-b831-3d39-8a99-792abfb6a4d1@linux.vnet.ibm.com>
 <20180501131646.GB118722@rodete-laptop-imager.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 3 May 2018 16:45:08 +0200
MIME-Version: 1.0
In-Reply-To: <20180501131646.GB118722@rodete-laptop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <ec576e05-acfc-1e97-b3c4-1f46093de9ca@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 01/05/2018 15:16, Minchan Kim wrote:
> On Mon, Apr 30, 2018 at 05:14:27PM +0200, Laurent Dufour wrote:
>>
>>
>> On 23/04/2018 08:42, Minchan Kim wrote:
>>> On Tue, Apr 17, 2018 at 04:33:14PM +0200, Laurent Dufour wrote:
>>>> From: Peter Zijlstra <peterz@infradead.org>
>>>>
>>>> Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
>>>> counts such that we can easily test if a VMA is changed.
>>>
>>> So, seqcount is to protect modifying all attributes of vma?
>>
>> The seqcount is used to protect fields that will be used during the speculative
>> page fault like boundaries, protections.
> 
> a VMA is changed, it was rather vague to me at this point.
> If you could specify detail fields or some example what seqcount aim for,
> it would help to review.

Got it, I'll try to make it more explicit in the commit message, mentioning
which fields are used in the speculative path and to be protected using the VMA
sequence counter.
> 
>>
>>>>
>>>> The unmap_page_range() one allows us to make assumptions about
>>>> page-tables; when we find the seqcount hasn't changed we can assume
>>>> page-tables are still valid.
>>>
>>> Hmm, seqcount covers page-table, too.
>>> Please describe what the seqcount want to protect.
>>
>> The calls to vm_write_begin/end() in unmap_page_range() are used to detect when
>> a VMA is being unmap and thus that new page fault should not be satisfied for
>> this VMA. This is protecting the VMA unmapping operation, not the page tables
>> themselves.
> 
> Thanks for the detail. yes, please include this phrase instead of "page-table
> are still valid". It makes me confused.

Sure, will do.

> 
>>
>>>>
>>>> The flip side is that we cannot distinguish between a vma_adjust() and
>>>> the unmap_page_range() -- where with the former we could have
>>>> re-checked the vma bounds against the address.
>>>>
>>>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>>>
>>>> [Port to 4.12 kernel]
>>>> [Build depends on CONFIG_SPECULATIVE_PAGE_FAULT]
>>>> [Introduce vm_write_* inline function depending on
>>>>  CONFIG_SPECULATIVE_PAGE_FAULT]
>>>> [Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
>>>>  using vm_raw_write* functions]
>>>> [Fix a lock dependency warning in mmap_region() when entering the error
>>>>  path]
>>>> [move sequence initialisation INIT_VMA()]
>>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>>> ---
>>>>  include/linux/mm.h       | 44 ++++++++++++++++++++++++++++++++++++++++++++
>>>>  include/linux/mm_types.h |  3 +++
>>>>  mm/memory.c              |  2 ++
>>>>  mm/mmap.c                | 31 +++++++++++++++++++++++++++++++
>>>>  4 files changed, 80 insertions(+)
>>>>
>>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>> index efc1248b82bd..988daf7030c9 100644
>>>> --- a/include/linux/mm.h
>>>> +++ b/include/linux/mm.h
>>>> @@ -1264,6 +1264,9 @@ struct zap_details {
>>>>  static inline void INIT_VMA(struct vm_area_struct *vma)
>>>>  {
>>>>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
>>>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>>> +	seqcount_init(&vma->vm_sequence);
>>>> +#endif
>>>>  }
>>>>  
>>>>  struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>>>> @@ -1386,6 +1389,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
>>>>  	unmap_mapping_range(mapping, holebegin, holelen, 0);
>>>>  }
>>>>  
>>>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>>> +static inline void vm_write_begin(struct vm_area_struct *vma)
>>>> +{
>>>> +	write_seqcount_begin(&vma->vm_sequence);
>>>> +}
>>>> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
>>>> +					 int subclass)
>>>> +{
>>>> +	write_seqcount_begin_nested(&vma->vm_sequence, subclass);
>>>> +}
>>>> +static inline void vm_write_end(struct vm_area_struct *vma)
>>>> +{
>>>> +	write_seqcount_end(&vma->vm_sequence);
>>>> +}
>>>> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
>>>> +{
>>>> +	raw_write_seqcount_begin(&vma->vm_sequence);
>>>> +}
>>>> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
>>>> +{
>>>> +	raw_write_seqcount_end(&vma->vm_sequence);
>>>> +}
>>>> +#else
>>>> +static inline void vm_write_begin(struct vm_area_struct *vma)
>>>> +{
>>>> +}
>>>> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
>>>> +					 int subclass)
>>>> +{
>>>> +}
>>>> +static inline void vm_write_end(struct vm_area_struct *vma)
>>>> +{
>>>> +}
>>>> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
>>>> +{
>>>> +}
>>>> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
>>>> +{
>>>> +}
>>>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>>>> +
>>>>  extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
>>>>  		void *buf, int len, unsigned int gup_flags);
>>>>  extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
>>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>>> index 21612347d311..db5e9d630e7a 100644
>>>> --- a/include/linux/mm_types.h
>>>> +++ b/include/linux/mm_types.h
>>>> @@ -335,6 +335,9 @@ struct vm_area_struct {
>>>>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>>>>  #endif
>>>>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>>>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>>> +	seqcount_t vm_sequence;
>>>> +#endif
>>>>  } __randomize_layout;
>>>>  
>>>>  struct core_thread {
>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>> index f86efcb8e268..f7fed053df80 100644
>>>> --- a/mm/memory.c
>>>> +++ b/mm/memory.c
>>>> @@ -1503,6 +1503,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>>>>  	unsigned long next;
>>>>  
>>>>  	BUG_ON(addr >= end);
>>>
>>> The comment about saying it aims for page-table stability will help.
>>
>> A comment may be added mentioning that we use the seqcount to indicate that the
>> VMA is modified, being unmapped. But there is not a real page table protection,
>> and I think this may be confusing to talk about page table stability here.
> 
> Okay, so here you mean seqcount is not protecting VMA's fields but vma unmap
> operation like you mentioned above. I was confused like below description.
> 
> "The unmap_page_range() one allows us to make assumptions about
> page-tables; when we find the seqcount hasn't changed we can assume
> page-tables are still valid"
> 
> Instead of using page-tables's validness in descriptoin, it would be better
> to use scenario you mentioned about VMA unmap operation and page fault race.

Ok will do that.
Thanks.
