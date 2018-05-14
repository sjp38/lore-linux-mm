Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFF36B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:10:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p126-v6so4339297qke.6
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:10:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r35-v6si1330153qtr.41.2018.05.14.08.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:10:04 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4EF5KJA136424
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:10:03 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hyaqcy1q5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:10:03 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 14 May 2018 16:10:00 +0100
Subject: Re: [PATCH v10 06/25] mm: make pte_unmap_same compatible with SPF
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <CAOaiJ-n6P-hjBEkiR4+MyFYunocPgzAYkG1wALDcmi7ROe4-ag@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 14 May 2018 17:09:48 +0200
MIME-Version: 1.0
In-Reply-To: <CAOaiJ-n6P-hjBEkiR4+MyFYunocPgzAYkG1wALDcmi7ROe4-ag@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e543c7a9-5aff-3f87-4ccf-e7da345f5bb1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>



On 10/05/2018 18:15, vinayak menon wrote:
> On Tue, Apr 17, 2018 at 8:03 PM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
>> pte_unmap_same() is making the assumption that the page table are still
>> around because the mmap_sem is held.
>> This is no more the case when running a speculative page fault and
>> additional check must be made to ensure that the final page table are still
>> there.
>>
>> This is now done by calling pte_spinlock() to check for the VMA's
>> consistency while locking for the page tables.
>>
>> This is requiring passing a vm_fault structure to pte_unmap_same() which is
>> containing all the needed parameters.
>>
>> As pte_spinlock() may fail in the case of a speculative page fault, if the
>> VMA has been touched in our back, pte_unmap_same() should now return 3
>> cases :
>>         1. pte are the same (0)
>>         2. pte are different (VM_FAULT_PTNOTSAME)
>>         3. a VMA's changes has been detected (VM_FAULT_RETRY)
>>
>> The case 2 is handled by the introduction of a new VM_FAULT flag named
>> VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
>> If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
>> page fault while holding the mmap_sem.
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  include/linux/mm.h |  1 +
>>  mm/memory.c        | 39 ++++++++++++++++++++++++++++-----------
>>  2 files changed, 29 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 4d1aff80669c..714da99d77a3 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1208,6 +1208,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
>>  #define VM_FAULT_NEEDDSYNC  0x2000     /* ->fault did not modify page tables
>>                                          * and needs fsync() to complete (for
>>                                          * synchronous page faults in DAX) */
>> +#define VM_FAULT_PTNOTSAME 0x4000      /* Page table entries have changed */
> 
> 
> This has to be added to VM_FAULT_RESULT_TRACE ?

Indeed there is no chance that the macro VM_FAULT_RESULT_TRACE would have to
translate that code to a string since VM_FAULT_PTNOTSAME is currently only
returned by pte_unmap_same() and then converted by its only caller
do_swap_page() to return 0. So VM_FAULT_PTNOTSAME is not expected to be seen
outside of these services which are never using VM_FAULT_RESULT_TRACE().

This being said, this may be a good idea to add it in the case of future
potential usage.
