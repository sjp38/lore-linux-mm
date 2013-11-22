Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id E28D26B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 01:23:22 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gq1so879656obb.32
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 22:23:22 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id t5si21064273oem.79.2013.11.21.22.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 22:23:22 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Nov 2013 23:23:20 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C920019D8041
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:23:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAM4LIVc1769874
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 05:21:18 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAM6QAvs032284
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:26:12 -0700
Date: Thu, 21 Nov 2013 22:23:14 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122062314.GN4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
 <20131121225208.GJ4138@linux.vnet.ibm.com>
 <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
 <20131122040856.GK4138@linux.vnet.ibm.com>
 <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 08:25:59PM -0800, Linus Torvalds wrote:
> On Thu, Nov 21, 2013 at 8:08 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > It is not the architecture that matters here, it is just a definition of
> > what ordering guarantees the locking primitives provide, independent of
> > the architecture.
> 
> So we definitely come from very different backgrounds.

Agreed, and I am pretty sure we are talking past each other.

> I don't care one *whit* about theoretical lock orderings. Not a bit.

If by theoretical lock orderings, you mean whether or not unlock+lock
acts as a full memory barrier, we really do have some code in the kernel
that relies on this.  So we either need to have find and change this
code or we need unlock+lock to continue to act as a full memory barrier.
Making RCU stop relying on this is easy because all the code that assumes
unlock+lock is a full barrier is on slow paths anyway.  Other subsystems
might be in different situations.

If you mean something else by theoretical lock orderings, I am sorry,
but I am completely failing to see what it might be.

> I do care deeply about reality, particularly of architectures that
> actually matter. To me, a spinlock in some theoretical case is
> uninteresting, but a efficient spinlock implementation on a real
> architecture is a big deal that matters a lot.

Agreed, reality and efficiency are the prime concerns.  Theory serves
reality and efficiency, but definitely not the other way around.

But if we want locking primitives that don't rely solely on atomic
instructions (such as the queued locks that people have been putting
forward), we are going to need to wade through a fair bit of theory
to make sure that they actually work on real hardware.  Subtle bugs in
locking primitives is a type of reality that I think we can both agree
that we should avoid.

Or am I missing your point?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
