Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF4F96B000E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:48:14 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f132-v6so2947803qkb.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:48:14 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id e7-v6si1599240qkf.217.2018.07.03.10.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 10:48:13 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:48:13 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_*
 fields
In-Reply-To: <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com>
Message-ID: <0100016461425062-724aa9d3-d7c1-4fa2-a87b-dc59cc5f7800-000000@email.amazonses.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com> <20180702005654.20369-6-jhubbard@nvidia.com> <20180702095331.n5zfz35d3invl5al@quack2.suse.cz> <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com> <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
 <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com> <01000164611dacae-5ac25e48-b845-43ef-9992-fc1047d8e0a0-000000@email.amazonses.com> <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Tue, 3 Jul 2018, John Hubbard wrote:

> The page->_refcount field is used normally, in addition to the dma_pinned_count.
> But the problem is that, unless the caller knows what kind of page it is,
> the page->dma_pinned_count cannot be looked at, because it is unioned with
> page->lru.prev.  page->dma_pinned_flags, at least starting at bit 1, are
> safe to look at due to pointer alignment, but now you cannot atomically
> count...
>
> So this seems unsolvable without having the caller specify that it knows the
> page type, and that it is therefore safe to decrement page->dma_pinned_count.
> I was hoping I'd found a way, but clearly I haven't. :)

Try to find some way to indicate that the page is pinned by using some of
the existing page flags? There is already an MLOCK flag. Maybe some
creativity with that can lead to something (but then the MLOCKed pages are
on the unevictable LRU....). cgroups used to have something called struct
page_ext. Oh its there in linux/mm/page_ext.c.
