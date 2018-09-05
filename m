Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54DB26B75B8
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 19:51:26 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id w196-v6so9565825itb.4
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 16:51:26 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l134-v6si2389665ita.10.2018.09.05.16.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 16:51:25 -0700 (PDT)
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
 <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
 <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
 <20180905230737.GA14977@bombadil.infradead.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c03c8851-ce18-56c6-3f37-47f585d70b19@oracle.com>
Date: Wed, 5 Sep 2018 16:51:00 -0700
MIME-Version: 1.0
In-Reply-To: <20180905230737.GA14977@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/05/2018 04:07 PM, Matthew Wilcox wrote:
> On Wed, Sep 05, 2018 at 03:00:08PM -0700, Andrew Morton wrote:
>> On Wed, 5 Sep 2018 14:35:11 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>>>>                                            so perhaps we could put some
>>>> stopgap workaround into that site and add a runtime warning into the
>>>> put_page() code somewhere to detect puttage of huge pages from hardirq
>>>> and softirq contexts.
>>>
>>> I think we would add the warning/etc at free_huge_page.  The issue would
>>> only apply to hugetlb pages, not THP.
>>>
>>> But, the more I think about it the more I think Aneesh's patch to do
>>> spin_lock/unlock_irqsave is the right way to go.  Currently, we only
>>> know of one place where a put_page of hugetlb pages is done from softirq
>>> context.  So, we could take the spin_lock/unlock_bh as Matthew suggested.
>>> When the powerpc iommu code was added, I doubt this was taken into account.
>>> I would be afraid of someone adding put_page from hardirq context.
>>
>> Me too.  If we're going to do this, surely we should make hugepages
>> behave in the same fashion as PAGE_SIZE pages.
> 
> But these aren't vanilla hugepages, they're specifically hugetlbfs pages.
> I don't believe there's any problem with calling put_page() on a normally
> allocated huge page or THP.

Right
The powerpc iommu code (at least) treated hugetlbfs pages as any other page
(huge, THP or base) and called put_page from softirq context.

It seems there are at least two ways to address this:
1) Prohibit this behavior for hugetlbfs pages
2) Try to make hugetlbfs pages behave like other pages WRT put_page

Aneesh's patch went further than allowing put_page of hugetlbfs pages
from softirq context.  It allowed them from hardirq context as well:
admittedly at a cost of disabling irqs.

This issue has probably existed since the addition of powerpc iommu code.
IMO, we should make hugetlbfs pages behave more like other pages in this
case.

BTW, free_huge_page called by put_page for hugetlbfs pages may also take
a subpool specific lock via spin_lock().  See hugepage_subpool_put_pages.
So, this would also need to take irq context into account.
-- 
Mike Kravetz
