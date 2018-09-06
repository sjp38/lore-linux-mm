Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2249B6B76AF
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 23:58:35 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q130-v6so11195276oic.22
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 20:58:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t62-v6si2283299oig.270.2018.09.05.20.58.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 20:58:33 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w863sPTh084338
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 23:58:33 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mat3sw5sj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 23:58:32 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Sep 2018 21:58:32 -0600
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
 <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 6 Sep 2018 09:28:23 +0530
MIME-Version: 1.0
In-Reply-To: <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <7e8a2960-2bee-9b49-fee0-c3c4e3b61bc2@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Kardashevskiy <aik@ozlabs.ru>

On 09/06/2018 03:05 AM, Mike Kravetz wrote:
> On 09/05/2018 12:58 PM, Andrew Morton wrote:
>> On Wed, 5 Sep 2018 06:48:48 -0700 Matthew Wilcox <willy@infradead.org> wrote:
>>
>>>> I didn't. The reason I looked at current patch is to enable the usage of
>>>> put_page() from irq context. We do allow that for non hugetlb pages. So was
>>>> not sure adding that additional restriction for hugetlb
>>>> is really needed. Further the conversion to irqsave/irqrestore was
>>>> straightforward.
>>>
>>> straightforward, sure.  but is it the right thing to do?  do we want to
>>> be able to put_page() a hugetlb page from hardirq context?
>>
>> Calling put_page() against a huge page from hardirq seems like the
>> right thing to do - even if it's rare now, it will presumably become
>> more common as the hugepage virus spreads further across the kernel.
>> And the present asymmetry is quite a wart.
>>
>> That being said, arch/powerpc/mm/mmu_context_iommu.c:mm_iommu_free() is
>> the only known site which does this (yes?)

I guess so. It is the rcu callback to release the pinned pages.

> 
> IIUC, the powerpc iommu code 'remaps' user allocated hugetlb pages.  It is
> these pages that are of issue at put_page time.  I'll admit that code is new
> to me and I may not fully understand.  However, if this is accurate then it
> makes it really difficult to track down any other similar usage patterns.
> I can not find a reference to PageHuge in the powerpc iommu code.


I don't know enough about vfio to comment about whether it is powerpc 
specific. So the usage is w.r.t pass-through of usb device using vfio. 
We do pin the entire guest ram. This pin is released later using the rcu 
callbacks. We hit the issue when we use hugetlbfs backed guest ram.

> 
>>                                             so perhaps we could put some
>> stopgap workaround into that site and add a runtime warning into the
>> put_page() code somewhere to detect puttage of huge pages from hardirq
>> and softirq contexts.
> 
> I think we would add the warning/etc at free_huge_page.  The issue would
> only apply to hugetlb pages, not THP.
> 
> But, the more I think about it the more I think Aneesh's patch to do
> spin_lock/unlock_irqsave is the right way to go.  Currently, we only
> know of one place where a put_page of hugetlb pages is done from softirq
> context.  So, we could take the spin_lock/unlock_bh as Matthew suggested.
> When the powerpc iommu code was added, I doubt this was taken into account.
> I would be afraid of someone adding put_page from hardirq context.
> 

-aneesh
