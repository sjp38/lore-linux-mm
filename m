Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7198C6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:21:29 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612091002.GA32052@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 19:21:55 +1000
Message-Id: <1244798515.7172.99.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


> We emit a debug warning but dont crash, so all should be fine and 
> the culprits can then be fixed, right?

 ... rewind ... :-)

Ok so, no, the culprit cannot be all fixed in a satifactory way.

The main reason is that I believe it's not "right" to have every caller
of slab around know whether GFP_KERNEL is good to go or it should get
into GFP_NOWAIT. This depends on many factors (among others us moving
things around more), and is not actually a good solution for thing that
can be called both at boot and later, such as get_vm_area().

I really think we are looking for trouble (and a lot of hidden bugs) by
trying to "fix" all callers, in addition to making some code like
vmalloc() more failure prone because it's unconditionally changed from
GFP_KERNEL to GFP_NOWAIT.

It seems a lot more reasonably to me to have sl*b naturally degrade to
NOWAIT when it's too early to enable interrupts.

In addition, my proposal of having bits to mask off gfp will also be
useful in fixing similar issues with suspend/resume vs. GFP_NOIO which
should really become implicit when devices start becoming suspended.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
