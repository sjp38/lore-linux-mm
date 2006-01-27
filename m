Date: Fri, 27 Jan 2006 09:22:10 +0200 (EET)
From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [patch 9/9] slab - Implement single mempool backing for slab
 allocator
In-Reply-To: <43D951C4.8050503@us.ibm.com>
Message-ID: <Pine.LNX.4.58.0601270915450.14394@sbz-30.cs.Helsinki.FI>
References: <20060125161321.647368000@localhost.localdomain>
 <1138218024.2092.9.camel@localhost.localdomain>
 <84144f020601260011p1e2f883fp8058eb0e2edee99f@mail.gmail.com>
 <43D951C4.8050503@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jan 2006, Matthew Dobson wrote:
> As you mention, there is no guarantee as to how long the critical page will
> be in use for.  One idea to tackle that problem would be to use the new
> mempool_t pointer in struct slab to provide exclusivity of critical slab
> pages, ie: if a non-critical slab request comes in and the only free page
> in the slab is a 'critical' page (it came from a mempool) then attempt to
> grow the slab or fail the non-critical request.  Both of these concepts
> were (more or less) implemented in my other attempt at solving the critical
> pool problem, so moving them to fit into this approach should not be difficult.

Increasing struct slab size doesn't sound too appealing. I don't think the 
slab allocator should know about mempools. Your critical allocations and 
regular slab allocations have very different needs. For regular 
allocations, we want to avoid page allocation which is why the object 
caches hold on to slab pages whereas for mempool, I think you almost 
always want to give back unused memory to the pool.

I think a better way to go is to improve the mempool implementation to 
allow non-fixed size allocations and then combine that with the slab 
allocator to get what you need.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
