Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id B04676B0074
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 11:18:02 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so2660844pbc.39
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 08:18:02 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 11:17:58 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1831E6E8048
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 11:17:55 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8RFHthV9699768
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:17:55 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8RFKsBI006384
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:20:56 -0600
Date: Fri, 27 Sep 2013 08:17:50 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
Message-ID: <20130927151749.GA2149@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1380235333.3229.39.camel@j-VirtualBox>
 <1380236265.3467.103.camel@schen9-DESK>
 <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380291257.17366.103.camel@joe-AO722>
 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
 <1380292495.17366.106.camel@joe-AO722>
 <20130927145007.GD15690@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130927145007.GD15690@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Joe Perches <joe@perches.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 04:50:07PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 07:34:55AM -0700, Joe Perches wrote:
> > That would make it seem as if all barriers are SMP no?
> 
> I would think any memory barrier is ordering against someone else; if
> not smp then a device/hardware -- like for instance the hardware page
> table walker.
> 
> Barriers are fundamentally about order; and order only makes sense if
> there's more than 1 party to the game.

Oddly enough, there is one exception that proves the rule...  On Itanium,
suppose we have the following code, with x initially equal to zero:

CPU 1: ACCESS_ONCE(x) = 1;

CPU 2: r1 = ACCESS_ONCE(x); r2 = ACCESS_ONCE(x);

Itanium architects have told me that it really is possible for CPU 2 to
see r1==1 and r2==0.  Placing a memory barrier between CPU 2's pair of
fetches prevents this, but without any other memory barrier to pair with.

> > Maybe just refer to Documentation/memory-barriers.txt
> > and/or say something like "please document appropriately"
> 
> Documentation/memory-barriers.txt is always good; appropriately doesn't
> seem to quantify anything much at all. Someone might think:
> 
> /*  */
> smp_mb();
> 
> appropriate... 

I end up doing this:

/* */
smp_mb(); /* See above block comment. */

But it would be nice for the prior comment to be recognized as belonging
to the memory barrier without the additional "See above" comment.

In any case, please feel free to add:

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

to the original checkpatch.pl patch.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
