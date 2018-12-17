Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24F298E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 14:48:08 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so18497017qtl.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:48:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e126si2603423qkb.261.2018.12.17.11.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 11:48:06 -0800 (PST)
Date: Mon, 17 Dec 2018 14:48:00 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181217194759.GB3341@redhat.com>
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
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181217183443.GO10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Dec 17, 2018 at 10:34:43AM -0800, Matthew Wilcox wrote:
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
> 
> >     - block layer copy the page to a bounce page effectively creating
> >       a snapshot of what is the content of the real page. This allows
> >       everything in block layer that need stable content to work on
> >       the bounce page (raid, stripping, encryption, ...)
> >     - once write back is done the page is not marked clean but stays
> >       dirty, this effectively disable things like COW for filesystem
> >       and other feature that expect page_mkwrite between write back.
> >       AFAIK it is believe that it is something acceptable
> 
> So none of this is necessary.

With the solution you are proposing we loose GUP fast and we have to
allocate a structure for each page that is under GUP, and the LRU
changes too. Moreover by not writing back there is a greater chance
of data loss.

I will do patches with the mapcount solution that require very little
change and people will be able to choose which solution they prefer.

Personaly i prefer the mapcount solution as it is less invasive.

Cheers,
J�r�me
