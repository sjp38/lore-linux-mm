Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id AAF096B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:06:27 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so4859090qac.7
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:06:27 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id k4si10646505qci.63.2013.11.22.12.06.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 12:06:26 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 13:06:25 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6CC461FF001C
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:06:04 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMI4Zkb1245600
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 19:04:35 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAMK9G8T014359
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:09:18 -0700
Date: Fri, 22 Nov 2013 12:06:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122200620.GA4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
 <20131121225208.GJ4138@linux.vnet.ibm.com>
 <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
 <20131122040856.GK4138@linux.vnet.ibm.com>
 <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
 <20131122062314.GN4138@linux.vnet.ibm.com>
 <20131122151600.GA14988@gmail.com>
 <20131122184937.GX4138@linux.vnet.ibm.com>
 <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 11:06:41AM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 10:49 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > You see, my problem is not the "crazy ordering" DEC Alpha, Itanium,
> > PowerPC, or even ARM.  It is really obvious what instructions to use in
> > a stiffened-up smp_store_release() for those guys: "mb" for DEC Alpha,
> > "st.rel" for Itanium, "sync" for PowerPC, and "dmb" for ARM.  Believe it
> > or not, my problem is instead with good old tightly ordered x86.
> >
> > We -could- just put an mfence into x86's smp_store_release() and
> > be done with it
> 
> Why would you bother?  The *acquire* has a memory barrier. End of
> story. On x86, it has to (since otherwise a load inside the locked
> region could be re-ordered wrt the write that takes the lock).

I am sorry, but that is not always correct.  For example, in the contended
case for Tim Chen's MCS queued locks, the x86 acquisition-side handoff
code does -not- contain any stores or memory-barrier instructions.
Here is that portion of the arch_mcs_spin_lock() code, along with the
x86 definition for smp_load_acquire:

+       while (!(smp_load_acquire(&node->locked)))                      \
+               arch_mutex_cpu_relax();                                 \

+#define smp_load_acquire(p)                                            \
+({                                                                     \
+       typeof(*p) ___p1 = ACCESS_ONCE(*p);                             \
+       compiletime_assert_atomic_type(*p);                             \
+       barrier();                                                      \
+       ___p1;                                                          \
+})

No stores, no memory-barrier instructions.

Of course, the fact that there are no stores means that on x86 the
critical section cannot leak out, even with no memory barrier.  That is
the easy part.  The hard part is if we want unlock+lock to be a full
memory barrier for MCS lock from the viewpoint of code not holding
that lock.  We clearly cannot rely on the non-existent memory barrier
in the acquisition handoff code.

And yes, there is a full barrier implied by the xchg() further up in
arch_mcs_spin_lock(), shown in full below, but that barrier is before
the handoff code, so that xchg() cannot have any effect on the handoff.
That xchg() therefore cannot force unlock+lock to act as a full memory
barrier in the contended queue-handoff case.

> Basically, any time you think you need to add a memory barrier on x86,
> you should go "I'm doing something wrong". It's that simple.

It -appears- that the MCS queue handoff code is one of the many cases
where we don't need a memory barrier on x86, even if we do want MCS
unlock+lock to be a full memory barrier.  But I wouldn't call it simple.
I -think- we do have a proof, but I don't yet totally trust it.

							Thanx, Paul


>                   Linus

------------------------------------------------------------------------

+#define arch_mcs_spin_lock(lock, node)                                 \
+{                                                                      \
+       struct mcs_spinlock *prev;                                      \
+                                                                       \
+       /* Init node */                                                 \
+       node->locked = 0;                                               \
+       node->next   = NULL;                                            \
+                                                                       \
+       /* xchg() provides a memory barrier */                          \
+       prev = xchg(lock, node);                                        \
+       if (likely(prev == NULL)) {                                     \
+               /* Lock acquired */                                     \
+               return;                                                 \
+       }                                                               \
+       ACCESS_ONCE(prev->next) = node;                                 \
+       /*                                                              \
+        * Wait until the lock holder passes the lock down.             \
+        * Using smp_load_acquire() provides a memory barrier that      \
+        * ensures subsequent operations happen after the lock is       \
+        * acquired.                                                    \
+        */                                                             \
+       while (!(smp_load_acquire(&node->locked)))                      \
+               arch_mutex_cpu_relax();                                 \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
