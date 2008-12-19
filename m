Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 10EDD6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 03:51:46 -0500 (EST)
Date: Fri, 19 Dec 2008 09:53:50 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] unlock_page speedup
Message-ID: <20081219085350.GF26419@wotan.suse.de>
References: <20081219072909.GC26419@wotan.suse.de> <20081218233549.cb451bc8.akpm@linux-foundation.org> <20081219075328.GD26419@wotan.suse.de> <20081218235957.d657b7ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081218235957.d657b7ac.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 18, 2008 at 11:59:57PM -0800, Andrew Morton wrote:
> On Fri, 19 Dec 2008 08:53:28 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Thu, Dec 18, 2008 at 11:35:49PM -0800, Andrew Morton wrote:
> > > On Fri, 19 Dec 2008 08:29:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > > Introduce a new page flag, PG_waiters
> > > 
> > > Leaving how many?
> > 
> > Don't know...
> 
> Need to know!  page.flags is prime real estate and we should decide
> whether gaining 2% in a particular microbenchmark is our best use of it

OK, good question. Honest answer is I don't really know. all
the different archs and memory models.. it's not something
I can exactly work out at a glance.

Keep in mind that it is page lock. We unlock it for every
file backed fault, COW fault, every truncate or invalidate,
every pagecache IO, write(2) etc etc. So the gain is not huge,
but it is definitely a common workload.

On powerpc the gain is much larger, because smp_mb__after_clear_bit
is really heavyweight in comparison to the lock release ordering.
Same would apply to ia64.

 
> > I thought the page-flags.h obfuscation project was
> > supposed to make that clearer to work out. There are what, 21 flags
> > used now. If everything is coded properly, then the memory model
> > should automatically kick its metadata out of page flags if it gets
> > too big.
> 
> That would be nice :)
> 
> > But most likely it will just blow up.
> 
> If we use them all _now_, as I proposed, we'll find out about that.

Well but it would push out the memory model metadata out of line
sooner (on smaller configs) which is undesirable.

But I think any extra page flags are always a bad thing, whether
or not we've reached the limit. Conceptually it is still using
a resource, even if not in reality.

But one nice thing about this flag is that it's simple to drop if we
ever need to reclaim it. Unlike "feature" features, that can never
be dropped and must always be maintained...


> > Probably we want
> > at least a few flags for memory model on 32-bit for smaller systems
> > (big NUMA 32-bit systems probably don't matter much anymore).
> > 
> > 
> > >  fs-cache wants to take two more.
> > 
> > fs-cache is getting merged?
> 
> See thread titled "Pull request for FS-Cache, including NFS patches"

Oh, ok thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
