Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B72526B0008
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 00:31:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b8-v6so879346qto.13
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 21:31:02 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id s6-v6si191108qvn.166.2018.07.02.21.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 21:31:01 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-6-jhubbard@nvidia.com>
 <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
 <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
 <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f01666d5-8da1-7bea-adfb-c3571a54587a@nvidia.com>
Date: Mon, 2 Jul 2018 21:30:28 -0700
MIME-Version: 1.0
In-Reply-To: <010001645d77ee2c-de7fedbd-f52d-4b74-9388-e6435973792b-000000@email.amazonses.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/02/2018 05:08 PM, Christopher Lameter wrote:
> On Mon, 2 Jul 2018, John Hubbard wrote:
> 
>>>
>>> These two are just wrong. You cannot make any page reference for
>>> PageDmaPinned() account against a pin count. First, it is just conceptually
>>> wrong as these references need not be long term pins, second, you can
>>> easily race like:
>>>
>>> Pinner				Random process
>>> 				get_page(page)
>>> pin_page_for_dma()
>>> 				put_page(page)
>>> 				 -> oops, page gets unpinned too early
>>>
>>
>> I'll drop this approach, without mentioning any of the locking that is hiding in
>> there, since that was probably breaking other rules anyway. :) Thanks for your
>> patience in reviewing this.
> 
> Mayb the following would work:
> 
> If you establish a reference to a page then increase the page count. If
> the reference is a dma pin action also then increase the pinned count.
> 
> That way you know how many of the references to the page are dma
> pins and you can correctly manage the state of the page if the dma pins go
> away.
> 

I think this sounds like what this patch already does, right? See:
__put_page_for_pinned_dma(), __get_page_for_pinned_dma(), and 
pin_page_for_dma(). The locking seems correct to me, but I suspect it's 
too heavyweight for such a hot path. But without adding a new put_user_page()
call, that was the best I could come up with.

What I'm hearing now from Jan and Michal is that the desired end result is
a separate API call, put_user_pages(), so that we can explicitly manage
these pinned pages.

thanks,
-- 
John Hubbard
NVIDIA
