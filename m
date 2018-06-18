Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBA7A6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:56:58 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id l11-v6so10533963oth.1
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:56:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g23-v6sor6730071ote.284.2018.06.18.10.56.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 10:56:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
References: <20180617012510.20139-1-jhubbard@nvidia.com> <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca> <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com> <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 10:56:57 -0700
Message-ID: <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon, Jun 18, 2018 at 10:50 AM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 06/18/2018 01:12 AM, Christoph Hellwig wrote:
>> On Sun, Jun 17, 2018 at 01:28:18PM -0700, John Hubbard wrote:
>>> Yes. However, my thinking was: get_user_pages() can become a way to indicate that
>>> these pages are going to be treated specially. In particular, the caller
>>> does not really want or need to support certain file operations, while the
>>> page is flagged this way.
>>>
>>> If necessary, we could add a new API call.
>>
>> That API call is called get_user_pages_longterm.
>
> OK...I had the impression that this was just semi-temporary API for dax, but
> given that it's an exported symbol, I guess it really is here to stay.

The plan is to go back and provide api changes that bypass
get_user_page_longterm() for RDMA. However, for VFIO and others, it's
not clear what we could do. In the VFIO case the guest would need to
be prepared handle the revocation.
