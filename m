Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	  <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Nov 2006 19:55:15 +0100
Message-Id: <1164912915.6588.153.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-30 at 10:52 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > The slab has some unfairness wrt gfp flags; when the slab is grown the gfp 
> > flags are used to allocate more memory, however when there is slab space 
> > available, gfp flags are ignored. Thus it is possible for less critical 
> > slab allocations to succeed and gobble up precious memory.
> 
> The gfpflags are ignored if there are
> 
> 1) objects in the per cpu, shared or alien caches
> 
> 2) objects are in partial or free slabs in the per node queues.

Yeah, basically as long as free objects can be found. No matter how
'hard' is was to obtain these objects.

> > This patch avoids this by keeping track of the allocation hardness when 
> > growing. This is then compared to the current slab alloc's gfp flags.
> 
> The approach is to force the allocation of additional slab to increase the 
> number of free slabs? The next free will drop the number of free slabs 
> back again to the allowed amount.

No, the forced allocation is to test the allocation hardness at that
point in time. I could not think of another way to test that than to
actually to an allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
