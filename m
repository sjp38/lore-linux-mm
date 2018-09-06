Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B27096B787E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:19:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z56-v6so3563851edz.10
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:19:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 41-v6si1798356edr.186.2018.09.06.04.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:19:05 -0700 (PDT)
Date: Thu, 6 Sep 2018 13:19:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Message-ID: <20180906111904.GB26069@dhcp22.suse.cz>
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
 <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
 <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
 <20180905230737.GA14977@bombadil.infradead.org>
 <c03c8851-ce18-56c6-3f37-47f585d70b19@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c03c8851-ce18-56c6-3f37-47f585d70b19@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 16:51:00, Mike Kravetz wrote:
> On 09/05/2018 04:07 PM, Matthew Wilcox wrote:
> > On Wed, Sep 05, 2018 at 03:00:08PM -0700, Andrew Morton wrote:
> >> On Wed, 5 Sep 2018 14:35:11 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> >>
> >>>>                                            so perhaps we could put some
> >>>> stopgap workaround into that site and add a runtime warning into the
> >>>> put_page() code somewhere to detect puttage of huge pages from hardirq
> >>>> and softirq contexts.
> >>>
> >>> I think we would add the warning/etc at free_huge_page.  The issue would
> >>> only apply to hugetlb pages, not THP.
> >>>
> >>> But, the more I think about it the more I think Aneesh's patch to do
> >>> spin_lock/unlock_irqsave is the right way to go.  Currently, we only
> >>> know of one place where a put_page of hugetlb pages is done from softirq
> >>> context.  So, we could take the spin_lock/unlock_bh as Matthew suggested.
> >>> When the powerpc iommu code was added, I doubt this was taken into account.
> >>> I would be afraid of someone adding put_page from hardirq context.
> >>
> >> Me too.  If we're going to do this, surely we should make hugepages
> >> behave in the same fashion as PAGE_SIZE pages.
> > 
> > But these aren't vanilla hugepages, they're specifically hugetlbfs pages.
> > I don't believe there's any problem with calling put_page() on a normally
> > allocated huge page or THP.
> 
> Right
> The powerpc iommu code (at least) treated hugetlbfs pages as any other page
> (huge, THP or base) and called put_page from softirq context.
> 
> It seems there are at least two ways to address this:
> 1) Prohibit this behavior for hugetlbfs pages
> 2) Try to make hugetlbfs pages behave like other pages WRT put_page

Hugetlb pages have always been special and that has caused us more
headache than necessary. So if there is a user calling put_page from the
soft IRQ context (which is a news to me) then we can expect somebody
will do that from the hard IRQ context sooner or later. So rather than
make hugetlb a special snow flake again I vote for 2) and make it
consistent with other pages.
-- 
Michal Hocko
SUSE Labs
