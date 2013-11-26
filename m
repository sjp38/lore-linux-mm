Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 224AA6B0092
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:00:52 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id u57so99004wes.23
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:00:51 -0800 (PST)
Received: from mail-ea0-x236.google.com (mail-ea0-x236.google.com [2a00:1450:4013:c01::236])
        by mx.google.com with ESMTPS id l7si19614586wjz.113.2013.11.26.11.00.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 11:00:50 -0800 (PST)
Received: by mail-ea0-f182.google.com with SMTP id o10so5552281eaj.27
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:00:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131126095945.GI10022@twins.programming.kicks-ass.net>
References: <20131121172558.GA27927@linux.vnet.ibm.com>
	<20131121215249.GZ16796@laptop.programming.kicks-ass.net>
	<20131121221859.GH4138@linux.vnet.ibm.com>
	<20131122155835.GR3866@twins.programming.kicks-ass.net>
	<20131122182632.GW4138@linux.vnet.ibm.com>
	<20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	<20131125173540.GK3694@twins.programming.kicks-ass.net>
	<20131125180250.GR4138@linux.vnet.ibm.com>
	<20131125182715.GG10022@twins.programming.kicks-ass.net>
	<20131125235252.GA4138@linux.vnet.ibm.com>
	<20131126095945.GI10022@twins.programming.kicks-ass.net>
Date: Tue, 26 Nov 2013 11:00:50 -0800
Message-ID: <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 1:59 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> If you now want to weaken this definition, then that needs consideration
> because we actually rely on things like
>
> spin_unlock(l1);
> spin_lock(l2);
>
> being full barriers.

Btw, maybe we should just stop that assumption. The complexity of this
discussion makes me go "maybe we should stop with subtle assumptions
that happen to be obviously true on x86 due to historical
implementations, but aren't obviously true even *there* any more with
the MCS lock".

We already have a concept of

        smp_mb__before_spinlock();
        spin_lock():

for sequences where we *know* we need to make getting a spin-lock be a
full memory barrier. It's free on x86 (and remains so even with the
MCS lock, regardless of any subtle issues, if only because even the
MCS lock starts out with a locked atomic, never mind the contention
slow-case). Of course, that macro is only used inside the scheduler,
and is actually documented to not really be a full memory barrier, but
it handles the case we actually care about.

IOW, where do we really care about the "unlock+lock" is a memory
barrier? And could we make those places explicit, and then do
something similar to the above to them?

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
