Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7006B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 16:10:06 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id y18-v6so9112691otg.14
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 13:10:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j47-v6sor5219017ota.146.2018.06.17.13.10.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Jun 2018 13:10:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180617200432.krw36wrcwidb25cj@ziepe.ca>
References: <20180617012510.20139-1-jhubbard@nvidia.com> <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com> <20180617200432.krw36wrcwidb25cj@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Jun 2018 13:10:04 -0700
Message-ID: <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>

On Sun, Jun 17, 2018 at 1:04 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Sun, Jun 17, 2018 at 12:53:04PM -0700, Dan Williams wrote:
>> > diff --git a/mm/rmap.c b/mm/rmap.c
>> > index 6db729dc4c50..37576f0a4645 100644
>> > +++ b/mm/rmap.c
>> > @@ -1360,6 +1360,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>> >                                 flags & TTU_SPLIT_FREEZE, page);
>> >         }
>> >
>> > +       if (PageDmaPinned(page))
>> > +               return false;
>> >         /*
>> >          * We have to assume the worse case ie pmd for invalidation. Note that
>> >          * the page can not be free in this function as call of try_to_unmap()
>>
>> We have a similiar problem with DAX and the conclusion we came to is
>> that it is not acceptable for userspace to arbitrarily block kernel
>> actions. The conclusion there was: 'wait' if the DMA is transient, and
>> 'revoke' if the DMA is long lived, or otherwise 'block' long-lived DMA
>> if a revocation mechanism is not available.
>
> This might be the right answer for certain things, but it shouldn't be
> the immediate reaction to everthing. There are many user APIs that
> block kernel actions and hold kernel resources.
>
> IMHO, there should be an identifiable objection, eg is blocking going
> to create a DOS, dead-lock, insecurity, etc?

I believe kernel behavior regression is a primary concern as now
fallocate() and truncate() can randomly fail where they didn't before.
