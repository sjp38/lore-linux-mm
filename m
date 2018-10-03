Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D86F6B026B
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:21:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a4-v6so3395347pfi.16
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:21:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a94-v6si2261332pla.123.2018.10.03.09.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:21:18 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:21:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
Message-ID: <20181003162115.GG24030@quack2.suse.cz>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928152958.GA3321@redhat.com>
 <4c884529-e2ff-3808-9763-eb0e71f5a616@nvidia.com>
 <20180928214934.GA3265@redhat.com>
 <dfa6aaef-b97e-ebd4-6cc8-c907a7b3f9bb@nvidia.com>
 <20180929084608.GA3188@redhat.com>
 <20181001061127.GQ31060@dastard>
 <20181001124757.GA26218@infradead.org>
 <20181002011447.GT31060@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002011447.GT31060@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On Tue 02-10-18 11:14:47, Dave Chinner wrote:
> On Mon, Oct 01, 2018 at 05:47:57AM -0700, Christoph Hellwig wrote:
> > On Mon, Oct 01, 2018 at 04:11:27PM +1000, Dave Chinner wrote:
> > > This reminds me so much of Linux mmap() in the mid-2000s - mmap()
> > > worked for ext3 without being aware of page faults,
> > 
> > And "worked" still is a bit of a stretch, as soon as you'd get
> > ENOSPC it would still blow up badly.  Which probably makes it an
> > even better analogy to the current case.
> > 
> > > RDMA does not call ->page_mkwrite on clean file backed pages before it
> > > writes to them and calls set_page_dirty(), and hence RDMA to file
> > > backed pages is completely unreliable. I'm not sure this can be
> > > solved without having page fault capable RDMA hardware....
> > 
> > We can always software prefault at gup time.
> 
> I'm not sure that's sufficient - we've got a series of panics from
> machines running ext4+RDMA where there are no bufferheads on dirty
> pages at writeback time. This was also reproducable on versions of
> XFS that used bufferheads.
> 
> We suspect that memory reclaim has tripped the bufferhead stripping
> threshold (yeah, that old ext3 hack to avoid writeback deadlocks
> under memory pressure), hence removed the bufferheads from clean
> mapped pages while RDMA has them pinned. And then some time later
> after set_page_dirty() was called on them the filesystem's page
> writeback code crashes and burns....
> 
> i.e. just because the page was in a known state at when it was
> pinned, it doesn't mean it will remain in that state until it is
> unpinned....

Exactly. The problem really is GUP user can call set_page_dirty() after the
page has been unmapped from all page tables and thus filesystem is totaly
unprepared to handle that.

> > And also remember that
> > while RDMA might be the case at least some people care about here it
> > really isn't different from any of the other gup + I/O cases, including
> > doing direct I/O to a mmap area.  The only difference in the various
> > cases is how long the area should be pinned down - some users like RDMA
> > want a long term mapping, while others like direct I/O just need a short
> > transient one.
> 
> Yup, now that I'm aware of all those little intricacies with gup I
> always try to consider what impact they have...
> 
> > > We could address these use-after-free situations via forcing RDMA to
> > > use file layout leases and revoke the lease when we need to modify
> > > the backing store on leased files. However, this doesn't solve the
> > > need for filesystems to receive write fault notifications via
> > > ->page_mkwrite.
> > 
> > Exactly.   We need three things here:
> > 
> >  - notification to the filesystem that a page is (possibly) beeing
> >    written to
> >  - a way to to block fs operations while the pages are pinned
> >  - a way to distinguish between short and long term mappings,
> >    and only allow long terms mappings if they can be broken
> >    using something like leases

Actually when using page cache, we should be fine with just knowing the
page it pinned by GUP. Writeback can then use bounce buffers to handle
data integrity writeout requests, skip periodic writeback, and keep page
dirty all the time it is pinned. That should deal with all the problems we
are currently aware of.

With DAX more is needed as truncate cannot proceed with pending GUP
references. So there we really need all you mention above. But for DAX we
have much more wiggle room how to define behavior and what we declare as
unsupported as DAX is new and it was never really used with RDMA and stuff.

> > I'm also pretty sure we already explained this a long time ago when the
> > issue came up last year, so I'm not sure why this is even still
> > contentious.
> 
> I suspect that it's simply because these discussions have been
> spread across different groups and not everyone is aware of what the
> other groups are discussing...

Yes, I have the same feeling.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
