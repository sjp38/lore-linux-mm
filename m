Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3A36B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:55:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a47so11816280wra.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 23:55:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y4si4611539wme.142.2017.08.30.23.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 23:55:33 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7V6rpQg093466
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:55:32 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cpca8d89d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:55:31 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 31 Aug 2017 16:55:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7V6tSeZ42467478
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 16:55:28 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7V6tIXG007752
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 16:55:18 +1000
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
 <12d54f18-6dec-5067-db87-d1a176d5160f@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 31 Aug 2017 12:25:16 +0530
MIME-Version: 1.0
In-Reply-To: <12d54f18-6dec-5067-db87-d1a176d5160f@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <0add5ad0-fd3d-efb7-f00c-7232dfc768af@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/30/2017 03:02 PM, Laurent Dufour wrote:
> On 30/08/2017 07:58, Peter Zijlstra wrote:
>> On Wed, Aug 30, 2017 at 10:33:50AM +0530, Anshuman Khandual wrote:
>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>> index a497024..08f3042 100644
>>> --- a/mm/filemap.c
>>> +++ b/mm/filemap.c
>>> @@ -1181,6 +1181,18 @@ int __lock_page_killable(struct page *__page)
>>>  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>>>                          unsigned int flags)
>>>  {
>>> +       if (flags & FAULT_FLAG_SPECULATIVE) {
>>> +               if (flags & FAULT_FLAG_KILLABLE) {
>>> +                       int ret;
>>> +
>>> +                       ret = __lock_page_killable(page);
>>> +                       if (ret)
>>> +                               return 0;
>>> +               } else
>>> +                       __lock_page(page);
>>> +               return 1;
>>> +       }
>>> +
>>>         if (flags & FAULT_FLAG_ALLOW_RETRY) {
>>>                 /*
>>>                  * CAUTION! In this case, mmap_sem is not released
>>
>> Yeah, that looks right.
> 
> Hum, I'm wondering if FAULT_FLAG_RETRY_NOWAIT should be forced in the
> speculative path in that case to match the semantics of
> __lock_page_or_retry().

Doing that would force us to have another retry through classic fault
path wasting all the work done till now through SPF. Hence it may be
better to just wait, get the lock here and complete the fault. Peterz,
would you agree ? Or we should do as suggested by Laurent. More over,
forcing FAULT_FLAG_RETRY_NOWAIT on FAULT_FLAG_SPECULTIVE at this point
would look like a hack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
