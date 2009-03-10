Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B3B0D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:19:27 -0400 (EDT)
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <49B68450.9000505@hp.com>
References: <49B68450.9000505@hp.com>
Content-Type: text/plain
Date: Tue, 10 Mar 2009 12:18:52 -0500
Message-Id: <1236705532.3205.14.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-03-10 at 11:16 -0400, Alan D. Brunelle wrote:
> Running blktrace & I/O loads cause a kernel BUG at mm/slab.c:3002!.

Pid: 11346, comm: blktrace Tainted: G    B      2.6.29-rc7 #3 ProLiant
DL585 G5   

That 'B' there indicates you've hit 'bad page' before this. That bug
seems to be strongly correlated with some form of hardware trouble.
Unfortunately, that makes everything after that point a little suspect.

Both this slab BUG and the bad page issue are "shouldn't happen"
situations that are generally caused by memory changing out from under
the subsystem, either by some other code scribbling on the relevant
memory or DRAM trouble or the like. If you want to pursue this further,
please gather up a collection of any bad page reports you can find on
your system and change the BUG code at slab.c:3002 to read something
like:

	if (slabp->inuse < 0 || slabp->inuse >= cachep->num) {
		printk("SLAB: slabp %p inuse %d max %d\n",
			slabp, slabp->inuse, cachep->num);
		BUG();
	}

We might find that the slab and the bad page are the same page or
nearby. We might find that inuse has a single bit flipped (hardware
error). Or we might find that it has a revealing value scribbled over it
that points to the culprit. From your trace, it appears to contain 0x70,
which is a rather large number of objects to have on a slab but as we
don't know what slab it is, it's hard to say what happened.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
