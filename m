Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A755280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:57:29 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z37so3078518qtj.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 00:57:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p60si4003053qtd.169.2018.01.17.00.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 00:57:28 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0H8uSWR064712
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:57:27 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fj1v9v1w2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:57:27 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 17 Jan 2018 08:57:24 -0000
Subject: Re: [PATCH v6 03/24] mm: Dont assume page-table invariance during
 faults
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-4-git-send-email-ldufour@linux.vnet.ibm.com>
 <87d129tccz.fsf@linux.intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 17 Jan 2018 09:57:14 +0100
MIME-Version: 1.0
In-Reply-To: <87d129tccz.fsf@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <476660c5-771c-0125-7d04-0e5a8d8bf65d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 17/01/2018 04:04, Andi Kleen wrote:
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> One of the side effects of speculating on faults (without holding
>> mmap_sem) is that we can race with free_pgtables() and therefore we
>> cannot assume the page-tables will stick around.
>>
>> Remove the reliance on the pte pointer.
> 
> This needs a lot more explanation. So why is this code not needed with
> SPF only?

Hi Andi,

This is a good question, and I should detail that more in the commit's log.

Here is my response to Balbir when he asked for:

On 10/07/2017 19:48, Laurent Dufour wrote:
> On 07/07/2017 09:07, Balbir Singh wrote:
>> On Fri, 2017-06-16 at 19:52 +0200, Laurent Dufour wrote:
>>> From: Peter Zijlstra <peterz@infradead.org>
>>>
>>> One of the side effects of speculating on faults (without holding
>>> mmap_sem) is that we can race with free_pgtables() and therefore we
>>> cannot assume the page-tables will stick around.
>>>
>>> Remove the relyance on the pte pointer.
>>              ^^ reliance
>>
>> Looking at the changelog and the code the impact is not clear.
>> It looks like after this patch we always assume the pte is not
>> the same. What is the impact of this patch?
> 
> Hi Balbir,
> 
> In most of the case pte_unmap_same() was returning 1, which meaning that
> do_swap_page() should do its processing.
> 
> So in most of the case there will be no impact.
> 
> Now regarding the case where pte_unmap_safe() was returning 0, and thus
> do_swap_page return 0 too, this happens when the page has already been
> swapped back. This may happen before do_swap_page() get called or while in
> the call to do_swap_page(). In that later case, the check done when
> swapin_readahead() returns will detect that case.
> 
> The worst case would be that a page fault is occuring on 2 threads at the
> same time on the same swapped out page. In that case one thread will take
> much time looping in __read_swap_cache_async(). But in the regular page
> fault path, this is even worse since the thread would wait for semaphore to
> be released before starting anything.
> 
> Cheers,
> Laurent.
> 

I'll add that to the commit's log.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
