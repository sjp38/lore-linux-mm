Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6886B0005
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 18:03:55 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x188so44311450pfb.2
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 15:03:55 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id p77si24130808pfj.241.2016.03.06.15.03.53
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 15:03:54 -0800 (PST)
Date: Mon, 7 Mar 2016 10:03:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160306230336.GE11282@dastard>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
 <56D9C882.3040808@intel.com>
 <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
 <20160304230548.GC11282@dastard>
 <20160304232412.GC12498@node.shutemov.name>
 <20160305223811.GD11282@dastard>
 <20160306003034.GA13704@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160306003034.GA13704@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 06, 2016 at 03:30:34AM +0300, Kirill A. Shutemov wrote:
> On Sun, Mar 06, 2016 at 09:38:11AM +1100, Dave Chinner wrote:
> > On Sat, Mar 05, 2016 at 02:24:12AM +0300, Kirill A. Shutemov wrote:
> > > Would it be acceptable for fallocate(FALLOC_FL_PUNCH_HOLE) to return
> > > -EBUSY (or other errno on your choice), if we cannot split the page
> > > right away?
> > 
> > Which means THP are not transparent any more. What does an
> > application do when it gets an EBUSY, anyway?
> 
> I guess it's reasonable to expect from an application to handle EOPNOTSUPP
> as FALLOC_FL_PUNCH_HOLE is not supported by some filesystems.

Yes, but this is usually done as a check at the program
initialisation to determine whether to issue hole punches at all.
It's not suppose to be a dynamic error.

> Although, non-consistent result from the same fd can be confusing.

Exactly.

> > And it's not just hole punching that has this problem. Direct IO is
> > going to have the same issue with invalidation of the mapped ranges
> > over the IO being done. XFS already WARNs when page cache
> > invalidation fails with EBUSY in direct IO, because that is
> > indicative of an application with a potential data corruption vector
> > and there's nothing we can do in the kernel code to prevent it.
> 
> My current understanding is that for filesystems with persistent storage,
> in order to make THP any useful, we would need to implement writeback
> without splitting the huge page.

Algorithmically it is no different to filesytem block size < page
size writeback.

> At the moment, I have no idea how hard it would be..

THP support would effectively require us to remove PAGE_CACHE_SIZE
assumptions from all of the filesystem and buffer code. That's a
large chunk of work e.g.  fs/buffer.c and any filesystem that uses
bufferheads for tracking filesystem block state through the page
cache.

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
