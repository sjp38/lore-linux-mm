Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f41.google.com (mail-vb0-f41.google.com [209.85.212.41])
	by kanga.kvack.org (Postfix) with ESMTP id 482B66B0044
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:58:14 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id w5so4566991vbf.28
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 15:58:14 -0800 (PST)
Received: from mail-ve0-x22b.google.com (mail-ve0-x22b.google.com [2607:f8b0:400c:c01::22b])
        by mx.google.com with ESMTPS id a6si20125313vdp.130.2013.11.26.15.58.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 15:58:13 -0800 (PST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so4708717veb.30
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 15:58:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131126225136.GG4137@linux.vnet.ibm.com>
References: <20131122182632.GW4138@linux.vnet.ibm.com>
	<20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	<20131125173540.GK3694@twins.programming.kicks-ass.net>
	<20131125180250.GR4138@linux.vnet.ibm.com>
	<20131125182715.GG10022@twins.programming.kicks-ass.net>
	<20131125235252.GA4138@linux.vnet.ibm.com>
	<20131126095945.GI10022@twins.programming.kicks-ass.net>
	<CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
	<20131126192003.GA4137@linux.vnet.ibm.com>
	<CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
	<20131126225136.GG4137@linux.vnet.ibm.com>
Date: Tue, 26 Nov 2013 15:58:11 -0800
Message-ID: <CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 2:51 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Good points, and after_spinlock() works for me from an RCU perspective.

Note that there's still a semantic question about exactly what that
"after_spinlock()" is: would it be a memory barrier *only* for the CPU
that actually does the spinlock? Or is it that "third CPU" order?

IOW, it would stil not necessarily make your "unlock+lock" (on
different CPU's) be an actual barrier as far as a third CPU was
concerned, because you could still have the "unlock happened after
contention was going on, so the final unlock only released the MCS
waiter, and there was no barrier".

See what I'm saying? We could guarantee that if somebody does

    write A;
    spin_lock()
    mb__after_spinlock();
    read B

then the "write A" -> "read B" would be ordered. That's one thing.

But your

 -  CPU 1:

    write A
    spin_unlock()

 - CPU 2

    spin_lock()
    mb__after_spinlock();
    read B

ordering as far as a *third* CPU is concerned is a whole different
thing again, and wouldn't be at all the same thing.

Is it really that cross-CPU ordering you care about?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
