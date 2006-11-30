Date: Thu, 30 Nov 2006 10:52:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
In-Reply-To: <20061130101921.113055000@chello.nl>>
Message-ID: <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl>> <20061130101921.113055000@chello.nl>>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> The slab has some unfairness wrt gfp flags; when the slab is grown the gfp 
> flags are used to allocate more memory, however when there is slab space 
> available, gfp flags are ignored. Thus it is possible for less critical 
> slab allocations to succeed and gobble up precious memory.

The gfpflags are ignored if there are

1) objects in the per cpu, shared or alien caches

2) objects are in partial or free slabs in the per node queues.

> This patch avoids this by keeping track of the allocation hardness when 
> growing. This is then compared to the current slab alloc's gfp flags.

The approach is to force the allocation of additional slab to increase the 
number of free slabs? The next free will drop the number of free slabs 
back again to the allowed amount.

I would think that one would need a rank with each cached object and 
free slab in order to do this the right way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
