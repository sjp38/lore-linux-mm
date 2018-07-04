Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC6686B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 06:43:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a4-v6so2873880pls.16
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 03:43:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22-v6si3133626plp.489.2018.07.04.03.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 03:43:21 -0700 (PDT)
Date: Wed, 4 Jul 2018 12:43:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
Message-ID: <20180704104318.f5pnqtnn3unkwauw@quack2.suse.cz>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-6-jhubbard@nvidia.com>
 <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
 <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
 <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
 <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com>
 <01000164611dacae-5ac25e48-b845-43ef-9992-fc1047d8e0a0-000000@email.amazonses.com>
 <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c71556f-1d71-873a-6f74-121865568bf7@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Tue 03-07-18 10:36:05, John Hubbard wrote:
> On 07/03/2018 10:08 AM, Christopher Lameter wrote:
> > On Mon, 2 Jul 2018, John Hubbard wrote:
> > 
> >>> If you establish a reference to a page then increase the page count. If
> >>> the reference is a dma pin action also then increase the pinned count.
> >>>
> >>> That way you know how many of the references to the page are dma
> >>> pins and you can correctly manage the state of the page if the dma pins go
> >>> away.
> >>>
> >>
> >> I think this sounds like what this patch already does, right? See:
> >> __put_page_for_pinned_dma(), __get_page_for_pinned_dma(), and
> >> pin_page_for_dma(). The locking seems correct to me, but I suspect it's
> >> too heavyweight for such a hot path. But without adding a new put_user_page()
> >> call, that was the best I could come up with.
> > 
> > When I saw the patch it looked like you were avoiding to increment the
> > page->count field.
> 
> Looking at it again, this patch is definitely susceptible to Jan's "page gets
> dma-unpinnned too soon" problem.  That leaves a window in which the original
> problem can occur.
> 
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

Well, I think the misconception is that "pinned" is a fundamental property
of a page. It is not. "pinned" is a property of a page reference (i.e., a
kind of reference that can be used for DMA access) and page gets into
"pinned" state if it has any reference of "pinned" type. And when you
realize this, it is obvious that you just have to have a special api for
getting and dropping references of this "pinned" type. For getting we
already have get_user_pages(), for putting we have to create the api...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
