Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B01106B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:40:11 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id c10so40752049pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:40:11 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id r83si14844581pfb.124.2016.02.25.13.40.10
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 13:40:10 -0800 (PST)
Date: Fri, 26 Feb 2016 08:39:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160225213919.GC30721@dastard>
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
 <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
 <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
 <20160225201517.GA30721@dastard>
 <56CF6D4C.1020101@inphi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CF6D4C.1020101@inphi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Terry <pterry@inphi.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 25, 2016 at 01:08:28PM -0800, Phil Terry wrote:
> On 02/25/2016 12:15 PM, Dave Chinner wrote:
> >On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
> >>Jeff Moyer <jmoyer@redhat.com> writes:
> >>
> >>>>The big issue we have right now is that we haven't made the DAX/pmem
> >>>>infrastructure work correctly and reliably for general use.  Hence
> >>>>adding new APIs to workaround cases where we haven't yet provided
> >>>>correct behaviour, let alone optimised for performance is, quite
> >>>>frankly, a clear case premature optimisation.
> >>>Again, I see the two things as separate issues.  You need both.
> >>>Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
> >>>issue of making existing applications work safely.
> >>I want to add one more thing to this discussion, just for the sake of
> >>clarity.  When I talk about existing applications and pmem, I mean
> >>applications that already know how to detect and recover from torn
> >>sectors.  Any application that assumes hardware does not tear sectors
> >>should be run on a file system layered on top of the btt.
> >Which turns off DAX, and hence makes this a moot discussion because
> >mmap is then buffered through the page cache and hence applications
> >*must use msync/fsync* to provide data integrity. Which also makes
> >them safe to use with DAX if we have a working fsync.
> >
> >Keep in mind that existing storage technologies tear fileystem data
> >writes, too, because user data writes are filesystem block sized and
> >not atomic at the device level (i.e.  typical is 512 byte sector, 4k
> >filesystem block size, so there are 7 points in a single write where
> >a tear can occur on a crash).
> Is that really true? Storage to date is on the PCIE/SATA etc IO
> chain. The locks and application crash scenarios when traversing
> down this chain are such that the device will not have its DMA
> programmed until the whole 4K etc page is flushed to memory, pinned

Has nothing to do with DMA semantics. Storage devices we have to
deal with have volatile write caches, and we can't assume anything
about what they write when power fails except that single sector
writes are atomic.

> In both cases, btt is not indirecting the buffer (as for a DMA
> master IO type device) but is simply using the same pmem api
> primitives to manage its own meta data about the filesystem writes
> to detect and recover from tears after the event. In what sense is
> DAX disabled for this?

BTT is, IIRC, using writeahead logging to stage every IO into pmem
so that after a crash the entire write can be recovered and replayed
to overwrite any torn sectors. This requires buffering at page cache
level, as direct writes to the pmem will not get logged. Hence DAX
cannot be used on BTT devices. Indeed:

static const struct block_device_operations btt_fops = {
        .owner =                THIS_MODULE,
        .rw_page =              btt_rw_page,
        .getgeo =               btt_getgeo,
        .revalidate_disk =      nvdimm_revalidate_disk,
};

There's no .direct_access method implemented for btt devices, so
it's clear that filesystems on BTT devices cannot enable DAX.

> So I think (please correct me if I'm wrong) but actually the
> hardware/firmware guys have been fixing the torn sector problem for

I was not talking about torn /sectors/. I was talking about a user
data write being made up of *multiple sectors*, and so there is no
atomicity guarantee for a user data write on existing storage when
the filesystem block size (user data IO size) is larger than the
device sector size. 

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
