Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EC8836B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:29:32 -0400 (EDT)
Message-ID: <49B6A374.6040805@hp.com>
Date: Tue, 10 Mar 2009 13:29:24 -0400
From: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
MIME-Version: 1.0
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
References: <49B68450.9000505@hp.com> <1236705532.3205.14.camel@calx>
In-Reply-To: <1236705532.3205.14.camel@calx>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
> On Tue, 2009-03-10 at 11:16 -0400, Alan D. Brunelle wrote:
>> Running blktrace & I/O loads cause a kernel BUG at mm/slab.c:3002!.
> 
> Pid: 11346, comm: blktrace Tainted: G    B      2.6.29-rc7 #3 ProLiant
> DL585 G5   
> 
> That 'B' there indicates you've hit 'bad page' before this. That bug
> seems to be strongly correlated with some form of hardware trouble.
> Unfortunately, that makes everything after that point a little suspect.


/If/ it were a hardware issue, that might explain the subsequent issue
when I switched to SLUB instead...

How does one look for "bad page reports"?

I /will/ go back and change mm/slab.c as suggested - that will help some
I'm sure (and switch back to SLAB, of course).

> 
> Both this slab BUG and the bad page issue are "shouldn't happen"
> situations that are generally caused by memory changing out from under
> the subsystem, either by some other code scribbling on the relevant
> memory or DRAM trouble or the like. If you want to pursue this further,
> please gather up a collection of any bad page reports you can find on
> your system and change the BUG code at slab.c:3002 to read something
> like:
> 
> 	if (slabp->inuse < 0 || slabp->inuse >= cachep->num) {
> 		printk("SLAB: slabp %p inuse %d max %d\n",
> 			slabp, slabp->inuse, cachep->num);
> 		BUG();
> 	}
> 
> We might find that the slab and the bad page are the same page or
> nearby. We might find that inuse has a single bit flipped (hardware
> error). Or we might find that it has a revealing value scribbled over it
> that points to the culprit. From your trace, it appears to contain 0x70,
> which is a rather large number of objects to have on a slab but as we
> don't know what slab it is, it's hard to say what happened.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
