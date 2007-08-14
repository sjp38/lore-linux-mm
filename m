Date: Tue, 14 Aug 2007 23:56:59 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Message-ID: <20070814215659.GF23308@one.firstfloor.org>
References: <20070814203329.GA22202@one.firstfloor.org> <Pine.LNX.4.64.0708141341120.31513@schroedinger.engr.sgi.com> <20070814204454.GC22202@one.firstfloor.org> <Pine.LNX.4.64.0708141414260.31693@schroedinger.engr.sgi.com> <20070814212355.GA23308@one.firstfloor.org> <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com> <20070814212955.GC23308@one.firstfloor.org> <Pine.LNX.4.64.0708141436380.31693@schroedinger.engr.sgi.com> <20070814214430.GD23308@one.firstfloor.org> <Pine.LNX.4.64.0708141444590.32110@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708141444590.32110@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 02:48:31PM -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > > But that still creates lots of overhead each time we take the lru lock!
> > 
> > A lot of overhead in what way? Setting a flag in a cache hot
> > per CPU data variable shouldn't be more than a few cycles.
> 
> Could you be a bit more specific? Where do you want to place the data?

DEFINE_PER_CPU(int, zone_flag);

	get_cpu();	// likely already true and then not needed
	__get_cpu(zone_flag) = 1;
	/* wmb is implied in spin_lock I think */
	spin_lock(&zone->lru_lock);
	...
	spin_unlock(&zone->lru_lock);
	__get_cpu(zone_flag) = 0;
	put_cpu();

Interrupt handler

	if (!__get_cpu(zone_flag)) {
		do things with zone locks 
	}

The interrupt handler shouldn't touch zone_flag. If it wants
to it would need to be converted to a local_t and incremented/decremented
(should be about the same cost at least on architectures with sane
local_t implementation) 
		
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
