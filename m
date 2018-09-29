Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A63898E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 15:19:19 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v125-v6so1965110ita.7
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 12:19:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o68-v6sor3285911ita.95.2018.09.29.12.19.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Sep 2018 12:19:18 -0700 (PDT)
Date: Sat, 29 Sep 2018 13:19:14 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 3/4] infiniband/mm: convert to the new put_user_page()
 call
Message-ID: <20180929191914.GA13783@ziepe.ca>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-3-jhubbard@nvidia.com>
 <20180928153922.GA17076@ziepe.ca>
 <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
 <20180929162117.GA31216@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929162117.GA31216@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On Sat, Sep 29, 2018 at 09:21:17AM -0700, Matthew Wilcox wrote:
> On Fri, Sep 28, 2018 at 08:12:33PM -0700, John Hubbard wrote:
> > >> +++ b/drivers/infiniband/core/umem.c
> > >> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
> > >>  		page = sg_page(sg);
> > >>  		if (!PageDirty(page) && umem->writable && dirty)
> > >>  			set_page_dirty_lock(page);
> > >> -		put_page(page);
> > >> +		put_user_page(page);
> > > 
> > > Would it make sense to have a release/put_user_pages_dirtied to absorb
> > > the set_page_dity pattern too? I notice in this patch there is some
> > > variety here, I wonder what is the right way?
> > > 
> > > Also, I'm told this code here is a big performance bottleneck when the
> > > number of pages becomes very long (think >> GB of memory), so having a
> > > future path to use some kind of batching/threading sound great.
> > 
> > Yes. And you asked for this the first time, too. Consistent! :) Sorry for
> > being slow to pick it up. It looks like there are several patterns, and
> > we have to support both set_page_dirty() and set_page_dirty_lock(). So
> > the best combination looks to be adding a few variations of
> > release_user_pages*(), but leaving put_user_page() alone, because it's
> > the "do it yourself" basic one. Scatter-gather will be stuck with that.
> 
> I think our current interfaces are wrong.  We should really have a
> get_user_sg() / put_user_sg() function that will set up / destroy an
> SG list appropriate for that range of user memory.  This is almost
> orthogonal to the original intent here, so please don't see this as a
> "must do first" kind of argument that might derail the whole thing.

This would be an excellent API, and it is exactly what this 'umem'
code in RDMA is trying to do for RDMA drivers..

I suspect it could do a much better job if it wasn't hindered by the
get_user_pages API - ie it could directly stuff huge pages into the SG
list instead of breaking them up, maybe also avoid the temporary memory
allocations for page * pointers, etc?

Jason
