Date: Mon, 2 Apr 2007 21:57:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
Message-Id: <20070402215702.6e3782a9.akpm@linux-foundation.org>
In-Reply-To: <1175575503.12230.484.camel@localhost.localdomain>
References: <1175571885.12230.473.camel@localhost.localdomain>
	<20070402205825.12190e52.akpm@linux-foundation.org>
	<1175575503.12230.484.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Tue, 03 Apr 2007 14:45:02 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Mon, 2007-04-02 at 20:58 -0700, Andrew Morton wrote:
> > On Tue, 03 Apr 2007 13:44:45 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> > 
> > > 
> > > I can never remember what the function to register to receive VM pressure
> > > is called.  I have to trace down from __alloc_pages() to find it.
> > > 
> > > It's called "set_shrinker()", and it needs Your Help.
> > > 
> > > New version:
> > > 1) Don't hide struct shrinker.  It contains no magic.
> > > 2) Don't allocate "struct shrinker".  It's not helpful.
> > > 3) Call them "register_shrinker" and "unregister_shrinker".
> > > 4) Call the function "shrink" not "shrinker".
> > > 5) Rename "nr_to_scan" argument to "nr_to_free".
> > 
> > No, it is actually the number to scan.  This is >= the number of freed
> > objects.
> > 
> > This is because, for better of for worse, the VM tries to balance the
> > scanning rate of the various caches, not the reclaiming rate.
> 
> Err, ok, I completely missed that distinction.
> 
> Does that mean the to function correctly every user needs some internal
> cursor so it doesn't end up scanning the first N entries over and over?
> 

If it wants to be well-behaved, and to behave as the VM expects, yes. 

There's an expectation that the callback will be performing some scan-based
aging operation and of course to do LRU (or whatever) aging, the callback
will need to remember where it was up to last time it was called.

But it's just a guideline - callbacks could do something different but
in-the-spirit, I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
