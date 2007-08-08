Date: Tue, 7 Aug 2007 20:44:36 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
Message-ID: <20070808014435.GG30556@waste.org>
References: <20070806102922.907530000@chello.nl> <20070806103658.603735000@chello.nl> <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 07, 2007 at 05:13:52PM -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Peter Zijlstra wrote:
> 
> > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > contexts that are entitled to it.
> 
> Is this patch actually necessary?
>
 > If you are in an atomic context and bound to a cpu then a per cpu slab is 
> assigned to you and no one else can take object aways from that process 
> since nothing else can run on the cpu.

Servicing I/O over the network requires an allocation to send a buffer
and an allocation to later receive the acknowledgement. We can't free
our send buffer (or the memory it's supposed to clean) until the
relevant ack is received. We have to hold our reserves privately
throughout, even if an interrupt that wants to do GFP_ATOMIC
allocation shows up in-between.

> If you are not in an atomic context and are preemptable or can switch 
> allocation context then you can create another context in which reclaim 
> could be run to remove some clean pages and get you more memory. Again no 
> need for the patch.

By the point that this patch is relevant, there are already no clean
pages. The only way to free up more memory is via I/O.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
