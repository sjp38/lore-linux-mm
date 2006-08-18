Date: Fri, 18 Aug 2006 10:04:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/1] network memory allocator.
In-Reply-To: <200608181129.15075.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0608180959190.31844@schroedinger.engr.sgi.com>
References: <20060814110359.GA27704@2ka.mipt.ru> <20060816142557.acccdfcf.ak@suse.de>
 <Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
 <200608181129.15075.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Aug 2006, Andi Kleen wrote:

> Also I must say it's still not quite clear to me if it's better to place
> network packets on the node the device is connected to or on the 
> node which contains the CPU who processes the packet data 
> For RX this can be three different nodes in the worst case
> (CPU processing is often split on different CPUs between softirq
> and user context), for TX  two. Do you have some experience that shows 
> that a particular placement is better than the other?

The more nodes are involved the more numa traffic and the slower the 
overall performance. It is best to place all control information on the 
node of the network card. The actual data is read via DMA and one may
place that local to the executing process. The DMA transfer will then have 
to cross the NUMA interlink but that DMA transfer is a linear and 
predictable stream that can often be optimized by hardware. If you 
would create the data on the network node then you would have off 
node overhead when creating the data (random acces to cache lines?) which 
is likely worse.

One should be able to place the process near the node that has the network 
card. Our machines typically have multiple network cards. It would be best 
if the network stack could choose the one that is nearest to the process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
