Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52E576B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:04:43 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id p41-v6so10728774oth.5
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:04:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j35-v6sor5885974oth.283.2018.06.18.13.04.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 13:04:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180618193158.GE6805@ziepe.ca>
References: <20180617012510.20139-3-jhubbard@nvidia.com> <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca> <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com> <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com> <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com> <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <20180618193158.GE6805@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 13:04:36 -0700
Message-ID: <CAPcyv4jbwtOqG_473SeK12LKghMo6mCDWRuTxqYVP6R-sLhpoA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon, Jun 18, 2018 at 12:31 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Mon, Jun 18, 2018 at 12:21:46PM -0700, Dan Williams wrote:
>> On Mon, Jun 18, 2018 at 11:14 AM, John Hubbard <jhubbard@nvidia.com> wrote:
>> > On 06/18/2018 10:56 AM, Dan Williams wrote:
>> >> On Mon, Jun 18, 2018 at 10:50 AM, John Hubbard <jhubbard@nvidia.com> wrote:
>> >>> On 06/18/2018 01:12 AM, Christoph Hellwig wrote:
>> >>>> On Sun, Jun 17, 2018 at 01:28:18PM -0700, John Hubbard wrote:
>> >>>>> Yes. However, my thinking was: get_user_pages() can become a way to indicate that
>> >>>>> these pages are going to be treated specially. In particular, the caller
>> >>>>> does not really want or need to support certain file operations, while the
>> >>>>> page is flagged this way.
>> >>>>>
>> >>>>> If necessary, we could add a new API call.
>> >>>>
>> >>>> That API call is called get_user_pages_longterm.
>> >>>
>> >>> OK...I had the impression that this was just semi-temporary API for dax, but
>> >>> given that it's an exported symbol, I guess it really is here to stay.
>> >>
>> >> The plan is to go back and provide api changes that bypass
>> >> get_user_page_longterm() for RDMA. However, for VFIO and others, it's
>> >> not clear what we could do. In the VFIO case the guest would need to
>> >> be prepared handle the revocation.
>> >
>> > OK, let's see if I understand that plan correctly:
>> >
>> > 1. Change RDMA users (this could be done entirely in the various device drivers'
>> > code, unless I'm overlooking something) to use mmu notifiers, and to do their
>> > DMA to/from non-pinned pages.
>>
>> The problem with this approach is surprising the RDMA drivers with
>> notifications of teardowns. It's the RDMA userspace applications that
>> need the notification, and it likely needs to be explicit opt-in, at
>> least for the non-ODP drivers.
>
> Well, more than that, we have no real plan on how to accomplish this,
> or any idea if it can even really work.. Most userspace give up
> control of the memory lifetime to the remote side of the connection
> and have no way to recover it other than a full teardown.
>
> Given that John is trying to fix a kernel oops, I don't think we
> should tie progress on it to the RDMA notification idea.
>
> .. and given that John is trying to fix a kernel oops, maybe the
> weird/bad/ugly behavior of ftruncte is a better bug to have than for
> unprivileged users to be able to oops the kernel???

Trading one bug for another is not a fix. We did not fix the
DAX-dma-vs-trruncate bug by breaking truncate() guarantees.
