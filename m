Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D13476B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 16:04:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u21-v6so7554989pfn.0
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 13:04:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h72-v6sor3908063pfa.36.2018.06.17.13.04.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Jun 2018 13:04:34 -0700 (PDT)
Date: Sun, 17 Jun 2018 14:04:32 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180617200432.krw36wrcwidb25cj@ziepe.ca>
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>

On Sun, Jun 17, 2018 at 12:53:04PM -0700, Dan Williams wrote:
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 6db729dc4c50..37576f0a4645 100644
> > +++ b/mm/rmap.c
> > @@ -1360,6 +1360,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >                                 flags & TTU_SPLIT_FREEZE, page);
> >         }
> >
> > +       if (PageDmaPinned(page))
> > +               return false;
> >         /*
> >          * We have to assume the worse case ie pmd for invalidation. Note that
> >          * the page can not be free in this function as call of try_to_unmap()
> 
> We have a similiar problem with DAX and the conclusion we came to is
> that it is not acceptable for userspace to arbitrarily block kernel
> actions. The conclusion there was: 'wait' if the DMA is transient, and
> 'revoke' if the DMA is long lived, or otherwise 'block' long-lived DMA
> if a revocation mechanism is not available.

This might be the right answer for certain things, but it shouldn't be
the immediate reaction to everthing. There are many user APIs that
block kernel actions and hold kernel resources.

IMHO, there should be an identifiable objection, eg is blocking going
to create a DOS, dead-lock, insecurity, etc?

Jason
