Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1A986B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 10:17:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 99-v6so9854462qkr.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 07:17:20 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id h57-v6si77631qtf.71.2018.07.05.07.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Jul 2018 07:17:19 -0700 (PDT)
Date: Thu, 5 Jul 2018 14:17:19 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_*
 fields
In-Reply-To: <20180704104318.f5pnqtnn3unkwauw@quack2.suse.cz>
Message-ID: <010001646acdf1d8-0460be04-cc74-4a2d-be89-a337461bd485-000000@email.amazonses.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com> <20180702005654.20369-6-jhubbard@nvidia.com> <20180702095331.n5zfz35d3invl5al@quack2.suse.cz> <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com> <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
 <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com> <01000164611dacae-5ac25e48-b845-43ef-9992-fc1047d8e0a0-000000@email.amazonses.com> <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com> <20180704104318.f5pnqtnn3unkwauw@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Wed, 4 Jul 2018, Jan Kara wrote:

> > So this seems unsolvable without having the caller specify that it knows the
> > page type, and that it is therefore safe to decrement page->dma_pinned_count.
> > I was hoping I'd found a way, but clearly I haven't. :)
>
> Well, I think the misconception is that "pinned" is a fundamental property
> of a page. It is not. "pinned" is a property of a page reference (i.e., a
> kind of reference that can be used for DMA access) and page gets into
> "pinned" state if it has any reference of "pinned" type. And when you
> realize this, it is obvious that you just have to have a special api for
> getting and dropping references of this "pinned" type. For getting we
> already have get_user_pages(), for putting we have to create the api...

Maybe we can do something by creating a special "pinned" bit in the pte?
If it is a RDMA reference then set that pinned bit there.

Thus any of the references could cause a pin. Since the page struct does
not contain that information we therefore have to scan through the ptes to
figure out if a page is pinned?

If so then we would not need a special function for dropping the
reference.

References to a page can also be created from devices mmu. Maybe we could
at some point start to manage them in a similar way to the page tables of
the processor? The mmu notifiers are a bit awkward if we need closer mm
integration.
