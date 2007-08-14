Date: Tue, 14 Aug 2007 14:48:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
In-Reply-To: <20070814214430.GD23308@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0708141444590.32110@schroedinger.engr.sgi.com>
References: <p73vebhnauo.fsf@bingen.suse.de>
 <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com>
 <20070814203329.GA22202@one.firstfloor.org>
 <Pine.LNX.4.64.0708141341120.31513@schroedinger.engr.sgi.com>
 <20070814204454.GC22202@one.firstfloor.org>
 <Pine.LNX.4.64.0708141414260.31693@schroedinger.engr.sgi.com>
 <20070814212355.GA23308@one.firstfloor.org>
 <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com>
 <20070814212955.GC23308@one.firstfloor.org>
 <Pine.LNX.4.64.0708141436380.31693@schroedinger.engr.sgi.com>
 <20070814214430.GD23308@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > But that still creates lots of overhead each time we take the lru lock!
> 
> A lot of overhead in what way? Setting a flag in a cache hot
> per CPU data variable shouldn't be more than a few cycles.

Could you be a bit more specific? Where do you want to place the data?

What we are talking about is

atomic_inc(&zone->reclaim_cpu[smp_processor_id()]);
smp_wmb();
spin_lock(&zone->lru_lock);

....

spin_unlock(&zone_lru_lock);
smp_wmb();
atomic_dec(&zone->reclaim_cpu[smp_processor_id()]);

That is not light weight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
