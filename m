Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4B516B7563
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 18:00:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id h4-v6so4391022pls.17
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 15:00:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cc7-v6si3481276plb.97.2018.09.05.15.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 15:00:10 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:00:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Message-Id: <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
In-Reply-To: <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
	<20180905130440.GA3729@bombadil.infradead.org>
	<d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
	<20180905134848.GB3729@bombadil.infradead.org>
	<20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
	<78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 5 Sep 2018 14:35:11 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> >                                            so perhaps we could put some
> > stopgap workaround into that site and add a runtime warning into the
> > put_page() code somewhere to detect puttage of huge pages from hardirq
> > and softirq contexts.
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

Me too.  If we're going to do this, surely we should make hugepages
behave in the same fashion as PAGE_SIZE pages.
