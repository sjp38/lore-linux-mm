Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F27056B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:19:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x44-v6so18147138edd.17
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 03:19:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1-v6si7511166ejf.311.2018.10.18.03.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 03:19:53 -0700 (PDT)
Date: Thu, 18 Oct 2018 12:19:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181018101951.GO23493@quack2.suse.cz>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
 <20181011084929.GB8418@quack2.suse.cz>
 <20181011132013.GA5968@ziepe.ca>
 <97e89e08-5b94-240a-56e9-ece2b91f6dbc@nvidia.com>
 <b9899626-9033-348b-6f07-dc90bcd8a468@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9899626-9033-348b-6f07-dc90bcd8a468@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Thu 11-10-18 20:53:34, John Hubbard wrote:
> On 10/11/18 6:23 PM, John Hubbard wrote:
> > On 10/11/18 6:20 AM, Jason Gunthorpe wrote:
> >> On Thu, Oct 11, 2018 at 10:49:29AM +0200, Jan Kara wrote:
> >>
> >>>> This is a real worry.  If someone uses a mistaken put_page() then how
> >>>> will that bug manifest at runtime?  Under what set of circumstances
> >>>> will the kernel trigger the bug?
> >>>
> >>> At runtime such bug will manifest as a page that can never be evicted from
> >>> memory. We could warn in put_page() if page reference count drops below
> >>> bare minimum for given user pin count which would be able to catch some
> >>> issues but it won't be 100% reliable. So at this point I'm more leaning
> >>> towards making get_user_pages() return a different type than just
> >>> struct page * to make it much harder for refcount to go wrong...
> >>
> >> At least for the infiniband code being used as an example here we take
> >> the struct page from get_user_pages, then stick it in a sgl, and at
> >> put_page time we get the page back out of the sgl via sg_page()
> >>
> >> So type safety will not help this case... I wonder how many other
> >> users are similar? I think this is a pretty reasonable flow for DMA
> >> with user pages.
> >>
> > 
> > That is true. The infiniband code, fortunately, never mixes the two page
> > types into the same pool (or sg list), so it's actually an easier example
> > than some other subsystems. But, yes, type safety doesn't help there. I can 
> > take a moment to look around at the other areas, to quantify how much a type
> > safety change might help.
> > 
> > Back to page flags again, out of desperation:
> > 
> > How much do we know about the page types that all of these subsystems
> > use? In other words, can we, for example, use bit 1 of page->lru.next (see [1]
> > for context) as the "dma-pinned" page flag, while tracking pages within parts 
> > of the kernel that call a mix of alloc_pages, get_user_pages, and other allocators? 
> > In order for that to work, page->index, page->private, and bit 1 of page->mapping
> > must not be used. I doubt that this is always going to hold, but...does it?
> > 
> 
> Oops, pardon me, please ignore that nonsense about page->index and page->private
> and page->mapping, that's actually fine (I was seeing "union", where "struct" was
> written--too much staring at this code). 
> 
> So actually, I think maybe we can just use bit 1 in page->lru.next to sort out
> which pages are dma-pinned, in the calling code, just like we're going to do
> in writeback situations. This should also allow run-time checking that Andrew was 
> hoping for:
> 
>     put_user_page(): assert that the page is dma-pinned
>     put_page(): assert that the page is *not* dma-pinned
> 
> ...both of which depend on that bit being, essentially, available as sort
> of a general page flag. And in fact, if it's not, then the whole approach
> is dead anyway.

Well, put_page() cannot assert page is not dma-pinned as someone can still
to get_page(), put_page() on dma-pinned page and that must not barf. But
put_page() could assert that if the page is pinned, refcount is >=
pincount. That will detect leaked pin references relatively quickly.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
