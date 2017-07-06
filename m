Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4563C6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 09:47:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so613249wrz.10
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 06:47:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j1si35035wrb.194.2017.07.06.06.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 06:47:08 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v66DhlSf023088
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 09:47:06 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bhk12skn3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:47:06 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 6 Jul 2017 14:47:04 +0100
Subject: Re: [RFC v5 09/11] mm: Try spin lock in speculative path
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 6 Jul 2017 15:46:59 +0200
MIME-Version: 1.0
In-Reply-To: <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <3af22f3b-03ab-1d37-b2b1-b616adde7eb6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 05/07/2017 20:50, Peter Zijlstra wrote:
> On Fri, Jun 16, 2017 at 07:52:33PM +0200, Laurent Dufour wrote:
>> @@ -2294,8 +2295,19 @@ static bool pte_map_lock(struct vm_fault *vmf)
>>  	if (vma_has_changed(vmf->vma, vmf->sequence))
>>  		goto out;
>>  
>> -	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
>> -				  vmf->address, &ptl);
>> +	/* Same as pte_offset_map_lock() except that we call
> 
> comment style..

Hi Peter and thanks for your work and review.

I'll fix this comment style.

> 
>> +	 * spin_trylock() in place of spin_lock() to avoid race with
>> +	 * unmap path which may have the lock and wait for this CPU
>> +	 * to invalidate TLB but this CPU has irq disabled.
>> +	 * Since we are in a speculative patch, accept it could fail
>> +	 */
>> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	pte = pte_offset_map(vmf->pmd, vmf->address);
>> +	if (unlikely(!spin_trylock(ptl))) {
>> +		pte_unmap(pte);
>> +		goto out;
>> +	}
>> +
>>  	if (vma_has_changed(vmf->vma, vmf->sequence)) {
>>  		pte_unmap_unlock(pte, ptl);
>>  		goto out;
> 
> Right, so if you look at my earlier patches you'll see I did something
> quite disgusting here.
> 
> Not sure that wants repeating, but I cannot remember why I thought this
> deadlock didn't exist anymore.

Regarding the deadlock I did face it on my Power victim node, so I guess it
is still there, and the stack traces are quiet explicit.
Am I missing something here ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
