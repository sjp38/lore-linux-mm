Date: Wed, 16 May 2007 14:42:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179350433.2912.66.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705161435110.11642@schroedinger.engr.sgi.com>
References: <1179350433.2912.66.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Peter Zijlstra wrote:

> > Hmmm.. so we could simplify the scheme by storing the last rank 
> > somewheres.
> 
> Not sure how that would help..

One does not have a way of determining the current processes
priority? Just need to do an alloc?

If we had the current processes "rank" then we could simply compare.
If rank is okay give them the object. If not try to extend slab. If that
succeeds clear the rank. If extending fails fail the alloc. There would be 
no need for a reserve slab.

What worries me about this whole thing is


1. It is designed to fail an allocation rather than guarantee that all 
   succeed. Is it not possible to figure out which processes are not 
   essential and simply put them to sleep until the situation clear up?

2. It seems to be based on global ordering of allocations which is
   not possible given large systems and the relativistic constraints
   of physics. Ordering of events get more expensive the bigger the
   system is.

   How does this system work if you can just order events within
   a processor? Or within a node? Within a zone?

3. I do not see how this integrates with other allocation constraints:
   DMA constraints, cpuset constraints, memory node constraints,
   GFP_THISNODE, MEMALLOC, GFP_HIGH.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
