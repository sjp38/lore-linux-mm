Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36CFF6B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 12:04:32 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 126-v6so13738184ybd.18
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 09:04:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c8-v6si1121090ybl.635.2018.04.04.09.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 09:04:31 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w34G3bVf117504
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 12:04:30 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4xdbuhdh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:04:29 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 17:04:26 +0100
Subject: Re: [PATCH v9 15/24] mm: Introduce __vm_normal_page()
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804021616370.104195@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 18:04:15 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021616370.104195@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <c3103568-41b8-ee54-8f4f-16d3e8c1984f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 03/04/2018 01:18, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index a84ddc218bbd..73b8b99f482b 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1263,8 +1263,11 @@ struct zap_details {
>>  	pgoff_t last_index;			/* Highest page->index to unmap */
>>  };
>>  
>> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> -			     pte_t pte, bool with_public_device);
>> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> +			      pte_t pte, bool with_public_device,
>> +			      unsigned long vma_flags);
>> +#define _vm_normal_page(vma, addr, pte, with_public_device) \
>> +	__vm_normal_page(vma, addr, pte, with_public_device, (vma)->vm_flags)
>>  #define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
>>  
>>  struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
> 
> If _vm_normal_page() is a static inline function does it break somehow?  
> It's nice to avoid the #define's.

No problem, I'll create it as a static inline function.

> 
>> diff --git a/mm/memory.c b/mm/memory.c
>> index af0338fbc34d..184a0d663a76 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -826,8 +826,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>>  #else
>>  # define HAVE_PTE_SPECIAL 0
>>  #endif
>> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> -			     pte_t pte, bool with_public_device)
>> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> +			      pte_t pte, bool with_public_device,
>> +			      unsigned long vma_flags)
>>  {
>>  	unsigned long pfn = pte_pfn(pte);
>>  
> 
> Would it be possible to update the comment since the function itself is no 
> longer named vm_normal_page?

Sure.
