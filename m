Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 664286B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:20:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p73-v6so8243280qkp.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:20:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42sor2482175qvi.38.2018.10.11.06.20.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 06:20:17 -0700 (PDT)
Date: Thu, 11 Oct 2018 07:20:13 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181011132013.GA5968@ziepe.ca>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
 <20181011084929.GB8418@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011084929.GB8418@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Thu, Oct 11, 2018 at 10:49:29AM +0200, Jan Kara wrote:

> > This is a real worry.  If someone uses a mistaken put_page() then how
> > will that bug manifest at runtime?  Under what set of circumstances
> > will the kernel trigger the bug?
> 
> At runtime such bug will manifest as a page that can never be evicted from
> memory. We could warn in put_page() if page reference count drops below
> bare minimum for given user pin count which would be able to catch some
> issues but it won't be 100% reliable. So at this point I'm more leaning
> towards making get_user_pages() return a different type than just
> struct page * to make it much harder for refcount to go wrong...

At least for the infiniband code being used as an example here we take
the struct page from get_user_pages, then stick it in a sgl, and at
put_page time we get the page back out of the sgl via sg_page()

So type safety will not help this case... I wonder how many other
users are similar? I think this is a pretty reasonable flow for DMA
with user pages.

Jason
