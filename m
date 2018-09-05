Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFD886B758C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 19:07:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c8-v6so4753088pfn.2
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 16:07:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j185-v6si3264577pgc.419.2018.09.05.16.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 16:07:40 -0700 (PDT)
Date: Wed, 5 Sep 2018 16:07:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Message-ID: <20180905230737.GA14977@bombadil.infradead.org>
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
 <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
 <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 05, 2018 at 03:00:08PM -0700, Andrew Morton wrote:
> On Wed, 5 Sep 2018 14:35:11 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
> > >                                            so perhaps we could put some
> > > stopgap workaround into that site and add a runtime warning into the
> > > put_page() code somewhere to detect puttage of huge pages from hardirq
> > > and softirq contexts.
> > 
> > I think we would add the warning/etc at free_huge_page.  The issue would
> > only apply to hugetlb pages, not THP.
> > 
> > But, the more I think about it the more I think Aneesh's patch to do
> > spin_lock/unlock_irqsave is the right way to go.  Currently, we only
> > know of one place where a put_page of hugetlb pages is done from softirq
> > context.  So, we could take the spin_lock/unlock_bh as Matthew suggested.
> > When the powerpc iommu code was added, I doubt this was taken into account.
> > I would be afraid of someone adding put_page from hardirq context.
> 
> Me too.  If we're going to do this, surely we should make hugepages
> behave in the same fashion as PAGE_SIZE pages.

But these aren't vanilla hugepages, they're specifically hugetlbfs pages.
I don't believe there's any problem with calling put_page() on a normally
allocated huge page or THP.
