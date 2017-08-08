Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7BC6B037C
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 06:05:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j83so28328775pfe.10
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 03:05:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s18si604773pgd.4.2017.08.08.03.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 03:05:56 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78A3mFQ020174
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 06:05:55 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c785pj3ux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:05:55 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 20:05:52 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v78A5g6K33292340
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 20:05:50 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v78A5HaR002188
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 20:05:17 +1000
Subject: Re: [RFC v5 01/11] mm: Dont assume page-table invariance during
 faults
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <1499411222.23251.5.camel@gmail.com>
 <d719a861-d712-1876-b46c-7f9c1360196c@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 15:34:41 +0530
MIME-Version: 1.0
In-Reply-To: <d719a861-d712-1876-b46c-7f9c1360196c@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <eeecf913-8921-97bb-be63-edd72baa979b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 07/10/2017 11:18 PM, Laurent Dufour wrote:
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

Can we move the detection of swap in of the same struct page back into
the page table bit earlier, ideally where pte_unmap_same() present to
speed up detection for the bail out case ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
