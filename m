Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5D536B0311
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 11:29:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 23so1487007wry.4
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:29:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j1si209133wrb.194.2017.07.06.08.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 08:29:36 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v66FSgf2054232
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 11:29:34 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bhqu705x1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jul 2017 11:29:34 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 6 Jul 2017 16:29:32 +0100
Subject: Re: [RFC v5 09/11] mm: Try spin lock in speculative path
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
 <3af22f3b-03ab-1d37-b2b1-b616adde7eb6@linux.vnet.ibm.com>
 <20170706144852.fwtuygj4ikcjmqat@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 6 Jul 2017 17:29:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170706144852.fwtuygj4ikcjmqat@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <ce7a039a-2697-f16e-b0b3-f6ae41391682@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 06/07/2017 16:48, Peter Zijlstra wrote:
> On Thu, Jul 06, 2017 at 03:46:59PM +0200, Laurent Dufour wrote:
>> On 05/07/2017 20:50, Peter Zijlstra wrote:
>>> On Fri, Jun 16, 2017 at 07:52:33PM +0200, Laurent Dufour wrote:
>>>> @@ -2294,8 +2295,19 @@ static bool pte_map_lock(struct vm_fault *vmf)
>>>>  	if (vma_has_changed(vmf->vma, vmf->sequence))
>>>>  		goto out;
>>>>  
>>>> -	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
>>>> -				  vmf->address, &ptl);
> 
>>>> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>>>> +	pte = pte_offset_map(vmf->pmd, vmf->address);
>>>> +	if (unlikely(!spin_trylock(ptl))) {
>>>> +		pte_unmap(pte);
>>>> +		goto out;
>>>> +	}
>>>> +
>>>>  	if (vma_has_changed(vmf->vma, vmf->sequence)) {
>>>>  		pte_unmap_unlock(pte, ptl);
>>>>  		goto out;
>>>
>>> Right, so if you look at my earlier patches you'll see I did something
>>> quite disgusting here.
>>>
>>> Not sure that wants repeating, but I cannot remember why I thought this
>>> deadlock didn't exist anymore.
>>
>> Regarding the deadlock I did face it on my Power victim node, so I guess it
>> is still there, and the stack traces are quiet explicit.
>> Am I missing something here ?
> 
> No, you are right in that the deadlock is quite real. What I cannot
> remember is what made me think to remove the really 'wonderful' code I
> had to deal with it.
> 
> That said, you might want to look at how often you terminate the
> speculation because of your trylock failing. If that shows up at all we
> might need to do something about it.

Based on the benchmarks I run, it doesn't fail so much often, but I was
thinking about adding some counters here. The system is accounting for
major page faults and minor ones, respectively current->maj_flt and
current->min_flt. I was wondering if an additional type like async_flt will
be welcome or if there is another smarter way to get that metric.

Feel free to advise.

Thanks
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
