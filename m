Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67D1744084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:48:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v26so120263455pfa.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:48:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i1si8343483pfa.122.2017.07.10.10.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 10:48:51 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6AHmiNa097814
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:48:50 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bmb55r1m8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:48:50 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 18:48:48 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [RFC v5 01/11] mm: Dont assume page-table invariance during
 faults
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <1499411222.23251.5.camel@gmail.com>
Date: Mon, 10 Jul 2017 19:48:43 +0200
MIME-Version: 1.0
In-Reply-To: <1499411222.23251.5.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d719a861-d712-1876-b46c-7f9c1360196c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 07/07/2017 09:07, Balbir Singh wrote:
> On Fri, 2017-06-16 at 19:52 +0200, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> One of the side effects of speculating on faults (without holding
>> mmap_sem) is that we can race with free_pgtables() and therefore we
>> cannot assume the page-tables will stick around.
>>
>> Remove the relyance on the pte pointer.
>              ^^ reliance
> 
> Looking at the changelog and the code the impact is not clear.
> It looks like after this patch we always assume the pte is not
> the same. What is the impact of this patch?

Hi Balbir,

In most of the case pte_unmap_same() was returning 1, which meaning that
do_swap_page() should do its processing.

So in most of the case there will be no impact.

Now regarding the case where pte_unmap_safe() was returning 0, and thus
do_swap_page return 0 too, this happens when the page has already been
swapped back. This may happen before do_swap_page() get called or while in
the call to do_swap_page(). In that later case, the check done when
swapin_readahead() returns will detect that case.

The worst case would be that a page fault is occuring on 2 threads at the
same time on the same swapped out page. In that case one thread will take
much time looping in __read_swap_cache_async(). But in the regular page
fault path, this is even worse since the thread would wait for semaphore to
be released before starting anything.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
