Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95B246B0003
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 04:30:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x20-v6so788178eda.21
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 01:30:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6-v6si6076770edd.134.2018.10.09.01.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 01:30:27 -0700 (PDT)
Date: Tue, 9 Oct 2018 10:30:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181009083025.GE11150@quack2.suse.cz>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Mon 08-10-18 17:14:42, Andrew Morton wrote:
> On Mon,  8 Oct 2018 14:16:22 -0700 john.hubbard@gmail.com wrote:
> > +		put_user_page(pages[index]);
> > +	}
> > +}
> > +
> > +static inline void put_user_pages(struct page **pages,
> > +				  unsigned long npages)
> > +{
> > +	unsigned long index;
> > +
> > +	for (index = 0; index < npages; index++)
> > +		put_user_page(pages[index]);
> > +}
> > +
> 
> Otherwise looks OK.  Ish.  But it would be nice if that comment were to
> explain *why* get_user_pages() pages must be released with
> put_user_page().

The reason is that eventually we want to track reference from GUP
separately but you're right that it would be good to have a comment about
that somewhere.

> Also, maintainability.  What happens if someone now uses put_page() by
> mistake?  Kernel fails in some mysterious fashion?  How can we prevent
> this from occurring as code evolves?  Is there a cheap way of detecting
> this bug at runtime?

The same will happen as with any other reference counting bug - the special
user reference will leak. It will be pretty hard to debug I agree. I was
thinking about whether we could provide some type safety against such bugs
such as get_user_pages() not returning struct page pointers but rather some
other special type but it would result in a big amount of additional churn
as we'd have to propagate this different type e.g. through the IO path so
that IO completion routines could properly call put_user_pages(). So I'm
not sure it's really worth it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
