Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BF52B6B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 18:05:52 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 124so43088071pfg.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 15:05:52 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id bx6si8654136pad.6.2016.03.04.15.05.51
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 15:05:52 -0800 (PST)
Date: Sat, 5 Mar 2016 10:05:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160304230548.GC11282@dastard>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
 <56D9C882.3040808@intel.com>
 <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 04, 2016 at 11:38:47AM -0800, Hugh Dickins wrote:
> On Fri, 4 Mar 2016, Dave Hansen wrote:
> > On 03/04/2016 03:26 AM, Kirill A. Shutemov wrote:
> > > On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
> > >> Truncate and punch hole that only cover part of THP range is implemented
> > >> by zero out this part of THP.
> > >>
> > >> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> > >> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> > >> inconsistent results depending what pages happened to be allocated.
> > >> Not sure if it should be considered ABI break or not.
> > > 
> > > Looks like this shouldn't be a problem. man 2 fallocate:
> > > 
> > > 	Within the specified range, partial filesystem blocks are zeroed,
> > > 	and whole filesystem blocks are removed from the file.  After a
> > > 	successful call, subsequent reads from this range will return
> > > 	zeroes.
> > > 
> > > It means we effectively have 2M filesystem block size.
> > 
> > The question is still whether this will case problems for apps.
> > 
> > Isn't 2MB a quote unusual block size?  Wouldn't some files on a tmpfs
> > filesystem act like they have a 2M blocksize and others like they have
> > 4k?  Would that confuse apps?
> 
> At risk of addressing the tip of an iceberg, before diving down to
> scope out the rest of the iceberg...
....

> (Though in the case of my huge tmpfs, it's the reverse: the small hole
> punch splits the hugepage; but it's natural that Kirill's way would try
> to hold on to its compound pages for longer than I do, and that's fine
> so long as it's all consistent.)
....
> Ah, but suppose someone holepunches out most of each 2M page: they would
> expect the memcg not to be charged for those holes (just as when they
> munmap most of an anonymous THP) - that does suggest splitting is needed.

I think filesystems will expect splitting to happen. They call
truncate_pagecache_range() on the region that the hole is being
punched out of, and they expect page cache pages over this range to
be unmapped, invalidated and then removed from the mapping tree as a
result. Also, most filesystems think the page cache only contains
PAGE_CACHE_SIZE mappings, so they are completely unaware of the
limitations THP might have when it comes to invalidation.

IOWs, if this range is not aligned to huge page boundaries, then it
implies the huge page is either split into PAGE_SIZE mappings and
then the range is invalidated as expected, or it is completely
invalidated and then refaulted on future accesses which determine if
THP or normal pages are used for the page being faulted....

Just to complicate things, keep in mind that some filesystems may
have a PAGE_SIZE block size, but can be convinced to only
allocate/punch/truncate/etc extents on larger alignments on a
per-inode basis. IOWs, THP vs hole punch behaviour is not actually
a filesystem type specific behaviour - it's per-inode specific...

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
