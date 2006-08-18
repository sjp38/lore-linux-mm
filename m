From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Fri, 18 Aug 2006 11:29:14 +0200
References: <20060814110359.GA27704@2ka.mipt.ru> <20060816142557.acccdfcf.ak@suse.de> <Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608181129.15075.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 18 August 2006 04:25, Christoph Lameter wrote:
> On Wed, 16 Aug 2006, Andi Kleen wrote:
> > That's not true on all NUMA systems (that they have a slow interconnect)
> > I think on x86-64 I would prefer if it was distributed evenly or maybe
> > even on the CPU who is finally going to process it.
> >
> > -Andi "not all NUMA is an Altix"
>
> The Altix NUMA interconnect has the same speed as far as I can recall as
> Hypertransport. It is the distance (real physical cable length) that
> creates latencies for huge systems. Sadly the Hypertransport is designed
> to stay on the motherboard. Hypertransport can only be said to be fast
> because its only used for tinzy winzy systems of a few processors. Are
> you saying that the design limitations of Hypertransport are an
> advantage?

Sorry, didn't want to state anything particular about advantages 
or disadvantages of different interconnects. I just wanted to say
that there are a lot of NUMA systems out there which have a very low
NUMA factor (for whatever reason, including them being quite small)
and that they should be considered for NUMA optimizations too.

So if you really want strict IO placement at least allow an easy way 
to turn it off even when CONFIG_NUMA is defined.

BTW there are large x86-64 NUMA systems that don't use HyperTransport
and have a varying NUMA factor, and also even HyperTransport
based systems have a widely varying NUMA factor depending on machine
size and hop distance (2-8 sockets and larger systems are in development)

So ideal would be something dynamic to turn on/off io placement, maybe based 
on node_distance() again, with the threshold tweakable per architecture?

Also I must say it's still not quite clear to me if it's better to place
network packets on the node the device is connected to or on the 
node which contains the CPU who processes the packet data 
For RX this can be three different nodes in the worst case
(CPU processing is often split on different CPUs between softirq
and user context), for TX  two. Do you have some experience that shows 
that a particular placement is better than the other?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
