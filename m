Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD4A6B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 11:44:45 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id t60so1439999wes.37
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 08:44:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xm13si20488wib.36.2014.01.23.08.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 08:44:43 -0800 (PST)
Date: Thu, 23 Jan 2014 16:44:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123164438.GL4963@suse.de>
References: <52DFD168.8080001@redhat.com>
 <20140122143452.GW4963@suse.de>
 <52DFDCA6.1050204@redhat.com>
 <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <20140123082734.GP13997@dastard>
 <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390492073.2372.118.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <clm@fb.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Thu, Jan 23, 2014 at 07:47:53AM -0800, James Bottomley wrote:
> On Thu, 2014-01-23 at 19:27 +1100, Dave Chinner wrote:
> > On Wed, Jan 22, 2014 at 10:13:59AM -0800, James Bottomley wrote:
> > > On Wed, 2014-01-22 at 18:02 +0000, Chris Mason wrote:
> > > > On Wed, 2014-01-22 at 09:21 -0800, James Bottomley wrote:
> > > > > On Wed, 2014-01-22 at 17:02 +0000, Chris Mason wrote:
> > > > 
> > > > [ I like big sectors and I cannot lie ]
> > > 
> > > I think I might be sceptical, but I don't think that's showing in my
> > > concerns ...
> > > 
> > > > > > I really think that if we want to make progress on this one, we need
> > > > > > code and someone that owns it.  Nick's work was impressive, but it was
> > > > > > mostly there for getting rid of buffer heads.  If we have a device that
> > > > > > needs it and someone working to enable that device, we'll go forward
> > > > > > much faster.
> > > > > 
> > > > > Do we even need to do that (eliminate buffer heads)?  We cope with 4k
> > > > > sector only devices just fine today because the bh mechanisms now
> > > > > operate on top of the page cache and can do the RMW necessary to update
> > > > > a bh in the page cache itself which allows us to do only 4k chunked
> > > > > writes, so we could keep the bh system and just alter the granularity of
> > > > > the page cache.
> > > > > 
> > > > 
> > > > We're likely to have people mixing 4K drives and <fill in some other
> > > > size here> on the same box.  We could just go with the biggest size and
> > > > use the existing bh code for the sub-pagesized blocks, but I really
> > > > hesitate to change VM fundamentals for this.
> > > 
> > > If the page cache had a variable granularity per device, that would cope
> > > with this.  It's the variable granularity that's the VM problem.
> > > 
> > > > From a pure code point of view, it may be less work to change it once in
> > > > the VM.  But from an overall system impact point of view, it's a big
> > > > change in how the system behaves just for filesystem metadata.
> > > 
> > > Agreed, but only if we don't do RMW in the buffer cache ... which may be
> > > a good reason to keep it.
> > > 
> > > > > The other question is if the drive does RMW between 4k and whatever its
> > > > > physical sector size, do we need to do anything to take advantage of
> > > > > it ... as in what would altering the granularity of the page cache buy
> > > > > us?
> > > > 
> > > > The real benefit is when and how the reads get scheduled.  We're able to
> > > > do a much better job pipelining the reads, controlling our caches and
> > > > reducing write latency by having the reads done up in the OS instead of
> > > > the drive.
> > > 
> > > I agree with all of that, but my question is still can we do this by
> > > propagating alignment and chunk size information (i.e. the physical
> > > sector size) like we do today.  If the FS knows the optimal I/O patterns
> > > and tries to follow them, the odd cockup won't impact performance
> > > dramatically.  The real question is can the FS make use of this layout
> > > information *without* changing the page cache granularity?  Only if you
> > > answer me "no" to this do I think we need to worry about changing page
> > > cache granularity.
> > 
> > We already do this today.
> > 
> > The problem is that we are limited by the page cache assumption that
> > the block device/filesystem never need to manage multiple pages as
> > an atomic unit of change. Hence we can't use the generic
> > infrastructure as it stands to handle block/sector sizes larger than
> > a page size...
> 
> If the compound page infrastructure exists today and is usable for this,
> what else do we need to do? ... because if it's a couple of trivial
> changes and a few minor patches to filesystems to take advantage of it,
> we might as well do it anyway. 

Do not do this as there is no guarantee that a compound allocation will
succeed. If the allocation fails then it is potentially unrecoverable
because we can no longer write to storage then you're hosed. If you are
now thinking mempool then the problem becomes that the system will be
in a state of degraded performance for an unknowable length of time and
may never recover fully. 64K MMU page size systems get away with this
because the blocksize is still <= PAGE_SIZE and no core VM changes are
necessary. Critically, pages like the page table pages are the same size as
the basic unit of allocation used by the kernel so external fragmentation
simply is not a severe problem.

> I was only objecting on the grounds that
> the last time we looked at it, it was major VM surgery.  Can someone
> give a summary of how far we are away from being able to do this with
> the VM system today and what extra work is needed (and how big is this
> piece of work)?
> 

Offhand no idea. For fsblock, probably a similar amount of work than
had to be done in 2007 and I'd expect it would still require filesystem
awareness problems that Dave Chinner pointer out earlier. For large block,
it'd hit into the same wall that allocations must always succeed. If we
want to break the connection between the basic unit of memory managed
by the kernel and the MMU page size then I don't know but it would be a
fairly large amount of surgery and need a lot of design work. Minimally,
anything dealing with an MMU-sized amount of memory would now need to
deal with sub-pages and there would need to be some restrictions on how
sub-pages were used to mitigate the risk of external fragmentation -- do not
mix page table page allocations with pages mapped into the address space,
do not allow sub pages to be used by different processes etc. At the very
least there would be a performance impact because PAGE_SIZE is no longer a
compile-time constant. However, it would potentially allow the block size
to be at least the same size as this new basic allocation unit.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
