Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7B0C6B754F
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:35:42 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 1-v6so3141447ybe.18
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:35:42 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u17-v6si796068ybp.122.2018.09.05.14.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 14:35:41 -0700 (PDT)
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
Date: Wed, 5 Sep 2018 14:35:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/05/2018 12:58 PM, Andrew Morton wrote:
> On Wed, 5 Sep 2018 06:48:48 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
>>> I didn't. The reason I looked at current patch is to enable the usage of
>>> put_page() from irq context. We do allow that for non hugetlb pages. So was
>>> not sure adding that additional restriction for hugetlb
>>> is really needed. Further the conversion to irqsave/irqrestore was
>>> straightforward.
>>
>> straightforward, sure.  but is it the right thing to do?  do we want to
>> be able to put_page() a hugetlb page from hardirq context?
> 
> Calling put_page() against a huge page from hardirq seems like the
> right thing to do - even if it's rare now, it will presumably become
> more common as the hugepage virus spreads further across the kernel. 
> And the present asymmetry is quite a wart.
> 
> That being said, arch/powerpc/mm/mmu_context_iommu.c:mm_iommu_free() is
> the only known site which does this (yes?)

IIUC, the powerpc iommu code 'remaps' user allocated hugetlb pages.  It is
these pages that are of issue at put_page time.  I'll admit that code is new
to me and I may not fully understand.  However, if this is accurate then it
makes it really difficult to track down any other similar usage patterns.
I can not find a reference to PageHuge in the powerpc iommu code.

>                                            so perhaps we could put some
> stopgap workaround into that site and add a runtime warning into the
> put_page() code somewhere to detect puttage of huge pages from hardirq
> and softirq contexts.

I think we would add the warning/etc at free_huge_page.  The issue would
only apply to hugetlb pages, not THP.

But, the more I think about it the more I think Aneesh's patch to do
spin_lock/unlock_irqsave is the right way to go.  Currently, we only
know of one place where a put_page of hugetlb pages is done from softirq
context.  So, we could take the spin_lock/unlock_bh as Matthew suggested.
When the powerpc iommu code was added, I doubt this was taken into account.
I would be afraid of someone adding put_page from hardirq context.

-- 
Mike Kravetz

> And attention will need to be paid to -stable backporting.  How long
> has mm_iommu_free() existed, and been doing this?
