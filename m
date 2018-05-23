Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 070436B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 19:04:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 5-v6so2961059qke.19
        for <linux-mm@kvack.org>; Wed, 23 May 2018 16:04:03 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j10-v6si4193077qtk.213.2018.05.23.16.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 16:04:01 -0700 (PDT)
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca>
 <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
 <20180518173637.GF15611@ziepe.ca>
 <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
 <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com>
 <20180519032400.GA12517@ziepe.ca>
 <CAPcyv4iGmUg108O-s1h6_YxmjQgMcV_pFpciObHh3zJkTOKfKA@mail.gmail.com>
 <20180521143830.GA25109@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <414dceeb-1cd1-61e4-2e5b-31f06242aba3@nvidia.com>
Date: Wed, 23 May 2018 16:03:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180521143830.GA25109@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Christopher Lameter <cl@linux.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On 05/21/2018 07:38 AM, Matthew Wilcox wrote:
> On Fri, May 18, 2018 at 08:51:38PM -0700, Dan Williams wrote:
-------------8<------------------------------------------------
> 
> Suggestion 1:
> 
> in get_user_pages_fast(), mark the page as dirty, but don't tag the radix
> tree entry as dirty.  Then vmscan() won't find it when it's looking to
> write out dirty pages.  Only mark it as dirty in the radix tree once we
> call set_page_dirty_lock().
> 
> Suggestion 2:
> 
> in get_user_pages_fast(), replace the page in the radix tree with a special
> entry that means "page under io".  In set_page_dirty_lock(), replace the
> "page under io" entry with the struct page pointer.

This second one feels a simpler to me. If no one sees huge problems with this,
I can put this together and try it out, because I have a few nicely reproducible
bugs that I can test this on.

But with either approach, a quick question first: will this do the right thing
for the other two use cases below?

    a) ftruncate

    b) deleting the inode and dropping all references to it (only the 
       get_user_pages reference remains)

...or is some other way to sneak in and try_to_free_buffers() on a 
page in this state?

Also, just to be sure I'm on the same page, is it accurate to claim that we
would then have the following updated guidelines for device drivers and
user space?

1. You can safely DMA to file-backed memory that you've pinned via
get_user_pages (with the usual caveats about getting the pages you think
you're getting), if you are careful to avoid truncating or deleting the 
file out from under get_user_pages.

In other words, this pattern is supported:

    get_user_pages (on file-backed memory from a persistent storage filesystem)
    ...do some DMA
    set_page_dirty_lock
    put_page

2. Furthermore, even if you are less careful, you still won't crash the kernel,
The worst that could happen is to corrupt your data, due to interrupting the
writeback.

The possibility of data corruption is bad, but it's also arguably both
self-inflicted and avoidable. Anyway, even so, it's an improvement: the bugs
I'm seeing would definitely get fixed with this.
    
> 
> Both of these suggestions have trouble with simultaneous sub-page IOs to the
> same page.  Do we care?  I suspect we might as pages get larger (see also:
> supporting THP pages in the page cache).
> 

I don't *think* we care. At least, no examples occur to me where this would
cause a problem.

thanks,
-- 
John Hubbard
NVIDIA
