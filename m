Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 851DC6B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 02:18:01 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id q124-v6so6823923ybg.18
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 23:18:01 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z187-v6si24914034ywe.241.2018.11.04.23.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 23:18:00 -0800 (PST)
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
 <20181011084929.GB8418@quack2.suse.cz> <20181011132013.GA5968@ziepe.ca>
 <97e89e08-5b94-240a-56e9-ece2b91f6dbc@nvidia.com>
 <20181022194329.GG30059@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <532c7ae5-7277-74a7-93f2-afe8b7dc13fc@nvidia.com>
Date: Sun, 4 Nov 2018 23:17:58 -0800
MIME-Version: 1.0
In-Reply-To: <20181022194329.GG30059@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome
 Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph
 Campbell <rcampbell@nvidia.com>

On 10/22/18 12:43 PM, Jason Gunthorpe wrote:
> On Thu, Oct 11, 2018 at 06:23:24PM -0700, John Hubbard wrote:
>> On 10/11/18 6:20 AM, Jason Gunthorpe wrote:
>>> On Thu, Oct 11, 2018 at 10:49:29AM +0200, Jan Kara wrote:
>>>
>>>>> This is a real worry.  If someone uses a mistaken put_page() then how
>>>>> will that bug manifest at runtime?  Under what set of circumstances
>>>>> will the kernel trigger the bug?
>>>>
>>>> At runtime such bug will manifest as a page that can never be evicted from
>>>> memory. We could warn in put_page() if page reference count drops below
>>>> bare minimum for given user pin count which would be able to catch some
>>>> issues but it won't be 100% reliable. So at this point I'm more leaning
>>>> towards making get_user_pages() return a different type than just
>>>> struct page * to make it much harder for refcount to go wrong...
>>>
>>> At least for the infiniband code being used as an example here we take
>>> the struct page from get_user_pages, then stick it in a sgl, and at
>>> put_page time we get the page back out of the sgl via sg_page()
>>>
>>> So type safety will not help this case... I wonder how many other
>>> users are similar? I think this is a pretty reasonable flow for DMA
>>> with user pages.
>>>
>>
>> That is true. The infiniband code, fortunately, never mixes the two page
>> types into the same pool (or sg list), so it's actually an easier example
>> than some other subsystems. But, yes, type safety doesn't help there. I can 
>> take a moment to look around at the other areas, to quantify how much a type
>> safety change might help.
> 
> Are most (all?) of the places working with SGLs?

I finally put together a spreadsheet, in order to answer this sort of thing.
Some notes:

a) There are around 100 call sites of either get_user_pages*(), or indirect
calls via iov_iter_get_pages*().

b) There are only a few SGL users. Most are ad-hoc, instead: some loop that
either can be collapsed nicely into the new put_user_pages*() APIs, or...
cannot.

c) The real problem is: around 20+ iov_iter_get_pages*() call sites. I need
to change both the  iov_iter system a little bit, and also change the callers
so that they don't pile all the gup-pinned pages into the same page** array
that also contains other allocation types. This can be done, it just takes
time, that's the good news.

> 
> Maybe we could just have a 'get_user_pages_to_sgl' and 'put_pages_sgl'
> sort of interface that handled all this instead of trying to make
> something that is struct page based?
> 
> It seems easier to get an extra bit for user/!user in the SGL
> datastructure?
> 

So at the moment I don't think we need this *_sgl interface. We need iov_iter*
changes instead.

thanks,
-- 
John Hubbard
NVIDIA
