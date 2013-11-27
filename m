Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 302A16B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 05:18:08 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ey16so1797104wid.0
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 02:18:07 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id lk7si12574586wjb.68.2013.11.27.02.18.06
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 02:18:06 -0800 (PST)
Date: Wed, 27 Nov 2013 10:16:13 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131127101613.GC9032@mudshark.cambridge.arm.com>
References: <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com>
 <20131126095945.GI10022@twins.programming.kicks-ass.net>
 <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
 <20131126192003.GA4137@linux.vnet.ibm.com>
 <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131126225136.GG4137@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 10:51:36PM +0000, Paul E. McKenney wrote:
> On Tue, Nov 26, 2013 at 11:32:25AM -0800, Linus Torvalds wrote:
> > On Tue, Nov 26, 2013 at 11:20 AM, Paul E. McKenney
> > <paulmck@linux.vnet.ibm.com> wrote:
> > >
> > > There are several places in RCU that assume unlock+lock is a full
> > > memory barrier, but I would be more than happy to fix them up given
> > > an smp_mb__after_spinlock() and an smp_mb__before_spinunlock(), or
> > > something similar.
> > 
> > A "before_spinunlock" would actually be expensive on x86.
> 
> Good point, on x86 the typical non-queued spin-lock acquisition path
> has an atomic operation with full memory barrier in any case.  I believe
> that this is the case for the other TSO architectures.  For the non-TSO
> architectures:
> 
> o	ARM has an smp_mb() during lock acquisition, so after_spinlock()
> 	can be a no-op for them.

Ok, but what about arm64? We use acquire for lock() and release for
unlock(), so in Linus' example:

    write A;
    spin_lock()
    mb__after_spinlock();
    read B

Then A could very well be reordered after B if mb__after_spinlock() is a nop.
Making that a full barrier kind of defeats the point of using acquire in the
first place...

It's one thing ordering unlock -> lock, but another getting those two to
behave as full barriers for any arbitrary memory accesses.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
