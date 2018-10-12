Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B79616B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:31:39 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j144-v6so8239609ywa.5
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:31:39 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id h74-v6si943215ywc.447.2018.10.12.15.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 15:31:38 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm: introduce put_user_page*(), placeholder versions
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-3-jhubbard@nvidia.com> <20181012073521.GJ8537@350D>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <faaac34e-c358-9675-5287-15398bc6828b@nvidia.com>
Date: Fri, 12 Oct 2018 15:31:36 -0700
MIME-Version: 1.0
In-Reply-To: <20181012073521.GJ8537@350D>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On 10/12/18 12:35 AM, Balbir Singh wrote:
> On Thu, Oct 11, 2018 at 11:00:10PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
[...]>> +/*
>> + * put_user_pages_dirty() - for each page in the @pages array, make
>> + * that page (or its head page, if a compound page) dirty, if it was
>> + * previously listed as clean. Then, release the page using
>> + * put_user_page().
>> + *
>> + * Please see the put_user_page() documentation for details.
>> + *
>> + * set_page_dirty(), which does not lock the page, is used here.
>> + * Therefore, it is the caller's responsibility to ensure that this is
>> + * safe. If not, then put_user_pages_dirty_lock() should be called instead.
>> + *
>> + * @pages:  array of pages to be marked dirty and released.
>> + * @npages: number of pages in the @pages array.
>> + *
>> + */
>> +void put_user_pages_dirty(struct page **pages, unsigned long npages)
>> +{
>> +	unsigned long index;
>> +
>> +	for (index = 0; index < npages; index++) {
> Do we need any checks on npages, npages <= (PUD_SHIFT - PAGE_SHIFT)?
> 

Hi Balbir,

Thanks for combing through this series.

I'd go with "probably not", because the only check that can be done is
what you showed above: "did someone crazy pass in more pages than are
possible for this system?". I don't think checking for that helps here,
as that will show up loud and clear, in other ways.

The release_pages() implementation made the same judgment call to not 
check npages, which also influenced me.

A VM_BUG_ON could be added but I'd prefer not to, as it seems to have 
not enough benefit to be worth it.


>> +		struct page *page = compound_head(pages[index]);
>> +
>> +		if (!PageDirty(page))
>> +			set_page_dirty(page);
>> +
>> +		put_user_page(page);
>> +	}
>> +}
>> +EXPORT_SYMBOL(put_user_pages_dirty);
>> +
>> +/*
>> + * put_user_pages_dirty_lock() - for each page in the @pages array, make
>> + * that page (or its head page, if a compound page) dirty, if it was
>> + * previously listed as clean. Then, release the page using
>> + * put_user_page().
>> + *
>> + * Please see the put_user_page() documentation for details.
>> + *
>> + * This is just like put_user_pages_dirty(), except that it invokes
>> + * set_page_dirty_lock(), instead of set_page_dirty().
>> + *
>> + * @pages:  array of pages to be marked dirty and released.
>> + * @npages: number of pages in the @pages array.
>> + *
>> + */
>> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
>> +{
>> +	unsigned long index;
>> +
>> +	for (index = 0; index < npages; index++) {
>> +		struct page *page = compound_head(pages[index]);
>> +
>> +		if (!PageDirty(page))
>> +			set_page_dirty_lock(page);
>> +
>> +		put_user_page(page);
>> +	}
>> +}
>> +EXPORT_SYMBOL(put_user_pages_dirty_lock);
>> +
> 
> This can be collapsed w.r.t put_user_pages_dirty, a function pointer indirection
> for the locked vs unlocked case, not sure how that affects function optimization.
> 

OK, good point. I initially wanted to avoid the overhead of a function 
pointer, but considering that there are lots of other operations 
happening, I think you're right: best to just get rid of the code 
duplication. If later on we find that changing it back actually helps 
any benchmarks, that can always be done.

See below for how I'm planning on fixing it, and it is a nice little 
cleanup, so thanks for pointing that out.

>> +/*
>> + * put_user_pages() - for each page in the @pages array, release the page
>> + * using put_user_page().
>> + *
>> + * Please see the put_user_page() documentation for details.
>> + *
>> + * This is just like put_user_pages_dirty(), except that it invokes
>> + * set_page_dirty_lock(), instead of set_page_dirty().
> 
> The comment is incorrect.

Yes, it sure is! Jan spotted it before, and I fixed it once, then 
rebased off of the version right *before* the fix, so now I have to 
delete that sentence again.  It's hard to kill! :)

> 
>> + *
>> + * @pages:  array of pages to be marked dirty and released.
>> + * @npages: number of pages in the @pages array.
>> + *
>> + */
>> +void put_user_pages(struct page **pages, unsigned long npages)
>> +{
>> +	unsigned long index;
>> +
>> +	for (index = 0; index < npages; index++)
>> +		put_user_page(pages[index]);
>> +}
> 
> Ditto in terms of code duplication
> 

Here, I think you'll find that the end result, is sufficiently 
de-duplicated, after applying the function pointer above. Here's what it 
looks like without the comment blocks, below. I don't want to go any 
further than this, because the only thing left is the "for" loops, and 
macro-izing such a trivial thing is not really a win:


typedef int (*set_dirty_func)(struct page *page);

static void __put_user_pages_dirty(struct page **pages,
				   unsigned long npages,
				   set_dirty_func sdf)
{
	unsigned long index;

	for (index = 0; index < npages; index++) {
		struct page *page = compound_head(pages[index]);

		if (!PageDirty(page))
			sdf(page);

		put_user_page(page);
	}
}

void put_user_pages_dirty(struct page **pages, unsigned long npages)
{
	__put_user_pages_dirty(pages, npages, set_page_dirty);
}
EXPORT_SYMBOL(put_user_pages_dirty);

void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
{
	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
}
EXPORT_SYMBOL(put_user_pages_dirty_lock);

void put_user_pages(struct page **pages, unsigned long npages)
{
	unsigned long index;

	for (index = 0; index < npages; index++)
		put_user_page(pages[index]);
}
EXPORT_SYMBOL(put_user_pages);

-- 
thanks,
John Hubbard
NVIDIA
