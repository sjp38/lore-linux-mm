Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1E8C6B02DB
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 09:49:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d30-v6so1980968edd.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 06:49:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12-v6si1461314edp.183.2018.07.09.06.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 06:49:44 -0700 (PDT)
Date: Mon, 9 Jul 2018 15:49:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
Message-ID: <20180709134937.fqk77w2jjw62lw6m@quack2.suse.cz>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-6-jhubbard@nvidia.com>
 <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
 <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
 <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
 <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com>
 <01000164611dacae-5ac25e48-b845-43ef-9992-fc1047d8e0a0-000000@email.amazonses.com>
 <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com>
 <20180704104318.f5pnqtnn3unkwauw@quack2.suse.cz>
 <010001646acdf1d8-0460be04-cc74-4a2d-be89-a337461bd485-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001646acdf1d8-0460be04-cc74-4a2d-be89-a337461bd485-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Thu 05-07-18 14:17:19, Christopher Lameter wrote:
> On Wed, 4 Jul 2018, Jan Kara wrote:
> 
> > > So this seems unsolvable without having the caller specify that it knows the
> > > page type, and that it is therefore safe to decrement page->dma_pinned_count.
> > > I was hoping I'd found a way, but clearly I haven't. :)
> >
> > Well, I think the misconception is that "pinned" is a fundamental property
> > of a page. It is not. "pinned" is a property of a page reference (i.e., a
> > kind of reference that can be used for DMA access) and page gets into
> > "pinned" state if it has any reference of "pinned" type. And when you
> > realize this, it is obvious that you just have to have a special api for
> > getting and dropping references of this "pinned" type. For getting we
> > already have get_user_pages(), for putting we have to create the api...
> 
> Maybe we can do something by creating a special "pinned" bit in the pte?
> If it is a RDMA reference then set that pinned bit there.
> 
> Thus any of the references could cause a pin. Since the page struct does
> not contain that information we therefore have to scan through the ptes to
> figure out if a page is pinned?
> 
> If so then we would not need a special function for dropping the
> reference.

I don't really see how a PTE bit would help in getting rid of the special
function for dropping "pinned" reference. You still need to distinguish
preexisting page references (and corresponding page ref drops which must
not unpin the page) from the references acquired after transitioning PTE to
the pinned state...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
