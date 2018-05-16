Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9462A6B0303
	for <linux-mm@kvack.org>; Wed, 16 May 2018 02:42:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l8-v6so2794234qtb.11
        for <linux-mm@kvack.org>; Tue, 15 May 2018 23:42:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g18-v6si1918776qvd.192.2018.05.15.23.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 23:42:58 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4G6fRYn091335
	for <linux-mm@kvack.org>; Wed, 16 May 2018 02:42:57 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j0f6g12an-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 May 2018 02:42:57 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 16 May 2018 07:42:54 +0100
Subject: Re: [PATCH v10 23/25] mm: add speculative page fault vmstats
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-24-git-send-email-ldufour@linux.vnet.ibm.com>
 <CADAEsF-DbqdOWcbzjvOTbrounCQP5pLmAZBKByfG165bu82_pA@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 16 May 2018 08:42:43 +0200
MIME-Version: 1.0
In-Reply-To: <CADAEsF-DbqdOWcbzjvOTbrounCQP5pLmAZBKByfG165bu82_pA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <5e98d70e-5eb0-32d0-f370-f0946fd17b49@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Balbir Singh <bsingharora@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 16/05/2018 04:50, Ganesh Mahendran wrote:
> 2018-04-17 22:33 GMT+08:00 Laurent Dufour <ldufour@linux.vnet.ibm.com>:
>> Add speculative_pgfault vmstat counter to count successful speculative page
>> fault handling.
>>
>> Also fixing a minor typo in include/linux/vm_event_item.h.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  include/linux/vm_event_item.h | 3 +++
>>  mm/memory.c                   | 1 +
>>  mm/vmstat.c                   | 5 ++++-
>>  3 files changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
>> index 5c7f010676a7..a240acc09684 100644
>> --- a/include/linux/vm_event_item.h
>> +++ b/include/linux/vm_event_item.h
>> @@ -111,6 +111,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>>                 SWAP_RA,
>>                 SWAP_RA_HIT,
>>  #endif
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +               SPECULATIVE_PGFAULT,
>> +#endif
>>                 NR_VM_EVENT_ITEMS
>>  };
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 425f07e0bf38..1cd5bc000643 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4508,6 +4508,7 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>          * If there is no need to retry, don't return the vma to the caller.
>>          */
>>         if (ret != VM_FAULT_RETRY) {
>> +               count_vm_event(SPECULATIVE_PGFAULT);
>>                 put_vma(vmf.vma);
>>                 *vma = NULL;
>>         }
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 536332e988b8..c6b49bfa8139 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -1289,7 +1289,10 @@ const char * const vmstat_text[] = {
>>         "swap_ra",
>>         "swap_ra_hit",
>>  #endif
>> -#endif /* CONFIG_VM_EVENTS_COUNTERS */
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +       "speculative_pgfault"
> 
> "speculative_pgfault",
> will be better. :)

Sure !

Thanks.

> 
>> +#endif
>> +#endif /* CONFIG_VM_EVENT_COUNTERS */
>>  };
>>  #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
>>
>> --
>> 2.7.4
>>
> 
