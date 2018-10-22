Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD8E26B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 15:43:33 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m67-v6so12773654ita.8
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 12:43:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q185-v6sor21214000itd.33.2018.10.22.12.43.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 12:43:32 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:43:29 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181022194329.GG30059@ziepe.ca>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
 <20181011084929.GB8418@quack2.suse.cz>
 <20181011132013.GA5968@ziepe.ca>
 <97e89e08-5b94-240a-56e9-ece2b91f6dbc@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97e89e08-5b94-240a-56e9-ece2b91f6dbc@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Thu, Oct 11, 2018 at 06:23:24PM -0700, John Hubbard wrote:
> On 10/11/18 6:20 AM, Jason Gunthorpe wrote:
> > On Thu, Oct 11, 2018 at 10:49:29AM +0200, Jan Kara wrote:
> > 
> >>> This is a real worry.  If someone uses a mistaken put_page() then how
> >>> will that bug manifest at runtime?  Under what set of circumstances
> >>> will the kernel trigger the bug?
> >>
> >> At runtime such bug will manifest as a page that can never be evicted from
> >> memory. We could warn in put_page() if page reference count drops below
> >> bare minimum for given user pin count which would be able to catch some
> >> issues but it won't be 100% reliable. So at this point I'm more leaning
> >> towards making get_user_pages() return a different type than just
> >> struct page * to make it much harder for refcount to go wrong...
> > 
> > At least for the infiniband code being used as an example here we take
> > the struct page from get_user_pages, then stick it in a sgl, and at
> > put_page time we get the page back out of the sgl via sg_page()
> > 
> > So type safety will not help this case... I wonder how many other
> > users are similar? I think this is a pretty reasonable flow for DMA
> > with user pages.
> > 
> 
> That is true. The infiniband code, fortunately, never mixes the two page
> types into the same pool (or sg list), so it's actually an easier example
> than some other subsystems. But, yes, type safety doesn't help there. I can 
> take a moment to look around at the other areas, to quantify how much a type
> safety change might help.

Are most (all?) of the places working with SGLs?

Maybe we could just have a 'get_user_pages_to_sgl' and 'put_pages_sgl'
sort of interface that handled all this instead of trying to make
something that is struct page based?

It seems easier to get an extra bit for user/!user in the SGL
datastructure?

Jason
