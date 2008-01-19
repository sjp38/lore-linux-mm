Date: Fri, 18 Jan 2008 20:55:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080118065621.GA27495@aepfle.de>
Message-ID: <Pine.LNX.4.64.0801182046060.12079@schroedinger.engr.sgi.com>
References: <20080115150949.GA14089@aepfle.de>
 <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
 <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com>
 <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
 <20080117211511.GA25320@aepfle.de> <20080118065621.GA27495@aepfle.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Olaf Hering wrote:

> calls cache_grow with nodeid 0
> > [c00000000075bbd0] [c0000000000f82d0] .cache_alloc_refill+0x234/0x2c0
> calls cache_grow with nodeid 0
> > [c00000000075bbe0] [c0000000000f7f38] .____cache_alloc_node+0x17c/0x1e8
> 
> calls cache_grow with nodeid 1
> > [c00000000075bbe0] [c0000000000f7d68] .fallback_alloc+0x1a0/0x1f4

Okay that makes sense. You have no node 0 with normal memory but the node 
assigned to the executing processor is zero (correct?). Thus it needs to 
fallback to node 1 and that is not possible during bootstrap. You need to 
run kmem_cache_init() on a cpu on a processor with memory.

Or we need to revert the patch which would allocate control 
structures again for all online nodes regardless if they have memory or 
not.

Does reverting 04231b3002ac53f8a64a7bd142fde3fa4b6808c6 change the 
situation? (However, we tried this on the other thread without success).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
