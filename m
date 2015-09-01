Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8788A6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 18:21:38 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so9248037pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:21:38 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ry10si19117399pac.11.2015.09.01.15.21.36
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 15:21:37 -0700 (PDT)
Date: Wed, 2 Sep 2015 08:21:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150901222120.GQ3902@dastard>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901070608.GA5482@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901070608.GA5482@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Tue, Sep 01, 2015 at 09:06:08AM +0200, Christoph Hellwig wrote:
> On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
> > On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> > > For DAX msync we just need to flush the given range using
> > > wb_cache_pmem(), which is now a public part of the PMEM API.
> > 
> > This is wrong, because it still leaves fsync() broken on dax.
> > 
> > Flushing dirty data to stable storage is the responsibility of the
> > writeback infrastructure, not the VMA/mm infrasrtucture. For non-dax
> > configurations, msync defers all that to vfs_fsync_range(), because
> > it has to be implemented there for fsync() to work.
> > 
> > Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> > the backing store allocations to stable storage, so there's not
> > getting around the fact msync is the wrong place to be flushing
> > DAX mappings to persistent storage.
> 
> DAX does call ->fsync before and after this patch.  And with all
> the recent fixes we take care to ensure data is written though the
> cache for everything but mmap-access.  With this patch from Ross
> we ensure msync writes back the cache before calling ->fsync so that
> the filesystem can then do it's work like converting unwritten extents.
> 
> The only downside is that previously on Linux you could always use
> fsync as a replaement for msymc, which isn't true anymore for DAX.

Which means applications that should "just work" without
modification on DAX are now subtly broken and don't actually
guarantee data is safe after a crash. That's a pretty nasty
landmine, and goes against *everything* we've claimed about using
DAX with existing applications.

That's wrong, and needs fixing.

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
