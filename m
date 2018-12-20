Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C43F98E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:07:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so1651989edd.11
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:07:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si1841669eje.240.2018.12.20.01.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 01:07:56 -0800 (PST)
Date: Thu, 20 Dec 2018 10:07:53 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181220090753.GB27845@quack2.suse.cz>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
 <20181219030329.GI21992@ziepe.ca>
 <20181219102825.GN6311@dastard>
 <20181219113540.GC18345@quack2.suse.cz>
 <20181219223312.GP6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219223312.GP6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu 20-12-18 09:33:12, Dave Chinner wrote:
> On Wed, Dec 19, 2018 at 12:35:40PM +0100, Jan Kara wrote:
> > On Wed 19-12-18 21:28:25, Dave Chinner wrote:
> > > On Tue, Dec 18, 2018 at 08:03:29PM -0700, Jason Gunthorpe wrote:
> > > > On Wed, Dec 19, 2018 at 10:42:54AM +1100, Dave Chinner wrote:
> > > > 
> > > > > Essentially, what we are talking about is how to handle broken
> > > > > hardware. I say we should just brun it with napalm and thermite
> > > > > (i.e. taint the kernel with "unsupportable hardware") and force
> > > > > wait_for_stable_page() to trigger when there are GUP mappings if
> > > > > the underlying storage doesn't already require it.
> > > > 
> > > > If you want to ban O_DIRECT/etc from writing to file backed pages,
> > > > then just do it.
> > > 
> > > O_DIRECT IO *isn't the problem*.
> > 
> > That is not true. O_DIRECT IO is a problem. In some aspects it is easier
> > than the problem with RDMA but currently O_DIRECT IO can crash your machine
> > or corrupt data the same way RDMA can.
> 
> It's not O_DIRECT - it's a ""transient page pin". Yes, there are
> problems with that right now, but as we've discussed the issues can
> be avoided by:
> 
> 	a) stable pages always blocking in ->page_mkwrite;
> 	b) blocking in write_cache_pages() on an elevated map count
> 	when WB_SYNC_ALL is set; and
> 	c) blocking in truncate_pagecache() on an elevated map
> 	count.
> 
> That prevents:
> 	a) gup pinning a page that is currently under writeback and
> 	modifying it while IO is in flight;
> 	b) a dirty page being written back while it is pinned by
> 	GUP, thereby turning it clean before the gup reference calls
> 	set_page_dirty() on DMA completion; and

This is not prevented by what you wrote above as currently GUP does not
increase page->_mapcount. Currently, there's no way to distinguish GUP page
reference from any other page reference - GUP simply does get_page() - and
big part of this thread as I see it is exactly about how to introduce this
distinction and how to convert all GUP users to the new convention safely
(as currently they just pass struct page * pointers around and eventually
do put_page() on them). Increasing page->_mapcount in GUP and trying to
deduce the pin count from that is one option Jerome suggested. At this
point I'm not 100% sure this is going to work but we'll see.

> 	c) truncate/hole punch for pulling the page out from under
> 	the gup operation that is ongoing.
> 
> This is an adequate solution for a short term transient pins. It
> doesn't break fsync(), it doesn't change how truncate works and it
> fixes the problem where a mapped file is the buffer for an O_DIRECT
> IO rather than the open fd and that buffer file gets truncated.
> IOWs, transient pins (and hence O_DIRECT) is not really the problem
> here.

For now let's assume that the mechanism how to detect page pinned by GUP is
actually somehow solved and we have already page_pinned() implemented. Then
what you suggest can actually create a deadlock AFAICS:

Process 1:						Process 2:

							fsync("file")
/* Evil memory buffer with page order reversed */
addr1 = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED, "file", 4096);
addr2 = mmap(addr1+4096, 4096, PROT_WRITE, MAP_SHARED, "file", 0);

/* Fault in pages */
*addr1 = 0;
*addr2 = 0;
							adds page with index 0
							  to bio

fd = open("file2", O_RDWR | O_DIRECT);
read(fd, addr1, 8192)
  -> eventually gets to iov_iter_get_pages() and then to
     get_user_pages_fast().
     -> pins "file" page with index 1
							blocks on pin for
							  page with index 1
     -> blocks in PageWriteback for page with index 0

Possibility of deadlocks like this is why I've decided it will be easier
to just bounce the page for writeback we cannot avoid rather than block the
writeback...

> The problem with this is that blocking on elevated map count does
> not work for long term pins (i.e. gup_longterm()) which are defined
> as:
> 
>  * "longterm" == userspace controlled elevated page count lifetime.
>  * Contrast this to iov_iter_get_pages() usages which are transient.
> 
> It's the "userspace controlled" part of the long term gup pin that
> is the problem we need to solve. If we treat them the same as a
> transient pin, then this leads to fsync() and truncate either
> blocking for a long time waiting for userspace to drop it's gup
> reference, or having to be failed with something like EBUSY or
> EAGAIN.

I agree. "userspace controlled" pins are another big problem to solve.

> This is the problem revokable file layout leases solve. The NFS
> server is already using this for revoking delegations from remote
> clients. Userspace holding long term GUP references is essentially
> the same thing - it's a delegation of file ownership to userspace
> that the filesystem must be able to revoke when it needs to run
> internal and/or 3rd-party requested operations on that delegated
> file.
> 
> If the hardware supports page faults, then we can further optimise
> the long term pin case to relax stable page requirements and allow
> page cleaning to occur while there are long term pins. In this case,
> the hardware will write-fault the clean pages appropriately before
> DMA is initiated, and hence avoid the need for data integrity
> operations like fsync() to trigger lease revocation. However,
> truncate/hole punch still requires lease revocation to work sanely,
> especially when we consider DAX *must* ensure there are no remaining
> references to the physical pmem page after the space has been freed.
> 
> i.e. conflating the transient and long term gup pins as the same
> problem doesn't help anyone. If we fix the short term pin problems,
> then the long term pin problem become tractable by adding a layer
> over the top (i.e.  hardware page fault capability and/or file lease
> requirements).  Existing apps and hardware will continue to work -
> external operations on the pinned file will simply hang rather than
> causing corruption or kernel crashes.  New (or updated) applications
> will play nicely with lease revocation and at that point the "long
> term pin" basically becomes a transient pin where the unpin latency
> is determined by how quickly the app responds to the lease
> revocation. And page fault capable hardware will reduce the
> occurrence of lease revocations due to data writeback/integrity
> operations and behave almost identically to cpu-based mmap accesses
> to file backed pages.

Agreed. I think we are on the same page wrt this. Just at this point I'm
trying to solve the "transient pin" problem...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
