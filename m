Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 605AF6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 05:11:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b192-v6so1620429wmb.1
        for <linux-mm@kvack.org>; Fri, 04 May 2018 02:11:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q11-v6si1716594edj.431.2018.05.04.02.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 02:11:10 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w44998t2118100
	for <linux-mm@kvack.org>; Fri, 4 May 2018 05:11:08 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hrjymcv95-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 May 2018 05:11:08 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 4 May 2018 10:11:05 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v10 12/25] mm: cache some VMA fields in the vm_fault
 structure
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-13-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423074221.GE114098@rodete-desktop-imager.corp.google.com>
 <cd27f249-6c78-ccbb-c8f4-a8d8f7a3cd60@linux.vnet.ibm.com>
 <20180503154211.GA180804@rodete-laptop-imager.corp.google.com>
Date: Fri, 4 May 2018 11:10:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180503154211.GA180804@rodete-laptop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <580c2760-2157-61fe-01ff-f928516fa23f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 03/05/2018 17:42, Minchan Kim wrote:
> On Thu, May 03, 2018 at 02:25:18PM +0200, Laurent Dufour wrote:
>> On 23/04/2018 09:42, Minchan Kim wrote:
>>> On Tue, Apr 17, 2018 at 04:33:18PM +0200, Laurent Dufour wrote:
>>>> When handling speculative page fault, the vma->vm_flags and
>>>> vma->vm_page_prot fields are read once the page table lock is released. So
>>>> there is no more guarantee that these fields would not change in our back
>>>> They will be saved in the vm_fault structure before the VMA is checked for
>>>> changes.
>>>
>>> Sorry. I cannot understand.
>>> If it is changed under us, what happens? If it's critical, why cannot we
>>> check with seqcounter?
>>> Clearly, I'm not understanding the logic here. However, it's a global
>>> change without CONFIG_SPF so I want to be more careful.
>>> It would be better to describe why we need to sanpshot those values
>>> into vm_fault rather than preventing the race.
>>
>> The idea is to go forward processing the page fault using the VMA's fields
>> values saved in the vm_fault structure. Then once the pte are locked, the
>> vma->sequence_counter is checked again and if something has changed in our back
>> the speculative page fault processing is aborted.
> 
> Sorry, still I don't understand why we should capture some fields to vm_fault.
> If we found vma->seq_cnt is changed under pte lock, can't we just bail out and
> fallback to classic fault handling?
> 
> Maybe, I'm missing something clear now. It would be really helpful to understand
> if you give some exmaple.

I'd rather say that I was not clear enough ;)

Here is the point, when we deal with a speculative page fault, the mmap_sem is
not taken, so parallel VMA's changes can occurred. When a VMA change is done
which will impact the page fault processing, we assumed that the VMA sequence
counter will be changed.

In the page fault processing, at the time the PTE is locked, we checked the VMA
sequence counter to detect changes done in our back. If no change is detected
we can continue further. But this doesn't prevent the VMA to not be changed in
our back while the PTE is locked. So VMA's fields which are used while the PTE
is locked must be saved to ensure that we are using *static* values.
This is important since the PTE changes will be made on regards to these VMA
fields and they need to be consistent. This concerns the vma->vm_flags and
vma->vm_page_prot VMA fields.

I hope I make this clear enough this time.

Thanks,
Laurent.
