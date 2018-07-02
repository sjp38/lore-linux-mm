Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 902A46B0279
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:44:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d14-v6so19925377qtn.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:44:49 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v144-v6si3971975qka.94.2018.07.02.13.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:44:48 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-6-jhubbard@nvidia.com>
 <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <bb798475-ebf3-7b02-409f-8c4347fa6674@nvidia.com>
Date: Mon, 2 Jul 2018 13:43:46 -0700
MIME-Version: 1.0
In-Reply-To: <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/02/2018 02:53 AM, Jan Kara wrote:
> On Sun 01-07-18 17:56:53, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
> ...
> 
>> @@ -904,12 +907,24 @@ static inline void get_page(struct page *page)
>>  	 */
>>  	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
>>  	page_ref_inc(page);
>> +
>> +	if (unlikely(PageDmaPinned(page)))
>> +		__get_page_for_pinned_dma(page);
>>  }
>>  
>>  static inline void put_page(struct page *page)
>>  {
>>  	page = compound_head(page);
>>  
>> +	/* Because the page->dma_pinned_* fields are unioned with
>> +	 * page->lru, there is no way to do classical refcount-style
>> +	 * decrement-and-test-for-zero. Instead, PageDmaPinned(page) must
>> +	 * be checked, in order to safely check if we are allowed to decrement
>> +	 * page->dma_pinned_count at all.
>> +	 */
>> +	if (unlikely(PageDmaPinned(page)))
>> +		__put_page_for_pinned_dma(page);
>> +
> 
> These two are just wrong. You cannot make any page reference for
> PageDmaPinned() account against a pin count. First, it is just conceptually
> wrong as these references need not be long term pins, second, you can
> easily race like:
> 
> Pinner				Random process
> 				get_page(page)
> pin_page_for_dma()
> 				put_page(page)
> 				 -> oops, page gets unpinned too early
> 

I'll drop this approach, without mentioning any of the locking that is hiding in
there, since that was probably breaking other rules anyway. :) Thanks for your
patience in reviewing this.

> So you really have to create counterpart to get_user_pages() - like
> put_user_page() or whatever... It is inconvenient to have to modify all GUP
> users but I don't see a way around that. 

OK, there will be a long-ish pause, while I go visit all the gup sites. I count about
88 callers, which is not nearly as crazy as my first casual grep showed, but still
quite a chunk, since I have to track down where each one does its put_page call(s).

It's definitely worth the effort, though. These pins just plain need some special
handling in order to get everything correct.


thanks,
-- 
John Hubbard
NVIDIA
