From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 03/29] mm: slb: add knowledge of reserve pages
Date: Sat, 15 Dec 2007 02:10:50 -0800
References: <20071214153907.770251000@chello.nl> <20071214154439.242195000@chello.nl> <200712141451.09500.phillips@phunq.net>
In-Reply-To: <200712141451.09500.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712150210.51049.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Friday 14 December 2007 14:51, I wrote:
> On Friday 14 December 2007 07:39, Peter Zijlstra wrote:
> Note that false sharing of slab pages is still possible between two
> unrelated writeout processes, both of which obey rules for their own
> writeout path, but the pinned combination does not.  This still
> leaves a hole through which a deadlock may slip.

Actually, no it doesn't.  It in fact does not matter how many unrelated 
writeout processes, block devices, whatevers share a slab cache.  
Sufficient reserve pages must have been made available (in a perfect 
work, by adding extra pages to the memalloc reserve on driver 
initialization, in the real world just by having a big memalloc 
reserve) to populate the slab up to the sum of the required objects for 
all memalloc users sharing the cache.

So I think this slab technique of yours is fundamentally sound, that is 
to say, adding a new per-slab flag to keep unbounded numbers of slab 
objects with unbounded lifetimes from mixing with the bounded number of 
slab objects with bounded lifetimes.

Ponder.  OK, here is another issue.  Suppose a driver expands the 
memalloc reserve by the X number of pages it needs on initialization, 
and shrinks it by the same amount on removal, as is right and proper.  
The problem is, less than the number of slab pages that got pulled into 
slab on behalf of the removed driver may be freed (or made freeable) 
back to the global reserve, due to page sharing with an unrelated user.   
In theory, the global reserve could be completely depleted by this slab 
fragmentation.

OK, that is like the case that I mistakenly raised in the previous mail, 
though far less likely to occur, because driver removals are relatively 
rare and so would be a fragmentation case so severe as to cause global 
reserve depletion.

Even so, if this possibility bothers anybody, it is fairly easy to plug 
the hole: associate each slab with a given memalloc user instead of 
just having one bit to classify users.  So unrelated memalloc users 
would never share a slab, no false sharing, everybody happy.  The cost: 
a new pointer field per slab and a few additional lines of code.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
