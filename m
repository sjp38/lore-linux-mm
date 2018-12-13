Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E62498E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:51:24 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s27so273439pgm.4
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:51:24 -0800 (PST)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id u6si252246plz.220.2018.12.12.16.51.22
        for <linux-mm@kvack.org>;
        Wed, 12 Dec 2018 16:51:23 -0800 (PST)
Date: Thu, 13 Dec 2018 11:51:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213005119.GD29416@dastard>
References: <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212215931.GG5037@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> > On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > So this approach doesn't look like a win to me over using counter in struct
> > > > page and I'd rather try looking into squeezing HMM public page usage of
> > > > struct page so that we can fit that gup counter there as well. I know that
> > > > it may be easier said than done...
> > > 
> > > So i want back to the drawing board and first i would like to ascertain
> > > that we all agree on what the objectives are:
> > > 
> > >     [O1] Avoid write back from a page still being written by either a
> > >          device or some direct I/O or any other existing user of GUP.

IOWs, you need to mark pages being written to by a GUP as
PageWriteback, so all attempts to write the page will block on
wait_on_page_writeback() before trying to write the dirty page.

> > >          This would avoid possible file system corruption.

This isn't a filesystem corruption vector. At worst, it could cause
torn data writes due to updating the page while it is under IO. We
have a name for this: "stable pages". This is designed to prevent
updates to pages via mmap writes from causing corruption of things
like MD RAID due to modification of the data during RAID parity
calculations. Hence we have wait_for_stable_page() calls in all
->page_mkwrite implementations so that new mmap writes block until
writeback IO is complete on the devices that require stable pages
to prevent corruption.

IOWs, we already deal with this "delay new modification while
writeback is in progress" problem in the mmap/filesystem world and
have infrastructure to handle it. And the ->page_mkwrite code
already deals with it.

> > > 
> > >     [O2] Avoid crash when set_page_dirty() is call on a page that is
> > >          considered clean by core mm (buffer head have been remove and
> > >          with some file system this turns into an ugly mess).
> > 
> > I think that's wrong. This isn't an "avoid a crash" case, this is a
> > "prevent data and/or filesystem corruption" case. The primary goal
> > we have here is removing our exposure to potential corruption, which
> > has the secondary effect of avoiding the crash/panics that currently
> > occur as a result of inconsistent page/filesystem state.
> 
> This is O1 avoid corruption is O1

It's "avoid a specific instance of data corruption", not a general
mechanism for avoiding data/filesystem corruption.

Calling set_page_dirty() on a file backed page which has not been
correctly prepared can cause data corruption, filesystem coruption
and shutdowns, etc because we have dirty data over a region that is
not correctly mapped. Yes, it can also cause a crash (because we
really, really suck at validation and error handling in generic code
paths), but there's so, so much more that can go wrong than crash
the kernel when we do stupid shit like this.

> > i.e. The goal is to have ->page_mkwrite() called on the clean page
> > /before/ the file-backed page is marked dirty, and hence we don't
> > expose ourselves to potential corruption or crashes that are a
> > result of inappropriately calling set_page_dirty() on clean
> > file-backed pages.
> 
> Yes and this would be handle by put_user_page ie:

No, put_user_page() is too late - it's after the DMA has completed,
but we have to ensure the file has backing store allocated and the
pages are in the correct state /before/ the DMA is done.

Think ENOSPC - that has to be handled before we do the DMA, not
after. Before the DMA it is a recoverable error, after the DMA it is
data loss/corruption failure.

> put_user_page(struct page *page, bool dirty)
> {
>     if (!PageAnon(page)) {
>         if (dirty) {
>             // Do the whole dance ie page_mkwrite and all before
>             // calling set_page_dirty()
>         }
>         ...
>     }
>     ...
> }

Essentially, doing this would require a whole new "dirty a page"
infrastructure because it is in the IO path, not the page fault
path.

And, for hardware that does it's own page faults for DMA, this whole
post-DMA page setup is broken because the pages will have already
gone through ->page_mkwrite() and be set up correctly already.

> > > For [O2] i believe we can handle that case in the put_user_page()
> > > function to properly dirty the page without causing filesystem
> > > freak out.
> > 
> > I'm pretty sure you can't call ->page_mkwrite() from
> > put_user_page(), so I don't think this is workable at all.
> 
> Hu why ? i can not think of any reason whike you could not. User of

It's not a fault path, you can't safely lock pages, you can't take
fault-path only locks in the IO path (mmap_sem inversion problems),
etc.

/me has a nagging feeling this was all explained in a previous
discussions of this patchset...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
