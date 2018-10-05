Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 895836B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 15:49:09 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id o2-v6so7521052ybq.18
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 12:49:09 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s72-v6si1185592ybi.107.2018.10.05.12.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 12:49:08 -0700 (PDT)
Subject: Re: [PATCH v2 2/3] mm: introduce put_user_page[s](), placeholder
 versions
References: <20181005040225.14292-1-jhubbard@nvidia.com>
 <20181005040225.14292-3-jhubbard@nvidia.com>
 <20181005151726.GA20776@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c6f31004-3a67-880b-47bb-b560dfd85343@nvidia.com>
Date: Fri, 5 Oct 2018 12:49:06 -0700
MIME-Version: 1.0
In-Reply-To: <20181005151726.GA20776@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>

On 10/5/18 8:17 AM, Jason Gunthorpe wrote:
> On Thu, Oct 04, 2018 at 09:02:24PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Introduces put_user_page(), which simply calls put_page().
>> This provides a way to update all get_user_pages*() callers,
>> so that they call put_user_page(), instead of put_page().
>>
>> Also introduces put_user_pages(), and a few dirty/locked variations,
>> as a replacement for release_pages(), for the same reasons.
>> These may be used for subsequent performance improvements,
>> via batching of pages to be released.
>>
>> This prepares for eventually fixing the problem described
>> in [1], and is following a plan listed in [2], [3], [4].
>>
>> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
>>
>> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>>     Proposed steps for fixing get_user_pages() + DMA problems.
>>
>> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
>>     Bounce buffers (otherwise [2] is not really viable).
>>
>> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
>>     Follow-up discussions.
>>
[...]
>>  
>> +/* Placeholder version, until all get_user_pages*() callers are updated. */
>> +static inline void put_user_page(struct page *page)
>> +{
>> +	put_page(page);
>> +}
>> +
>> +/* For get_user_pages*()-pinned pages, use these variants instead of
>> + * release_pages():
>> + */
>> +static inline void put_user_pages_dirty(struct page **pages,
>> +					unsigned long npages)
>> +{
>> +	while (npages) {
>> +		set_page_dirty(pages[npages]);
>> +		put_user_page(pages[npages]);
>> +		--npages;
>> +	}
>> +}
> 
> Shouldn't these do the !PageDirty(page) thing?
> 

Well, not yet. This is the "placeholder" patch, in which I planned to keep
the behavior the same, while I go to all the get_user_pages call sites and change 
put_page() and release_pages() over to use these new routines.

After the call sites are changed, then these routines will be updated to do more.
[2], above has slightly more detail about that.


thanks,
-- 
John Hubbard
NVIDIA
