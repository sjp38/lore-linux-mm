Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E38A96B0005
	for <linux-mm@kvack.org>; Sat,  5 Mar 2016 17:38:16 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fl4so55521869pad.0
        for <linux-mm@kvack.org>; Sat, 05 Mar 2016 14:38:16 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id n81si10637988pfa.84.2016.03.05.14.38.15
        for <linux-mm@kvack.org>;
        Sat, 05 Mar 2016 14:38:16 -0800 (PST)
Date: Sun, 6 Mar 2016 09:38:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160305223811.GD11282@dastard>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
 <56D9C882.3040808@intel.com>
 <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
 <20160304230548.GC11282@dastard>
 <20160304232412.GC12498@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160304232412.GC12498@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 05, 2016 at 02:24:12AM +0300, Kirill A. Shutemov wrote:
> On Sat, Mar 05, 2016 at 10:05:48AM +1100, Dave Chinner wrote:
> > On Fri, Mar 04, 2016 at 11:38:47AM -0800, Hugh Dickins wrote:
> > > On Fri, 4 Mar 2016, Dave Hansen wrote:
> > > > On 03/04/2016 03:26 AM, Kirill A. Shutemov wrote:
> > > > > On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
> > > > >> Truncate and punch hole that only cover part of THP range is implemented
> > > > >> by zero out this part of THP.
> > > > >>
> > > > >> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> > > > >> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> > > > >> inconsistent results depending what pages happened to be allocated.
> > > > >> Not sure if it should be considered ABI break or not.
> > > > > 
> > > > > Looks like this shouldn't be a problem. man 2 fallocate:
> > > > > 
> > > > > 	Within the specified range, partial filesystem blocks are zeroed,
> > > > > 	and whole filesystem blocks are removed from the file.  After a
> > > > > 	successful call, subsequent reads from this range will return
> > > > > 	zeroes.
> > > > > 
> > > > > It means we effectively have 2M filesystem block size.
> > > > 
> > > > The question is still whether this will case problems for apps.
> > > > 
> > > > Isn't 2MB a quote unusual block size?  Wouldn't some files on a tmpfs
> > > > filesystem act like they have a 2M blocksize and others like they have
> > > > 4k?  Would that confuse apps?
> > > 
> > > At risk of addressing the tip of an iceberg, before diving down to
> > > scope out the rest of the iceberg...
> > ....
> > 
> > > (Though in the case of my huge tmpfs, it's the reverse: the small hole
> > > punch splits the hugepage; but it's natural that Kirill's way would try
> > > to hold on to its compound pages for longer than I do, and that's fine
> > > so long as it's all consistent.)
> > ....
> > > Ah, but suppose someone holepunches out most of each 2M page: they would
> > > expect the memcg not to be charged for those holes (just as when they
> > > munmap most of an anonymous THP) - that does suggest splitting is needed.
> > 
> > I think filesystems will expect splitting to happen. They call
> > truncate_pagecache_range() on the region that the hole is being
> > punched out of, and they expect page cache pages over this range to
> > be unmapped, invalidated and then removed from the mapping tree as a
> > result. Also, most filesystems think the page cache only contains
> > PAGE_CACHE_SIZE mappings, so they are completely unaware of the
> > limitations THP might have when it comes to invalidation.
> > 
> > IOWs, if this range is not aligned to huge page boundaries, then it
> > implies the huge page is either split into PAGE_SIZE mappings and
> > then the range is invalidated as expected, or it is completely
> > invalidated and then refaulted on future accesses which determine if
> > THP or normal pages are used for the page being faulted....
> 
> The filesystem in question is tmpfs and complete invalidation is not
> always an option.

Then your two options are: splitting the page and rerunning the hole
punch, or simply zeroing the sections of the THP rather than trying
to punch out the backing store.

> For other filesystems it also can be unavailable
> immediately if the page is dirty (the dirty flag is tracked on per-THP
> basis at the moment).

Filesystems with persistent storage flush the range being punched
first to ensure that partial blocks are correctly written before we
start freeing the backing store. This is needed on XFS to ensure
hole punch plays nicely with delayed allocation and other extent
based operations. Hence we know that we have clean pages over the
hole we are about to punch and so there is no reason the
invalidation should *ever* fail.

tmpfs is a special snowflake when it comes to these fallocate based
filesystem layout manipulation functions - it does not have
persistent storage, so you have to do things very differently to
ensure that data is not lost.

> Would it be acceptable for fallocate(FALLOC_FL_PUNCH_HOLE) to return
> -EBUSY (or other errno on your choice), if we cannot split the page
> right away?

Which means THP are not transparent any more. What does an
application do when it gets an EBUSY, anyway? It needs to punch a
hole, and failure to do so could result in data corruption or stale
data exposure if the hole isn't punched and the data purged from the
range.

And it's not just hole punching that has this problem. Direct IO is
going to have the same issue with invalidation of the mapped ranges
over the IO being done. XFS already WARNs when page cache
invalidation fails with EBUSY in direct IO, because that is
indicative of an application with a potential data corruption vector
and there's nothing we can do in the kernel code to prevent it.

I think the same issues also exist with DAX using huge (and giant)
pages. Hence it seems like we need to think about these interactions
carefully, because they will no longer are isolated to tmpfs and
THP...

> > Just to complicate things, keep in mind that some filesystems may
> > have a PAGE_SIZE block size, but can be convinced to only
> > allocate/punch/truncate/etc extents on larger alignments on a
> > per-inode basis. IOWs, THP vs hole punch behaviour is not actually
> > a filesystem type specific behaviour - it's per-inode specific...
> 
> There is also similar question about THP vs. i_size vs. SIGBUS.
> 
> For small pages an application will not get SIGBUS on mmap()ed file, until
> it wouldn't try to access beyond round_up(i_size, PAGE_CACHE_SIZE) - 1.
> 
> For THP it would be round_up(i_size, HPAGE_PMD_SIZE) - 1.
> 
> Is it a problem?

No idea. I'm guessing that there may be significant stale data
exposure issues here as filesystems do not guarantee that blocks
completely beyond EOF contain zeros.

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
