Date: Thu, 13 Jan 2005 09:25:53 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0501130919470.2310@ppc970.osdl.org>
References: <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org>
 <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112104326.69b99298.akpm@osdl.org> <41E5AFE6.6000509@yahoo.com.au>
 <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au>
 <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
 <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
 <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>


On Thu, 13 Jan 2005, Christoph Lameter wrote:
>
> On Wed, 13 Jan 2005, Andi Kleen wrote:
> 
> > Alternatively you can use a lazy load, checking for changes.
> > (untested)
> >
> > pte_t read_pte(volatile pte_t *pte)
> > {
> > 	pte_t n;
> > 	do {
> > 		n.pte_low = pte->pte_low;
> > 		rmb();
> > 		n.pte_high = pte->pte_high;
> > 		rmb();
> > 	} while (n.pte_low != pte->pte_low);
> > 	return pte;
> > }
> >
> > No atomic operations, I bet it's actually faster than the cmpxchg8.
> > There is a small risk for livelock, but not much worse than with an
> > ordinary spinlock.
> 
> Hmm.... This may replace the get of a 64 bit value. But here could still
> be another process that is setting the pte in a non-atomic way.

There's a nice standard way of doing that, namely sequence numbers. 

However, most of the time it isn't actually faster than just getting the 
lock. There are two real costs in getting a lock: serialization and cache 
bouncing. The ordering often requires _more_ serialization than a 
lock/unlock sequence, so sequences like the above are often slower than 
the trivial lock is, at least in the absense of lock contention.

So sequence numbers (or multiple reads) only tend make sense where there
is a _lot_ more reads than writes, and where you get lots of lock 
contention. If there are lots of writes, my gut feel (but hey, all locking 
optimization should be backed up by real numbers) is that it's better to 
have a lock close to the data, since you'll get the cacheline bounces 
_anyway_, and locking often has lower serialization costs.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
