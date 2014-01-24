Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 42B156B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 05:57:55 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id q59so2450374wes.39
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:57:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hy4si314866wjb.102.2014.01.24.02.57.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 02:57:54 -0800 (PST)
Date: Fri, 24 Jan 2014 10:57:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140124105748.GQ4963@suse.de>
References: <52DFDCA6.1050204@redhat.com>
 <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <20140123082734.GP13997@dastard>
 <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com>
 <20140123164438.GL4963@suse.de>
 <1390506935.2402.8.camel@dabdike>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390506935.2402.8.camel@dabdike>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Thu, Jan 23, 2014 at 11:55:35AM -0800, James Bottomley wrote:
> > > > > > <SNIP>
> > > > > > The real benefit is when and how the reads get scheduled.  We're able to
> > > > > > do a much better job pipelining the reads, controlling our caches and
> > > > > > reducing write latency by having the reads done up in the OS instead of
> > > > > > the drive.
> > > > > 
> > > > > I agree with all of that, but my question is still can we do this by
> > > > > propagating alignment and chunk size information (i.e. the physical
> > > > > sector size) like we do today.  If the FS knows the optimal I/O patterns
> > > > > and tries to follow them, the odd cockup won't impact performance
> > > > > dramatically.  The real question is can the FS make use of this layout
> > > > > information *without* changing the page cache granularity?  Only if you
> > > > > answer me "no" to this do I think we need to worry about changing page
> > > > > cache granularity.
> > > > 
> > > > We already do this today.
> > > > 
> > > > The problem is that we are limited by the page cache assumption that
> > > > the block device/filesystem never need to manage multiple pages as
> > > > an atomic unit of change. Hence we can't use the generic
> > > > infrastructure as it stands to handle block/sector sizes larger than
> > > > a page size...
> > > 
> > > If the compound page infrastructure exists today and is usable for this,
> > > what else do we need to do? ... because if it's a couple of trivial
> > > changes and a few minor patches to filesystems to take advantage of it,
> > > we might as well do it anyway. 
> > 
> > Do not do this as there is no guarantee that a compound allocation will
> > succeed.
> 
> I presume this is because in the current implementation compound pages
> have to be physically contiguous.

Well.... yes. In VM terms, a compound page is a high-order physically
contiguous page that has additional metadata and a destructor. A potentially
discontiguous buffer would need a different structure and always be accessed
with base-page-sized iterators.

> For increasing granularity in the
> page cache, we don't necessarily need this ... however, getting write
> out to work properly without physically contiguous pages would be a bit
> more challenging (but not impossible) to solve.
> 

Every filesystem would have to be aware of this potentially discontiguous
buffer. I do not know what the mechanics of fsblock were but I bet it
had to handle some sort of multiple page read/write when block size was
bigger than PAGE_SIZE.

> >  If the allocation fails then it is potentially unrecoverable
> > because we can no longer write to storage then you're hosed. If you are
> > now thinking mempool then the problem becomes that the system will be
> > in a state of degraded performance for an unknowable length of time and
> > may never recover fully. 64K MMU page size systems get away with this
> > because the blocksize is still <= PAGE_SIZE and no core VM changes are
> > necessary. Critically, pages like the page table pages are the same size as
> > the basic unit of allocation used by the kernel so external fragmentation
> > simply is not a severe problem.
> 
> Right, I understand this ... but we still need to wonder about what it
> would take.

So far on the table is

1. major filesystem overhawl
2. major vm overhawl
3. use compound pages as they are today and hope it does not go
   completely to hell, reboot when it does

>  Even the simple fail a compound page allocation gets
> treated in the kernel the same way as failing a single page allocation
> in the page cache.
> 

The percentages of failures are the problem here. If an order-0 allocation
fails then any number of actions the kernel takes will result in a free
page that can be used to satisfy the allocation. At worst, OOM killing a
process is guaranteed to free up order-0 pages but the same is not true
for compaction. Anti-fragmentation and compaction make this very difficult
and they go a long way here but it is not a 100% guarantee a compound
allocation will succeed in the future or be a cheap allocation.

> > > I was only objecting on the grounds that
> > > the last time we looked at it, it was major VM surgery.  Can someone
> > > give a summary of how far we are away from being able to do this with
> > > the VM system today and what extra work is needed (and how big is this
> > > piece of work)?
> > > 
> > 
> > Offhand no idea. For fsblock, probably a similar amount of work than
> > had to be done in 2007 and I'd expect it would still require filesystem
> > awareness problems that Dave Chinner pointer out earlier. For large block,
> > it'd hit into the same wall that allocations must always succeed.
> 
> I don't understand this.  Why must they succeed?  4k page allocations
> don't have to succeed today in the page cache, so why would compound
> page allocations have to succeed?
> 

4K page allocations can temporarily fail but almost any reclaim action
with the exception of slab reclaim will result in 4K allocation requests
succeeding again. The same is not true of compound pages. An adverse workload
could potentially use page table pages (unreclaimable other than OOM kill)
to prevent compound allocations ever succeeding.

That's why I suggested that it may be necessary to change the basic unit of
allocation the kernel uses to be larger than the MMU page size and restrict
how the sub pages are used. The requirement is to preserve the property that
"with the exception of slab reclaim that any reclaim action will result
in K-sized allocation succeeding" where K is the largest blocksize used by
any underlying storage device. From an FS perspective then certain things
would look similar to what they do today. Block data would be on physically
contiguous pages, buffer_heads would still manage the case where block_size
<= PAGEALLOC_PAGE_SIZE (as opposed to MMU_PAGE_SIZE), particularly for
dirty tracking and so on. The VM perspective is different because now it
has to handle MMU_PAGE_SIZE in a very different way, page reclaim of a page
becomes multiple unmap events and so on. There would also be anomalies such
as mlock of a range smaller than PAGEALLOC_PAGE_SIZE becomes difficult if
not impossible to sensibly manage because mlock of a 4K page effectively
pins the rest and it's not obvious how we would deal with the VMAs in that
case. It would get more than just the storage gains though. Some of the
scalability problems that deal with massive amount of struct pages may
magically go away if the base unit of allocation and management changes.

> >  If we
> > want to break the connection between the basic unit of memory managed
> > by the kernel and the MMU page size then I don't know but it would be a
> > fairly large amount of surgery and need a lot of design work. Minimally,
> > anything dealing with an MMU-sized amount of memory would now need to
> > deal with sub-pages and there would need to be some restrictions on how
> > sub-pages were used to mitigate the risk of external fragmentation -- do not
> > mix page table page allocations with pages mapped into the address space,
> > do not allow sub pages to be used by different processes etc. At the very
> > least there would be a performance impact because PAGE_SIZE is no longer a
> > compile-time constant. However, it would potentially allow the block size
> > to be at least the same size as this new basic allocation unit.
> 
> Hm, OK, so less appealing then.
> 

Yes. On the plus side, you get the type of compound pages you want. On the
negative side this would be a massive overhawl of a large chunk of the VM
with lots of nasty details.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
