Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1638E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:30:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so11950828edm.20
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:30:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u22si3304802eds.450.2018.12.18.01.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:30:20 -0800 (PST)
Date: Tue, 18 Dec 2018 10:30:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181218093017.GB18032@quack2.suse.cz>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217183443.GO10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon 17-12-18 10:34:43, Matthew Wilcox wrote:
> On Mon, Dec 17, 2018 at 01:11:50PM -0500, Jerome Glisse wrote:
> > On Mon, Dec 17, 2018 at 08:58:19AM +1100, Dave Chinner wrote:
> > > Sure, that's a possibility, but that doesn't close off any race
> > > conditions because there can be DMA into the page in progress while
> > > the page is being bounced, right? AFAICT this ext3+DIF/DIX case is
> > > different in that there is no 3rd-party access to the page while it
> > > is under IO (ext3 arbitrates all access to it's metadata), and so
> > > nothing can actually race for modification of the page between
> > > submission and bouncing at the block layer.
> > > 
> > > In this case, the moment the page is unlocked, anyone else can map
> > > it and start (R)DMA on it, and that can happen before the bio is
> > > bounced by the block layer. So AFAICT, block layer bouncing doesn't
> > > solve the problem of racing writeback and DMA direct to the page we
> > > are doing IO on. Yes, it reduces the race window substantially, but
> > > it doesn't get rid of it.
> > 
> > So the event flow is:
> >     - userspace create object that match a range of virtual address
> >       against a given kernel sub-system (let's say infiniband) and
> >       let's assume that the range is an mmap() of a regular file
> >     - device driver do GUP on the range (let's assume it is a write
> >       GUP) so if the page is not already map with write permission
> >       in the page table than a page fault is trigger and page_mkwrite
> >       happens
> >     - Once GUP return the page to the device driver and once the
> >       device driver as updated the hardware states to allow access
> >       to this page then from that point on hardware can write to the
> >       page at _any_ time, it is fully disconnected from any fs event
> >       like write back, it fully ignore things like page_mkclean
> > 
> > This is how it is to day, we allowed people to push upstream such
> > users of GUP. This is a fact we have to live with, we can not stop
> > hardware access to the page, we can not force the hardware to follow
> > page_mkclean and force a page_mkwrite once write back ends. This is
> > the situation we are inheriting (and i am personnaly not happy with
> > that).
> > 
> > >From my point of view we are left with 2 choices:
> >     [C1] break all drivers that do not abide by the page_mkclean and
> >          page_mkwrite
> >     [C2] mitigate as much as possible the issue
> > 
> > For [C2] the idea is to keep track of GUP per page so we know if we
> > can expect the page to be written to at any time. Here is the event
> > flow:
> >     - driver GUP the page and program the hardware, page is mark as
> >       GUPed
> >     ...
> >     - write back kicks in on the dirty page, lock the page and every
> >       thing as usual , sees it is GUPed and inform the block layer to
> >       use a bounce page
> 
> No.  The solution John, Dan & I have been looking at is to take the
> dirty page off the LRU while it is pinned by GUP.  It will never be
> found for writeback.
> 
> That's not the end of the story though.  Other parts of the kernel (eg
> msync) also need to be taught to stay away from pages which are pinned
> by GUP.  But the idea is that no page gets written back to storage while
> it's pinned by GUP.  Only when the last GUP ends is the page returned
> to the list of dirty pages.

We've been through this in:

https://lore.kernel.org/lkml/20180709194740.rymbt2fzohbdmpye@quack2.suse.cz/

back in July. You cannot just skip pages for fsync(2). So as I wrote above -
memory cleaning writeback can skip pinned pages. Data integrity writeback
must be able to write pinned pages. And bouncing is one reasonable way how
to do that.

This writeback decision is pretty much independent from the mechanism by
which we are going to identify pinned pages. Whether that's going to be
separate counter in struct page, using page->_mapcount, or separately
allocated data structure as you know promote.

I currently like the most the _mapcount suggestion from Jerome but I'm not
really attached to any solution as long as it performs reasonably and
someone can make it working :) as I don't have time to implement it at
least till January.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
