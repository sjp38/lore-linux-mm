Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E34308E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:33:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so12004951edb.22
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:33:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f7-v6si1371740ejl.226.2018.12.18.02.33.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 02:33:09 -0800 (PST)
Date: Tue, 18 Dec 2018 11:33:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181218103306.GC18032@quack2.suse.cz>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181216215819.GC10644@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon 17-12-18 08:58:19, Dave Chinner wrote:
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

The scenario you describe here cannot happen exactly because of the
wait_for_stable_page() in ->page_mkwrite() you mention below. If someone
will try to GUP a page that is under writeback (has already PageWriteback
set), GUP will have to do a write fault because the page is writeprotected
in page tables and go into ->page_mkwrite() which will wait.

The problem rather is with someone mapping the page *before* writeback
starts, giving the page to HW. Then clear_page_dirty_for_io() writeprotects
the page in PTEs but the HW gives a damn about that. Then, after we add the
page to the bio but before the page gets bounced by the block layer, the HW
can still modify it.

So for anything in the block layer and below, doing the bouncing in the
block layer is enough. So DIF/DIX will work, device mapper targets will
work etc.  But you are right that if the filesystem itself needs stable
data, then bouncing in the block layer is not enough. Thanks for catching
this hole, I didn't think of that. Ext4 does not need stable data during
writeback, btrfs probably does as it needs to compute data checksums during
writeout. So we'll probably need something like clear_page_dirty_for_io()
returning a bounced page for data integrity writeback of a pinned page. And
the filesystem would then need to submit this page for IO.

> /me points to wait_for_stable_page() in ->page_mkwrite as the
> mechanism we already have to avoid races between dirtying mapped
> pages and page writeback....

Yes, the problem is that some RDMA hardware does not (and AFAIU cannot be
made to) follow the wait_for_stable_page() rules. And we have a userspace
visible API by which application can ask the kernel to give mapped file
pages to the HW as a buffer and the HW can fill in the contents at its will
until userspace tells the kernel to remove these mapped pages from the HW.
The interval how long userspace leaves these pages to the HW is upto
userspace and in practice it is often counted in hours.

If you want to tell me this is broken and could always corrupt data and
kill the kernel and what not, I agree. The goal is to avoid at least the
worst issues without breaking userspace too badly.

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

Interaction with COW is certainly an interesting problem. When the page
gets pinned, GUP will make sure the page is writeably mapped and trigger a
write fault if not. So at the moment the page is pinned, we are sure the
page is COWed. Now the question is what should happen when the file A
containing this pinned page gets reflinked to file B while the page is still
pinned.

Options I can see are:

1) Fail the reflink.
  - difficult for sysadmin to discover the source of failure

2) Block reflink until the pin of the page is released.
  - can last for a long time, again difficult to discover

3) Don't do anything special.
  - can corrupt data as read accesses through file B won't see
    modifications done to the page (and thus eventually the corresponding disk
    block) by the HW.

4) Immediately COW the block during reflink when the corresponding page
   cache page is pinned.
  - seems as the best solution at this point, although sadly also requires
    the most per-filesystem work

> > But these should work fine as is (page cache
> > invalidation will just happily truncate dirty pages). DIO might get
> > confused by the inability to invalidate dirty pages but then user combining
> > RDMA with DIO on the same file at one moment gets what he deserves...
> 
> I'm almost certain this will do something that will occur. i.e.
> permanently mapped RDMA file, filesystem backup program uses DIO....

IMO this falls into the same cathegory like two independent processes doing
DIO overwrite of the same file block. Or combining mmap and DIO access.
Kernel must not crash, filesystem must stay consistent, but the user is
responsible to put together bits of the data that are left...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
