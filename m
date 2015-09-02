Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 14E696B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 01:17:29 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so19961064pad.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 22:17:28 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id pj2si33520589pbc.180.2015.09.01.22.17.26
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 22:17:27 -0700 (PDT)
Date: Wed, 2 Sep 2015 15:17:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902051711.GS3902@dastard>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901070608.GA5482@lst.de>
 <20150901222120.GQ3902@dastard>
 <20150902031945.GA8916@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150902031945.GA8916@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Tue, Sep 01, 2015 at 09:19:45PM -0600, Ross Zwisler wrote:
> On Wed, Sep 02, 2015 at 08:21:20AM +1000, Dave Chinner wrote:
> > Which means applications that should "just work" without
> > modification on DAX are now subtly broken and don't actually
> > guarantee data is safe after a crash. That's a pretty nasty
> > landmine, and goes against *everything* we've claimed about using
> > DAX with existing applications.
> > 
> > That's wrong, and needs fixing.
> 
> I agree that we need to fix fsync as well, and that the fsync solution could
> be used to implement msync if we choose to go that route.  I think we might
> want to consider keeping the msync and fsync implementations separate, though,
> for two reasons.
> 
> 1) The current msync implementation is much more efficient than what will be
> needed for fsync.  Fsync will need to call into the filesystem, traverse all
> the blocks, get kernel virtual addresses from those and then call
> wb_cache_pmem() on those kernel addresses.  I think this is a necessary evil
> for fsync since you don't have a VMA, but for msync we do and we can just
> flush using the user addresses without any fs lookups.

Yet you're ignoring the fact that flushing the entire range of the
relevant VMAs may not be very efficient. It may be a very
large mapping with only a few pages that need flushing from the
cache, but you still iterate the mappings flushing GB ranges from
the cache at a time.

We don't need struct pages to track page dirty state. We already
have a method for doing this that does not rely on having a struct
page and can be used for efficient lookup of exact dirty ranges. i.e
the per-page dirty tag that is kept in the mapping radix tree. It's
fine grained, and extremely efficient in terms of lookups to find
dirty pages.

Indeed, the mapping tree tags were specifically designed to avoid
this "fsync doesn't know what range to flush" problem for normal
files. That same problem still exists here for msync - these patches
are just hitting it with a goddamn massive hammer "because it is
easy" rather than attempting to do the flushing efficiently.

> 2) I believe that the near-term fsync code will rely on struct pages for
> PMEM, which I believe are possible but optional as of Dan's last patch set:
> 
> https://lkml.org/lkml/2015/8/25/841
> 
> I believe that this means that if we don't have struct pages for PMEM (becuase
> ZONE_DEVICE et al. are turned off) fsync won't work.  I'd be nice not to lose
> msync as well.

I don't think this is an either-or situation. If we use struct pages
for PMEM, then fsync will work without modification as DAX will need
to use struct pages and hence we can insert them in the mapping
radix tree directly and use the normal set/clear_page_dirty() calls
to track dirty state. It will give us fine grained flush capability
and we won't want msync() to be using the big hammer if we can avoid
it.

If we make the existing pfn-based DAX code track dirty pages via
mapping radix tree tags right now, then we allow fsync to work by
reusing most of the infrastructure we already have.  That means DAX
and fsync will work exactly the same regardless of how we
index/reference PMEM in future and we won't have to come back and
fix it all up again.

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
