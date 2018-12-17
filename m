Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA1B18E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:11:59 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s70so16331181qks.4
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:11:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l202si3227109qke.87.2018.12.17.10.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 10:11:58 -0800 (PST)
Date: Mon, 17 Dec 2018 13:11:50 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181217181148.GA3341@redhat.com>
References: <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181216215819.GC10644@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Dec 17, 2018 at 08:58:19AM +1100, Dave Chinner wrote:
> On Fri, Dec 14, 2018 at 04:43:21PM +0100, Jan Kara wrote:
> > Hi!
> > 
> > On Thu 13-12-18 08:46:41, Dave Chinner wrote:
> > > On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > > > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > > So this approach doesn't look like a win to me over using counter in struct
> > > > > page and I'd rather try looking into squeezing HMM public page usage of
> > > > > struct page so that we can fit that gup counter there as well. I know that
> > > > > it may be easier said than done...
> > > > 
> > > > So i want back to the drawing board and first i would like to ascertain
> > > > that we all agree on what the objectives are:
> > > > 
> > > >     [O1] Avoid write back from a page still being written by either a
> > > >          device or some direct I/O or any other existing user of GUP.
> > > >          This would avoid possible file system corruption.
> > > > 
> > > >     [O2] Avoid crash when set_page_dirty() is call on a page that is
> > > >          considered clean by core mm (buffer head have been remove and
> > > >          with some file system this turns into an ugly mess).
> > > 
> > > I think that's wrong. This isn't an "avoid a crash" case, this is a
> > > "prevent data and/or filesystem corruption" case. The primary goal
> > > we have here is removing our exposure to potential corruption, which
> > > has the secondary effect of avoiding the crash/panics that currently
> > > occur as a result of inconsistent page/filesystem state.
> > > 
> > > i.e. The goal is to have ->page_mkwrite() called on the clean page
> > > /before/ the file-backed page is marked dirty, and hence we don't
> > > expose ourselves to potential corruption or crashes that are a
> > > result of inappropriately calling set_page_dirty() on clean
> > > file-backed pages.
> > 
> > I agree that [O1] - i.e., avoid corrupting fs data - is more important and
> > [O2] is just one consequence of [O1].
> > 
> > > > For [O1] and [O2] i believe a solution with mapcount would work. So
> > > > no new struct, no fake vma, nothing like that. In GUP for file back
> > > > pages we increment both refcount and mapcount (we also need a special
> > > > put_user_page to decrement mapcount when GUP user are done with the
> > > > page).
> > > 
> > > I don't see how a mapcount can prevent anyone from calling
> > > set_page_dirty() inappropriately.
> > > 
> > > > Now for [O1] the write back have to call page_mkclean() to go through
> > > > all reverse mapping of the page and map read only. This means that
> > > > we can count the number of real mapping and see if the mapcount is
> > > > bigger than that. If mapcount is bigger than page is pin and we need
> > > > to use a bounce page to do the writeback.
> > > 
> > > Doesn't work. Generally filesystems have already mapped the page
> > > into bios before they call clear_page_dirty_for_io(), so it's too
> > > late for the filesystem to bounce the page at that point.
> > 
> > Yes, for filesystem it is too late. But the plan we figured back in October
> > was to do the bouncing in the block layer. I.e., mark the bio (or just the
> > particular page) as needing bouncing and then use the existing page
> > bouncing mechanism in the block layer to do the bouncing for us. Ext3 (when
> > it was still a separate fs driver) has been using a mechanism like this to
> > make DIF/DIX work with its metadata.
> 
> Sure, that's a possibility, but that doesn't close off any race
> conditions because there can be DMA into the page in progress while
> the page is being bounced, right? AFAICT this ext3+DIF/DIX case is
> different in that there is no 3rd-party access to the page while it
> is under IO (ext3 arbitrates all access to it's metadata), and so
> nothing can actually race for modification of the page between
> submission and bouncing at the block layer.
> 
> In this case, the moment the page is unlocked, anyone else can map
> it and start (R)DMA on it, and that can happen before the bio is
> bounced by the block layer. So AFAICT, block layer bouncing doesn't
> solve the problem of racing writeback and DMA direct to the page we
> are doing IO on. Yes, it reduces the race window substantially, but
> it doesn't get rid of it.

So the event flow is:
    - userspace create object that match a range of virtual address
      against a given kernel sub-system (let's say infiniband) and
      let's assume that the range is an mmap() of a regular file
    - device driver do GUP on the range (let's assume it is a write
      GUP) so if the page is not already map with write permission
      in the page table than a page fault is trigger and page_mkwrite
      happens
    - Once GUP return the page to the device driver and once the
      device driver as updated the hardware states to allow access
      to this page then from that point on hardware can write to the
      page at _any_ time, it is fully disconnected from any fs event
      like write back, it fully ignore things like page_mkclean

This is how it is to day, we allowed people to push upstream such
users of GUP. This is a fact we have to live with, we can not stop
hardware access to the page, we can not force the hardware to follow
page_mkclean and force a page_mkwrite once write back ends. This is
the situation we are inheriting (and i am personnaly not happy with
that).

>From my point of view we are left with 2 choices:
    [C1] break all drivers that do not abide by the page_mkclean and
         page_mkwrite
    [C2] mitigate as much as possible the issue

For [C2] the idea is to keep track of GUP per page so we know if we
can expect the page to be written to at any time. Here is the event
flow:
    - driver GUP the page and program the hardware, page is mark as
      GUPed
    ...
    - write back kicks in on the dirty page, lock the page and every
      thing as usual , sees it is GUPed and inform the block layer to
      use a bounce page
    - block layer copy the page to a bounce page effectively creating
      a snapshot of what is the content of the real page. This allows
      everything in block layer that need stable content to work on
      the bounce page (raid, stripping, encryption, ...)
    - once write back is done the page is not marked clean but stays
      dirty, this effectively disable things like COW for filesystem
      and other feature that expect page_mkwrite between write back.
      AFAIK it is believe that it is something acceptable

The whole write back sequence will repeat until all GUP users calls
put_user_page, once the page is no longer pin by any GUP then things
resume back to the normal flow ie next write back will mark the page
clean and it will force a page_mkwrite on next write fault.



> 
> /me points to wait_for_stable_page() in ->page_mkwrite as the
> mechanism we already have to avoid races between dirtying mapped
> pages and page writeback....

Saddly some devices can not abide by that rules. They over interpreted
what GUP means and what are its guarantee.


> > > > For [O2] i believe we can handle that case in the put_user_page()
> > > > function to properly dirty the page without causing filesystem
> > > > freak out.
> > > 
> > > I'm pretty sure you can't call ->page_mkwrite() from
> > > put_user_page(), so I don't think this is workable at all.
> > 
> > Yes, calling ->page_mkwrite() in put_user_page() is not only technically
> > complicated but also too late - DMA has already modified page contents.
> > What we planned to do (again discussed back in October) was to never allow
> > the pinned page to become clean. I.e., clear_page_dirty_for_io() would
> > leave pinned pages dirty. Also we would skip pinned pages for WB_SYNC_NONE
> > writeback as there's no point in that really. That way MM and filesystems
> > would be aware of the real page state - i.e., what's in memory is not in
> > sync (potentially) with what's on disk. I was thinking whether this
> > permanently-dirty state couldn't confuse filesystem in some way but I
> > didn't find anything serious - the worst I could think of are places that
> > do filemap_write_and_wait() and then invalidate page cache e.g. before hole
> > punching or extent shifting.
> 
> If it's permanently dirty, how do we trigger new COW operations
> after writeback has "cleaned" the page? i.e. we still need a
> ->page_mkwrite call to run before we allow the next write to the
> page to be done, regardless of whether the page is "permanently
> dirty" or not....

For as long as they are GUP reference on the page we are effectively
in some way disabling page cleaning ie we still write back content so
that data loss is still unlikely but pages stays dirty and it disables
anything that rely on page_mkwrite including COW.

>From fs point of view it is as if page is frozen in being dirty and
under write for undefined period of time. We only mitigate the data
loss by allowing write to happen using a bounce page (so that layer
down the stack get a page with stable content ie a snapshot).

In other word we can not block the device from writing to the page,
some hardware are just not capable of that and saddly we allowed GUP
to be use for those.


> > But these should work fine as is (page cache
> > invalidation will just happily truncate dirty pages). DIO might get
> > confused by the inability to invalidate dirty pages but then user combining
> > RDMA with DIO on the same file at one moment gets what he deserves...
> 
> I'm almost certain this will do something that will occur. i.e.
> permanently mapped RDMA file, filesystem backup program uses DIO....

DIO being software i believe it can be told to understand this special
case.

Cheers,
J�r�me
