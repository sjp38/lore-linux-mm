Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 458556B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 06:29:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y1so12234529qti.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 03:29:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 8si3255514qtw.118.2018.04.04.03.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 03:29:01 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w34ARaGc088240
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 06:29:00 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4vs6gn8b-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 06:28:59 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 11:28:56 +0100
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
References: <20180317075119.u6yuem2bhxvggbz3@inn>
 <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803251510040.80485@chino.kir.corp.google.com>
 <aa6f2ff1-ff67-106a-e0e4-522ac82a7bf0@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804031748120.27686@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1804031802110.50064@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 12:28:44 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804031802110.50064@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <964ecdb1-3a2a-96b5-5a9c-5c12f874ea84@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kernel test robot <fengguang.wu@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org



On 04/04/2018 03:03, David Rientjes wrote:
> On Tue, 3 Apr 2018, David Rientjes wrote:
> 
>>>>> I found the root cause of this lockdep warning.
>>>>>
>>>>> In mmap_region(), unmap_region() may be called while vma_link() has not been
>>>>> called. This happens during the error path if call_mmap() failed.
>>>>>
>>>>> The only to fix that particular case is to call
>>>>> seqcount_init(&vma->vm_sequence) when initializing the vma in mmap_region().
>>>>>
>>>>
>>>> Ack, although that would require a fixup to dup_mmap() as well.
>>>
>>> You're right, I'll fix that too.
>>>
>>
>> I also think the following is needed:
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -312,6 +312,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
>>  	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
>>  	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
>>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	seqcount_init(&vma->vm_sequence);
>> +	atomic_set(&vma->vm_ref_count, 0);
>> +#endif
>>  
>>  	err = insert_vm_struct(mm, vma);
>>  	if (err)
>>
> 
> Ugh, I think there are a number of other places where this is needed as 
> well in mm/mmap.c.  I think it would be better to just create a new 
> alloc_vma(unsigned long flags) that all vma allocators can use and for 
> CONFIG_SPECULATIVE_PAGE_FAULT will initialize the seqcount_t and atomic_t.
> 

I don't think this is really needed, most of the time the vma structure is
allocated cleared and is then link to rb tree via vma_link.

The only case generating a locked warning is when the vma is referenced in the
error path before being linked in the mm tree and that is not usual.
