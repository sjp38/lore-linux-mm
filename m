Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5BB26B0011
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:11:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f10so2121393qtc.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:11:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f45si4484320qtk.379.2018.03.28.10.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 10:11:07 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SHB60g093196
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:11:07 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h0eefj23v-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:11:06 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 18:11:03 +0100
Subject: Re: [PATCH v9 08/24] mm: Protect VMA modifications using VMA sequence
 count
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-9-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803271454390.41987@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 19:10:53 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803271454390.41987@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <f42499e6-746d-e9d0-2e71-6ee1003c8228@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 27/03/2018 23:57, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 5898255d0aeb..d6533cb85213 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -847,17 +847,18 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  	}
>>  
>>  	if (start != vma->vm_start) {
>> -		vma->vm_start = start;
>> +		WRITE_ONCE(vma->vm_start, start);
>>  		start_changed = true;
>>  	}
>>  	if (end != vma->vm_end) {
>> -		vma->vm_end = end;
>> +		WRITE_ONCE(vma->vm_end, end);
>>  		end_changed = true;
>>  	}
>> -	vma->vm_pgoff = pgoff;
>> +	WRITE_ONCE(vma->vm_pgoff, pgoff);
>>  	if (adjust_next) {
>> -		next->vm_start += adjust_next << PAGE_SHIFT;
>> -		next->vm_pgoff += adjust_next;
>> +		WRITE_ONCE(next->vm_start,
>> +			   next->vm_start + (adjust_next << PAGE_SHIFT));
>> +		WRITE_ONCE(next->vm_pgoff, next->vm_pgoff + adjust_next);
>>  	}
>>  
>>  	if (root) {
>> @@ -1781,6 +1782,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>>  out:
>>  	perf_event_mmap(vma);
>>  
>> +	vm_write_begin(vma);
>>  	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
>>  	if (vm_flags & VM_LOCKED) {
>>  		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
>> @@ -1803,6 +1805,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>>  	vma->vm_flags |= VM_SOFTDIRTY;
>>  
>>  	vma_set_page_prot(vma);
>> +	vm_write_end(vma);
>>  
>>  	return addr;
>>  
> 
> Shouldn't this also protect vma->vm_flags?

Nice catch !
I just found that too while reviewing the entire patch to answer your previous
email.

> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1796,7 +1796,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  					vma == get_gate_vma(current->mm)))
>  			mm->locked_vm += (len >> PAGE_SHIFT);
>  		else
> -			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
> +			WRITE_ONCE(vma->vm_flags,
> +				   vma->vm_flags & VM_LOCKED_CLEAR_MASK);
>  	}
> 
>  	if (file)
> @@ -1809,7 +1810,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	 * then new mapped in-place (which must be aimed as
>  	 * a completely new data area).
>  	 */
> -	vma->vm_flags |= VM_SOFTDIRTY;
> +	WRITE_ONCE(vma->vm_flags, vma->vm_flags | VM_SOFTDIRTY);
> 
>  	vma_set_page_prot(vma);
>  	vm_write_end(vma);
> 
