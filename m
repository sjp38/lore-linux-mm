Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF3B66B02A5
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 20:08:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h15-v6so245743qkj.17
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 17:08:19 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id x10-v6si5384298qkx.258.2018.07.02.17.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 17:08:18 -0700 (PDT)
Date: Tue, 3 Jul 2018 00:08:18 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_*
 fields
In-Reply-To: <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
Message-ID: <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com> <20180702005654.20369-6-jhubbard@nvidia.com> <20180702095331.n5zfz35d3invl5al@quack2.suse.cz> <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Mon, 2 Jul 2018, John Hubbard wrote:

> >
> > These two are just wrong. You cannot make any page reference for
> > PageDmaPinned() account against a pin count. First, it is just conceptually
> > wrong as these references need not be long term pins, second, you can
> > easily race like:
> >
> > Pinner				Random process
> > 				get_page(page)
> > pin_page_for_dma()
> > 				put_page(page)
> > 				 -> oops, page gets unpinned too early
> >
>
> I'll drop this approach, without mentioning any of the locking that is hiding in
> there, since that was probably breaking other rules anyway. :) Thanks for your
> patience in reviewing this.

Mayb the following would work:

If you establish a reference to a page then increase the page count. If
the reference is a dma pin action also then increase the pinned count.

That way you know how many of the references to the page are dma
pins and you can correctly manage the state of the page if the dma pins go
away.
