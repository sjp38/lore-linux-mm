Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5C56B0292
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:18:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q16so6265721pgc.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 06:18:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n22si2293680pfj.334.2017.08.29.06.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 06:18:37 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7TDIOHO078910
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:18:36 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cn3jfb186-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:18:36 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 29 Aug 2017 14:18:33 +0100
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
 <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 29 Aug 2017 15:18:25 +0200
MIME-Version: 1.0
In-Reply-To: <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <848fa2c6-dbda-9a1e-2efd-3ce9b083365e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 29/08/2017 14:04, Peter Zijlstra wrote:
> On Tue, Aug 29, 2017 at 09:59:30AM +0200, Laurent Dufour wrote:
>> On 27/08/2017 02:18, Kirill A. Shutemov wrote:
>>>> +
>>>> +	if (unlikely(!vma->anon_vma))
>>>> +		goto unlock;
>>>
>>> It deserves a comment.
>>
>> You're right I'll add it in the next version.
>> For the record, the root cause is that __anon_vma_prepare() requires the
>> mmap_sem to be held because vm_next and vm_prev must be safe.
> 
> But should that test not be:
> 
> 	if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma))
> 		goto unlock;
> 
> Because !anon vmas will never have ->anon_vma set and you don't want to
> exclude those.

Yes in the case we later allow non anonymous vmas to be handled.
Currently only anonymous vmas are supported so the check is good enough,
isn't it ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
