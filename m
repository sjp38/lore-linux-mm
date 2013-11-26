Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f52.google.com (mail-vb0-f52.google.com [209.85.212.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D54B6B009B
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:32:27 -0500 (EST)
Received: by mail-vb0-f52.google.com with SMTP id f13so4276754vbg.11
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:32:27 -0800 (PST)
Received: from mail-ve0-x22b.google.com (mail-ve0-x22b.google.com [2607:f8b0:400c:c01::22b])
        by mx.google.com with ESMTPS id q6si8222092vdw.114.2013.11.26.11.32.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 11:32:26 -0800 (PST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so4274146veb.2
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:32:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131126192003.GA4137@linux.vnet.ibm.com>
References: <20131121221859.GH4138@linux.vnet.ibm.com>
	<20131122155835.GR3866@twins.programming.kicks-ass.net>
	<20131122182632.GW4138@linux.vnet.ibm.com>
	<20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	<20131125173540.GK3694@twins.programming.kicks-ass.net>
	<20131125180250.GR4138@linux.vnet.ibm.com>
	<20131125182715.GG10022@twins.programming.kicks-ass.net>
	<20131125235252.GA4138@linux.vnet.ibm.com>
	<20131126095945.GI10022@twins.programming.kicks-ass.net>
	<CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
	<20131126192003.GA4137@linux.vnet.ibm.com>
Date: Tue, 26 Nov 2013 11:32:25 -0800
Message-ID: <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 11:20 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> There are several places in RCU that assume unlock+lock is a full
> memory barrier, but I would be more than happy to fix them up given
> an smp_mb__after_spinlock() and an smp_mb__before_spinunlock(), or
> something similar.

A "before_spinunlock" would actually be expensive on x86.

So I'd *much* rather see the "after_spinlock()" version, if that is
sufficient for all users. And it should be, since that's the
traditional x86 behavior that we had before the MCS lock discussion.

Because it's worth noting that a spin_lock() is still a full memory
barrier on x86, even with the MCS code, *assuming it is done in the
context of the thread needing the memory barrier". And I suspect that
is much more generally true than just x86. It's the final MCS hand-off
of a lock that is pretty weak with just a local read. The full lock
sequence is always going to be much stronger, if only because it will
contain a write somewhere shared as well.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
