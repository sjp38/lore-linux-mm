Date: Tue, 3 Apr 2007 15:44:19 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [xfs-masters] Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
Message-ID: <20070403054419.GV32597093@melbourne.sgi.com>
References: <1175571885.12230.473.camel@localhost.localdomain> <20070402205825.12190e52.akpm@linux-foundation.org> <1175575503.12230.484.camel@localhost.localdomain> <20070402215702.6e3782a9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070402215702.6e3782a9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xfs-masters@oss.sgi.com
Cc: Rusty Russell <rusty@rustcorp.com.au>, lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 02, 2007 at 09:57:02PM -0700, Andrew Morton wrote:
> On Tue, 03 Apr 2007 14:45:02 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > On Mon, 2007-04-02 at 20:58 -0700, Andrew Morton wrote:
> > > On Tue, 03 Apr 2007 13:44:45 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> > > 
> > > > 
> > > > I can never remember what the function to register to receive VM pressure
> > > > is called.  I have to trace down from __alloc_pages() to find it.
> > > > 
> > > > It's called "set_shrinker()", and it needs Your Help.
> > > > 
> > > > New version:
> > > > 1) Don't hide struct shrinker.  It contains no magic.
> > > > 2) Don't allocate "struct shrinker".  It's not helpful.
> > > > 3) Call them "register_shrinker" and "unregister_shrinker".
> > > > 4) Call the function "shrink" not "shrinker".
> > > > 5) Rename "nr_to_scan" argument to "nr_to_free".
> > > 
> > > No, it is actually the number to scan.  This is >= the number of freed
> > > objects.
> > > 
> > > This is because, for better of for worse, the VM tries to balance the
> > > scanning rate of the various caches, not the reclaiming rate.
> > 
> > Err, ok, I completely missed that distinction.
> > 
> > Does that mean the to function correctly every user needs some internal
> > cursor so it doesn't end up scanning the first N entries over and over?
> > 
> 
> If it wants to be well-behaved, and to behave as the VM expects, yes. 
> 
> There's an expectation that the callback will be performing some scan-based
> aging operation and of course to do LRU (or whatever) aging, the callback
> will need to remember where it was up to last time it was called.
> 
> But it's just a guideline - callbacks could do something different but
> in-the-spirit, I guess.

In XFS, one of the shrinkers cwthat gets registered calls causes all
the xfsbufd's in the system to run and write back delayed write
metadata - this can't be freed up until it is clean, and this is the
only hook we have that can be used to trigger writeback on memory
pressure. We need this because we can potentially have hundreds of
megabytes of dirty metadata per XFS filesystem.

IOW, the way the VM expects the shrinkers to work can be far, far
away from what subsystems need the shrinker callbacks for....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
