Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2569F6B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 00:14:40 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wn1so15170368obc.19
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 21:14:39 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id p8si46207501oeq.43.2014.01.02.21.14.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 21:14:38 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 2 Jan 2014 22:14:37 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D28B01FF001A
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 22:14:07 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s035ESYF8585602
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 06:14:28 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s035HkHk024978
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 22:17:46 -0700
Date: Thu, 2 Jan 2014 21:14:17 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140103051417.GT19211@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <20140103033906.GB2983@leaf>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140103033906.GB2983@leaf>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

On Thu, Jan 02, 2014 at 07:39:07PM -0800, Josh Triplett wrote:
> On Thu, Jan 02, 2014 at 12:33:20PM -0800, Paul E. McKenney wrote:
> > Hello!
> > 
> > From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
> > allocators would deal with the following sort of race:
> > 
> > A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;
> > 
> > 	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);
> > 
> > However, my guess is that this should be considered an accident of the
> > current implementation rather than a feature.  The reason for this is
> > that I cannot see how you would usefully do (A) above without also allowing
> > (B) and (C) below, both of which look to me to be quite destructive:
> 
> (A) only seems OK if "gp" is guaranteed to be NULL beforehand, *and* if
> no other CPUs can possibly do what CPU 1 is doing in parallel.  Even
> then, it seems questionable how this could ever be used successfully in
> practice.
> 
> This seems similar to the TCP simultaneous-SYN case: theoretically
> possible, absurd in practice.

Heh!

Agreed on the absurdity, but my quick look and slab/slob/slub leads
me to believe that current Linux kernel would actually do something
sensible in this case.  But only because they don't touch the actual
memory.  DYNIX/ptx would have choked on it, IIRC.

And the fact that slab/slob/slub seem to handle (A) seemed bizarre
enough to be worth asking the question.

> > B.	CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> > 
> >         CPU 1: r2 = ACCESS_ONCE(shared_x); if (r2) kfree(r2);
> > 
> > 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> > 
> > 	This results in the memory being on two different freelists.
> 
> That's a straightforward double-free bug.  You need some kind of
> synchronization there to ensure that only one call to kfree occurs.

Yep!

> > C.      CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> > 
> > 	CPU 1: r2 = ACCESS_ONCE(shared_x); r2->a = 1; r2->b = 2;
> > 
> > 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> > 
> > 	CPU 3: r4 = kmalloc(...);  r4->s = 3; r4->t = 4;
> > 
> > 	This results in the memory being used by two different CPUs,
> > 	each of which believe that they have sole access.
> 
> This is not OK either: CPU 2 has called kfree on a pointer that CPU 1
> still considers alive, and again, the CPUs haven't used any form of
> synchronization to prevent that.

Agreed.

> > But I thought I should ask the experts.
> > 
> > So, am I correct that kernel hackers are required to avoid "drive-by"
> > kfree()s of kmalloc()ed memory?
> 
> Don't kfree things that are in use, and synchronize to make sure all
> CPUs agree about "in use", yes.

For example, ensure that each kmalloc() happens unambiguously before the
corresponding kfree().  ;-)

> > PS.  To the question "Why would anyone care about (A)?", then answer
> >      is "Inquiring programming-language memory-model designers want
> >      to know."
> 
> I find myself wondering about the original form of the question, since
> I'd hope that programming-languge memory-model designers would
> understand the need for synchronization around reclaiming memory.

I think that they do now.  The original form of the question was as
follows:

	But my intuition at the moment is that allowing racing
	accesses and providing pointer atomicity leads to a much more
	complicated and harder to explain model.  You have to deal
	with initialization issues and OOTA problems without atomics.
	And the implementation has to deal with cross-thread visibility
	of malloc meta-information, which I suspect will be expensive.
	You now essentially have to be able to malloc() in one thread,
	transfer the pointer via a race to another thread, and free()
	in the second thread.  Thata??s hard unless malloc() and free()
	always lock (as I presume they do in the Linux kernel).

But the first I heard of it was something like litmus test (A) above.

(And yes, I already disabused them of their notion that Linux kernel
kmalloc() and kfree() always lock.)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
