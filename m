Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 67DCC6B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 22:39:16 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm19so58094wib.7
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 19:39:15 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id k1si22392298wjz.126.2014.01.02.19.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 19:39:15 -0800 (PST)
Date: Thu, 2 Jan 2014 19:39:07 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: Memory allocator semantics
Message-ID: <20140103033906.GB2983@leaf>
References: <20140102203320.GA27615@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140102203320.GA27615@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

On Thu, Jan 02, 2014 at 12:33:20PM -0800, Paul E. McKenney wrote:
> Hello!
> 
> From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
> allocators would deal with the following sort of race:
> 
> A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;
> 
> 	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);
> 
> However, my guess is that this should be considered an accident of the
> current implementation rather than a feature.  The reason for this is
> that I cannot see how you would usefully do (A) above without also allowing
> (B) and (C) below, both of which look to me to be quite destructive:

(A) only seems OK if "gp" is guaranteed to be NULL beforehand, *and* if
no other CPUs can possibly do what CPU 1 is doing in parallel.  Even
then, it seems questionable how this could ever be used successfully in
practice.

This seems similar to the TCP simultaneous-SYN case: theoretically
possible, absurd in practice.

> B.	CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> 
>         CPU 1: r2 = ACCESS_ONCE(shared_x); if (r2) kfree(r2);
> 
> 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> 
> 	This results in the memory being on two different freelists.

That's a straightforward double-free bug.  You need some kind of
synchronization there to ensure that only one call to kfree occurs.

> C.      CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> 
> 	CPU 1: r2 = ACCESS_ONCE(shared_x); r2->a = 1; r2->b = 2;
> 
> 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> 
> 	CPU 3: r4 = kmalloc(...);  r4->s = 3; r4->t = 4;
> 
> 	This results in the memory being used by two different CPUs,
> 	each of which believe that they have sole access.

This is not OK either: CPU 2 has called kfree on a pointer that CPU 1
still considers alive, and again, the CPUs haven't used any form of
synchronization to prevent that.

> But I thought I should ask the experts.
> 
> So, am I correct that kernel hackers are required to avoid "drive-by"
> kfree()s of kmalloc()ed memory?

Don't kfree things that are in use, and synchronize to make sure all
CPUs agree about "in use", yes.

> PS.  To the question "Why would anyone care about (A)?", then answer
>      is "Inquiring programming-language memory-model designers want
>      to know."

I find myself wondering about the original form of the question, since
I'd hope that programming-languge memory-model designers would
understand the need for synchronization around reclaiming memory.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
