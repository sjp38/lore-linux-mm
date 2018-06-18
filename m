Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0956B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 14:15:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l10-v6so14659927qth.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 11:15:04 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 31-v6si4297500qkr.350.2018.06.18.11.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 11:15:03 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
Date: Mon, 18 Jun 2018 11:14:40 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On 06/18/2018 10:56 AM, Dan Williams wrote:
> On Mon, Jun 18, 2018 at 10:50 AM, John Hubbard <jhubbard@nvidia.com> wrote:
>> On 06/18/2018 01:12 AM, Christoph Hellwig wrote:
>>> On Sun, Jun 17, 2018 at 01:28:18PM -0700, John Hubbard wrote:
>>>> Yes. However, my thinking was: get_user_pages() can become a way to indicate that
>>>> these pages are going to be treated specially. In particular, the caller
>>>> does not really want or need to support certain file operations, while the
>>>> page is flagged this way.
>>>>
>>>> If necessary, we could add a new API call.
>>>
>>> That API call is called get_user_pages_longterm.
>>
>> OK...I had the impression that this was just semi-temporary API for dax, but
>> given that it's an exported symbol, I guess it really is here to stay.
> 
> The plan is to go back and provide api changes that bypass
> get_user_page_longterm() for RDMA. However, for VFIO and others, it's
> not clear what we could do. In the VFIO case the guest would need to
> be prepared handle the revocation.
 
OK, let's see if I understand that plan correctly:

1. Change RDMA users (this could be done entirely in the various device drivers'
code, unless I'm overlooking something) to use mmu notifiers, and to do their
DMA to/from non-pinned pages.

2. Return early from get_user_pages_longterm, if the memory is...marked for
RDMA? (How? Same sort of page flag that I'm floating here, or something else?)
That would avoid the problem with pinned pages getting their buffer heads
removed--by disallowing the pinning. Makes sense.

Also, is there anything I can help with here, so that things can happen sooner? 
