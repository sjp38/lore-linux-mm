Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2506B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 08:53:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w59so13048601wrb.8
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 05:53:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r13si3461331eda.331.2018.04.05.05.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 05:53:34 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w35CogA7083421
	for <linux-mm@kvack.org>; Thu, 5 Apr 2018 08:53:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h5fxtbsek-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:53:32 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 5 Apr 2018 13:53:30 +0100
Subject: Re: [PATCH v9 15/24] mm: Introduce __vm_normal_page()
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180403193927.GD5935@redhat.com>
 <a3446d86-8a29-a9f2-a1fe-b8cc1b748132@linux.vnet.ibm.com>
 <20180404215916.GC3331@redhat.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 5 Apr 2018 14:53:19 +0200
MIME-Version: 1.0
In-Reply-To: <20180404215916.GC3331@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <6ebb4602-9455-65f3-ea60-bfaaee23a859@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 04/04/2018 23:59, Jerome Glisse wrote:
> On Wed, Apr 04, 2018 at 06:26:44PM +0200, Laurent Dufour wrote:
>>
>>
>> On 03/04/2018 21:39, Jerome Glisse wrote:
>>> On Tue, Mar 13, 2018 at 06:59:45PM +0100, Laurent Dufour wrote:
>>>> When dealing with the speculative fault path we should use the VMA's field
>>>> cached value stored in the vm_fault structure.
>>>>
>>>> Currently vm_normal_page() is using the pointer to the VMA to fetch the
>>>> vm_flags value. This patch provides a new __vm_normal_page() which is
>>>> receiving the vm_flags flags value as parameter.
>>>>
>>>> Note: The speculative path is turned on for architecture providing support
>>>> for special PTE flag. So only the first block of vm_normal_page is used
>>>> during the speculative path.
>>>
>>> Might be a good idea to explicitly have SPECULATIVE Kconfig option depends
>>> on ARCH_PTE_SPECIAL and a comment for !HAVE_PTE_SPECIAL in the function
>>> explaining that speculative page fault should never reach that point.
>>
>> Unfortunately there is no ARCH_PTE_SPECIAL in the config file, it is defined in
>> the per architecture header files.
>> So I can't do anything in the Kconfig file
> 
> Maybe adding a new Kconfig symbol for ARCH_PTE_SPECIAL very much like
> others ARCH_HAS_
> 
>>
>> However, I can check that at build time, and doing such a check in
>> __vm_normal_page sounds to be a good place, like that:
>>
>> @@ -869,6 +870,14 @@ struct page *__vm_normal_page(struct vm_area_struct *vma,
>> unsigned long addr,
>>
>>         /* !HAVE_PTE_SPECIAL case follows: */
>>
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +       /* This part should never get called when the speculative page fault
>> +        * handler is turned on. This is mainly because we can't rely on
>> +        * vm_start.
>> +        */
>> +#error CONFIG_SPECULATIVE_PAGE_FAULT requires HAVE_PTE_SPECIAL
>> +#endif
>> +
>>         if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
>>                 if (vma_flags & VM_MIXEDMAP) {
>>                         if (!pfn_valid(pfn))
>>
> 
> I am not a fan of #if/#else/#endif in code. But that's a taste thing.
> I honnestly think that adding a Kconfig for special pte is the cleanest
> solution.

I do agree, but this should be done in a separate series.

I'll see how this could be done but there are some arch (like powerpc) where
this is a bit obfuscated for unknown reason.

For the time being, I'll remove the check and just let the comment in place.
