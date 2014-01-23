Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2A96B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 15:34:54 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so646211bkg.33
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 12:34:53 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id dg6si158516bkc.330.2014.01.23.12.34.51
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 12:34:52 -0800 (PST)
Date: Fri, 24 Jan 2014 07:34:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123203447.GT13997@dastard>
References: <20140122143452.GW4963@suse.de>
 <52DFDCA6.1050204@redhat.com>
 <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <20140123082734.GP13997@dastard>
 <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com>
 <20140123164438.GL4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123164438.GL4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Chris Mason <clm@fb.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Thu, Jan 23, 2014 at 04:44:38PM +0000, Mel Gorman wrote:
> On Thu, Jan 23, 2014 at 07:47:53AM -0800, James Bottomley wrote:
> > On Thu, 2014-01-23 at 19:27 +1100, Dave Chinner wrote:
> > > On Wed, Jan 22, 2014 at 10:13:59AM -0800, James Bottomley wrote:
> > > > On Wed, 2014-01-22 at 18:02 +0000, Chris Mason wrote:
> > > > > > The other question is if the drive does RMW between 4k and whatever its
> > > > > > physical sector size, do we need to do anything to take advantage of
> > > > > > it ... as in what would altering the granularity of the page cache buy
> > > > > > us?
> > > > > 
> > > > > The real benefit is when and how the reads get scheduled.  We're able to
> > > > > do a much better job pipelining the reads, controlling our caches and
> > > > > reducing write latency by having the reads done up in the OS instead of
> > > > > the drive.
> > > > 
> > > > I agree with all of that, but my question is still can we do this by
> > > > propagating alignment and chunk size information (i.e. the physical
> > > > sector size) like we do today.  If the FS knows the optimal I/O patterns
> > > > and tries to follow them, the odd cockup won't impact performance
> > > > dramatically.  The real question is can the FS make use of this layout
> > > > information *without* changing the page cache granularity?  Only if you
> > > > answer me "no" to this do I think we need to worry about changing page
> > > > cache granularity.
> > > 
> > > We already do this today.
> > > 
> > > The problem is that we are limited by the page cache assumption that
> > > the block device/filesystem never need to manage multiple pages as
> > > an atomic unit of change. Hence we can't use the generic
> > > infrastructure as it stands to handle block/sector sizes larger than
> > > a page size...
> > 
> > If the compound page infrastructure exists today and is usable for this,
> > what else do we need to do? ... because if it's a couple of trivial
> > changes and a few minor patches to filesystems to take advantage of it,
> > we might as well do it anyway. 
> 
> Do not do this as there is no guarantee that a compound allocation will
> succeed. If the allocation fails then it is potentially unrecoverable
> because we can no longer write to storage then you're hosed.  If you are
> now thinking mempool then the problem becomes that the system will be
> in a state of degraded performance for an unknowable length of time and
> may never recover fully.

We are talking about page cache allocation here, not something deep
down inside the IO path that requires mempools to guarantee IO
completion. IOWs, we have an *existing error path* to return ENOMEM
to userspace when page cache allocation fails.

> 64K MMU page size systems get away with this
> because the blocksize is still <= PAGE_SIZE and no core VM changes are
> necessary. Critically, pages like the page table pages are the same size as
> the basic unit of allocation used by the kernel so external fragmentation
> simply is not a severe problem.

Christoph's old patches didn't need 64k MMU page sizes to work.
IIRC, the compound page was mapped via into the page cache as
individual 4k pages. Any change of state on the child pages followed
the back pointer to the head of the compound page and changed the
state of that page. On page faults, the individual 4k pages were
mapped to userspace rather than the compound page, so there was no
userspace visible change, either.

The question I had at the time that was never answered was this: if
pages are faulted and mapped individually through their own ptes,
why did the compound pages need to be contiguous? copy-in/out
through read/write was still done a PAGE_SIZE granularity, mmap
mappings were still on PAGE_SIZE granularity, so why can't we build
a compound page for the page cache out of discontiguous pages?

FWIW, XFS has long used discontiguous pages for large block support
in metadata. Some of that is vmapped to make metadata processing
simple. The point of this is that we don't need *contiguous*
compound pages in the page cache if we can map them into userspace
as individual PAGE_SIZE pages. Only the page cache management needs
to handle the groups of pages that make up a filesystem block
as a compound page....

> > I was only objecting on the grounds that
> > the last time we looked at it, it was major VM surgery.  Can someone
> > give a summary of how far we are away from being able to do this with
> > the VM system today and what extra work is needed (and how big is this
> > piece of work)?
> > 
> 
> Offhand no idea. For fsblock, probably a similar amount of work than
> had to be done in 2007 and I'd expect it would still require filesystem
> awareness problems that Dave Chinner pointer out earlier. For large block,
> it'd hit into the same wall that allocations must always succeed. If we
> want to break the connection between the basic unit of memory managed
> by the kernel and the MMU page size then I don't know but it would be a
> fairly large amount of surgery and need a lot of design work.

Here's the patch that Christoph wrote backin 2007 to add PAGE_SIZE
based mmap support:

http://thread.gmane.org/gmane.linux.file-systems/18004

I don't claim to understand all of it, but it seems to me that most
of the design and implementation problems were solved....

.....

> At the very
> least there would be a performance impact because PAGE_SIZE is no longer a
> compile-time constant.

Christoph's patchset did this, and no discernable performance
difference could be measured as a result of making PAGE_SIZE a
variable rather than a compile time constant. I doubt that this has
changed much since then...

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
