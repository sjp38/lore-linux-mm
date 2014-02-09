Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 38BF96B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 21:00:13 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wo20so5836516obc.28
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 18:00:12 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id rk9si5282629obb.51.2014.02.08.18.00.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 18:00:12 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 8 Feb 2014 19:00:11 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 91DC11FF001B
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 19:00:08 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s192089u31260778
	for <linux-mm@kvack.org>; Sun, 9 Feb 2014 03:00:08 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1923S1i009209
	for <linux-mm@kvack.org>; Sat, 8 Feb 2014 19:03:29 -0700
Date: Sat, 8 Feb 2014 18:00:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140209020004.GY4250@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <52F60699.8010204@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F60699.8010204@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

On Sat, Feb 08, 2014 at 12:27:37PM +0200, Pekka Enberg wrote:
> Hi Paul,
> 
> On 01/02/2014 10:33 PM, Paul E. McKenney wrote:
> > From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
> >allocators would deal with the following sort of race:
> >
> >A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;
> >
> >	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);
> >
> >However, my guess is that this should be considered an accident of the
> >current implementation rather than a feature.  The reason for this is
> >that I cannot see how you would usefully do (A) above without also allowing
> >(B) and (C) below, both of which look to me to be quite destructive:
> >
> >B.	CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> >
> >         CPU 1: r2 = ACCESS_ONCE(shared_x); if (r2) kfree(r2);
> >
> >	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> >
> >	This results in the memory being on two different freelists.
> >
> >C.      CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
> >
> >	CPU 1: r2 = ACCESS_ONCE(shared_x); r2->a = 1; r2->b = 2;
> >
> >	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
> >
> >	CPU 3: r4 = kmalloc(...);  r4->s = 3; r4->t = 4;
> >
> >	This results in the memory being used by two different CPUs,
> >	each of which believe that they have sole access.
> >
> >But I thought I should ask the experts.
> >
> >So, am I correct that kernel hackers are required to avoid "drive-by"
> >kfree()s of kmalloc()ed memory?
> 
> So to be completely honest, I don't understand what is the race in
> (A) that concerns the *memory allocator*.  I also don't what the
> memory allocator can do in (B) and (C) which look like double-free
> and use-after-free, respectively, to me. :-)

>From what I can see, (A) works by accident, but is kind of useless because
you allocate and free the memory without touching it.  (B) and (C) are the
lightest touches I could imagine, and as you say, both are bad.  So I
believe that it is reasonable to prohibit (A).

Or is there some use for (A) that I am missing?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
