Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA716B0266
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:42:12 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id g194-v6so1747650ybf.5
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:42:12 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n17-v6si5646874ybg.216.2018.10.09.17.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:42:11 -0700 (PDT)
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
Date: Tue, 9 Oct 2018 17:42:09 -0700
MIME-Version: 1.0
In-Reply-To: <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On 10/8/18 5:14 PM, Andrew Morton wrote:
> On Mon,  8 Oct 2018 14:16:22 -0700 john.hubbard@gmail.com wrote:
> 
>> From: John Hubbard <jhubbard@nvidia.com>
[...]
>> +/*
>> + * Pages that were pinned via get_user_pages*() should be released via
>> + * either put_user_page(), or one of the put_user_pages*() routines
>> + * below.
>> + */
>> +static inline void put_user_page(struct page *page)
>> +{
>> +	put_page(page);
>> +}
>> +
>> +static inline void put_user_pages_dirty(struct page **pages,
>> +					unsigned long npages)
>> +{
>> +	unsigned long index;
>> +
>> +	for (index = 0; index < npages; index++) {
>> +		if (!PageDirty(pages[index]))
> 
> Both put_page() and set_page_dirty() handle compound pages.  But
> because of the above statement, put_user_pages_dirty() might misbehave? 
> Or maybe it won't - perhaps the intent here is to skip dirtying the
> head page if the sub page is clean?  Please clarify, explain and add
> comment if so.
> 

Yes, technically, the accounting is wrong: we normally use the head page to 
track dirtiness, and here, that is not done. (Nor was it done before this
patch). However, it's not causing problems in code today because sub pages
are released at about the same time as head pages, so the head page does get 
properly checked at some point. And that means that set_page_dirty*() gets
called if it needs to be called. 

Obviously this is a little fragile, in that it depends on the caller behaving 
a certain way. And in any case, the long-term fix (coming later) *also* only
operates on the head page. So actually, instead of a comment, I think it's good 
to just insert

	page = compound_head(page);

...into these new routines, right now. I'll do that.

[...]
> 
> Otherwise looks OK.  Ish.  But it would be nice if that comment were to
> explain *why* get_user_pages() pages must be released with
> put_user_page().
> 

Yes, will do.

> Also, maintainability.  What happens if someone now uses put_page() by
> mistake?  Kernel fails in some mysterious fashion?  How can we prevent
> this from occurring as code evolves?  Is there a cheap way of detecting
> this bug at runtime?
> 

It might be possible to do a few run-time checks, such as "does page that came 
back to put_user_page() have the correct flags?", but it's harder (without 
having a dedicated page flag) to detect the other direction: "did someone page 
in a get_user_pages page, to put_page?"

As Jan said in his reply, converting get_user_pages (and put_user_page) to 
work with a new data type that wraps struct pages, would solve it, but that's
an awfully large change. Still...given how much of a mess this can turn into 
if it's wrong, I wonder if it's worth it--maybe? 

thanks,
-- 
John Hubbard
NVIDIA
 
