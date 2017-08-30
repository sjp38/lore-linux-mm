Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05E1F6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:32:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u15so11599558pgb.7
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 02:32:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 34si4124727plp.495.2017.08.30.02.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 02:32:53 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7U9WNDY007260
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:32:52 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cnss1jx0q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:32:52 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 30 Aug 2017 10:32:49 +0100
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
 <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
 <848fa2c6-dbda-9a1e-2efd-3ce9b083365e@linux.vnet.ibm.com>
 <20170829134550.t7du5zdssvlzemtk@hirez.programming.kicks-ass.net>
 <ab0634c4-274d-208f-fc4b-43991986bacf@linux.vnet.ibm.com>
 <20170830055800.GG32112@worktop.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 30 Aug 2017 11:32:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170830055800.GG32112@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <12d54f18-6dec-5067-db87-d1a176d5160f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 30/08/2017 07:58, Peter Zijlstra wrote:
> On Wed, Aug 30, 2017 at 10:33:50AM +0530, Anshuman Khandual wrote:
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index a497024..08f3042 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -1181,6 +1181,18 @@ int __lock_page_killable(struct page *__page)
>>  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>>                          unsigned int flags)
>>  {
>> +       if (flags & FAULT_FLAG_SPECULATIVE) {
>> +               if (flags & FAULT_FLAG_KILLABLE) {
>> +                       int ret;
>> +
>> +                       ret = __lock_page_killable(page);
>> +                       if (ret)
>> +                               return 0;
>> +               } else
>> +                       __lock_page(page);
>> +               return 1;
>> +       }
>> +
>>         if (flags & FAULT_FLAG_ALLOW_RETRY) {
>>                 /*
>>                  * CAUTION! In this case, mmap_sem is not released
> 
> Yeah, that looks right.

Hum, I'm wondering if FAULT_FLAG_RETRY_NOWAIT should be forced in the
speculative path in that case to match the semantics of
__lock_page_or_retry().

> 
>> @@ -4012,17 +4010,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>                 goto unlock;
>>         }
>>
>> +       if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma)) {
>>                 trace_spf_vma_notsup(_RET_IP_, vma, address);
>>                 goto unlock;
>>         }
> 
> As riel pointed out on IRC slightly later, private file maps also need
> ->anon_vma and those actually have ->vm_ops IIRC so the condition needs
> to be slightly more complicated.

Yes I read again the code and lead to the same conclusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
