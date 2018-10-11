Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB5AC6B000A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:49:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m45-v6so4751033edc.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:49:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10-v6si17121377ejd.315.2018.10.11.01.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 01:49:30 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:49:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181011084929.GB8418@quack2.suse.cz>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010164541.ec4bf53f5a9e4ba6e5b52a21@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Wed 10-10-18 16:45:41, Andrew Morton wrote:
> On Tue, 9 Oct 2018 17:42:09 -0700 John Hubbard <jhubbard@nvidia.com> wrote:
> 
> > > Also, maintainability.  What happens if someone now uses put_page() by
> > > mistake?  Kernel fails in some mysterious fashion?  How can we prevent
> > > this from occurring as code evolves?  Is there a cheap way of detecting
> > > this bug at runtime?
> > > 
> > 
> > It might be possible to do a few run-time checks, such as "does page that came 
> > back to put_user_page() have the correct flags?", but it's harder (without 
> > having a dedicated page flag) to detect the other direction: "did someone page 
> > in a get_user_pages page, to put_page?"
> > 
> > As Jan said in his reply, converting get_user_pages (and put_user_page) to 
> > work with a new data type that wraps struct pages, would solve it, but that's
> > an awfully large change. Still...given how much of a mess this can turn into 
> > if it's wrong, I wonder if it's worth it--maybe? 
> 
> This is a real worry.  If someone uses a mistaken put_page() then how
> will that bug manifest at runtime?  Under what set of circumstances
> will the kernel trigger the bug?

At runtime such bug will manifest as a page that can never be evicted from
memory. We could warn in put_page() if page reference count drops below
bare minimum for given user pin count which would be able to catch some
issues but it won't be 100% reliable. So at this point I'm more leaning
towards making get_user_pages() return a different type than just
struct page * to make it much harder for refcount to go wrong...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
