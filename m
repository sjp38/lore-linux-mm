Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id D578E6B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 15:33:40 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so15015846obc.29
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 12:33:40 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id jb8si45338889obb.105.2014.01.02.12.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 12:33:39 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 2 Jan 2014 13:33:39 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 68ABA19D803E
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 13:33:27 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s02KXQae63766550
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 21:33:26 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s02Kakwx008935
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 13:36:46 -0700
Date: Thu, 2 Jan 2014 12:33:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Memory allocator semantics
Message-ID: <20140102203320.GA27615@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

Hello!

>From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
allocators would deal with the following sort of race:

A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;

	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);

However, my guess is that this should be considered an accident of the
current implementation rather than a feature.  The reason for this is
that I cannot see how you would usefully do (A) above without also allowing
(B) and (C) below, both of which look to me to be quite destructive:

B.	CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;

        CPU 1: r2 = ACCESS_ONCE(shared_x); if (r2) kfree(r2);

	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);

	This results in the memory being on two different freelists.

C.      CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;

	CPU 1: r2 = ACCESS_ONCE(shared_x); r2->a = 1; r2->b = 2;

	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);

	CPU 3: r4 = kmalloc(...);  r4->s = 3; r4->t = 4;

	This results in the memory being used by two different CPUs,
	each of which believe that they have sole access.

But I thought I should ask the experts.

So, am I correct that kernel hackers are required to avoid "drive-by"
kfree()s of kmalloc()ed memory?

							Thanx, Paul

PS.  To the question "Why would anyone care about (A)?", then answer
     is "Inquiring programming-language memory-model designers want
     to know."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
