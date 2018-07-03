Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD4296B026C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:08:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 99-v6so2958218qkr.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:08:13 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id n33-v6si1467232qvg.190.2018.07.03.10.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 10:08:12 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:08:12 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_*
 fields
In-Reply-To: <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com>
Message-ID: <01000164611dacae-5ac25e48-b845-43ef-9992-fc1047d8e0a0-000000@email.amazonses.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com> <20180702005654.20369-6-jhubbard@nvidia.com> <20180702095331.n5zfz35d3invl5al@quack2.suse.cz> <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com> <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
 <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Mon, 2 Jul 2018, John Hubbard wrote:

> > If you establish a reference to a page then increase the page count. If
> > the reference is a dma pin action also then increase the pinned count.
> >
> > That way you know how many of the references to the page are dma
> > pins and you can correctly manage the state of the page if the dma pins go
> > away.
> >
>
> I think this sounds like what this patch already does, right? See:
> __put_page_for_pinned_dma(), __get_page_for_pinned_dma(), and
> pin_page_for_dma(). The locking seems correct to me, but I suspect it's
> too heavyweight for such a hot path. But without adding a new put_user_page()
> call, that was the best I could come up with.

When I saw the patch it looked like you were avoiding to increment the
page->count field.

> What I'm hearing now from Jan and Michal is that the desired end result is
> a separate API call, put_user_pages(), so that we can explicitly manage
> these pinned pages.

Certainly a good approach.
