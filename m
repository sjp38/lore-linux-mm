Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E30786B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:19:16 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id hu19so1353598vcb.0
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:19:16 -0800 (PST)
Received: from mail-vb0-x236.google.com (mail-vb0-x236.google.com [2607:f8b0:400c:c02::236])
        by mx.google.com with ESMTPS id q6si1607720vdw.10.2013.11.22.14.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 14:19:16 -0800 (PST)
Received: by mail-vb0-f54.google.com with SMTP id p6so1360444vbe.27
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:19:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122215208.GD4138@linux.vnet.ibm.com>
References: <20131122040856.GK4138@linux.vnet.ibm.com>
	<CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
	<20131122062314.GN4138@linux.vnet.ibm.com>
	<20131122151600.GA14988@gmail.com>
	<20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
	<CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
	<20131122203738.GC4138@linux.vnet.ibm.com>
	<CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
	<20131122215208.GD4138@linux.vnet.ibm.com>
Date: Fri, 22 Nov 2013 14:19:15 -0800
Message-ID: <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 1:52 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> You seem to be assuming that the unlock+lock rule applies only when the
> unlock and the lock are executed by the same CPU.  This is not always
> the case.  For example, when the unlock and lock are operating on the
> same lock variable, the critical sections must appear to be ordered from
> the perspective of some other CPU, even when that CPU is not holding
> any lock.

Umm. Isn't that pretty much *guaranteed* by any cache-coherent locking scheme.

The unlock - by virtue of being an unlock - means that all ops within
the first critical region must be visible in the cache coherency
protocol before the unlock is visible. Same goes for the lock on the
other CPU wrt the memory accesses within that locked region.

IOW, I'd argue that any locking model that depends on cache coherency
- as opposed to some magic external locks independent of cache
coherenecy - *has* to follow the rules in that section as far as I can
see. Or it's not a locking model at all, and lets the cache accesses
leak outside of the critical section.

Btw, you can see the difference in the very next section, where you
have *non-cache-coherent* (IO) accesses. So once you have different
rules for the data and the lock accesses, you can get different
results. And yes, there have been broken SMP models (historically)
where locking was "separate" from the memory system, and you could get
coherence only by taking the right lock. But I really don't think we
care about such locking models (for memory - again, IO accesses are
different, exactly because locking and data are in different "ordering
domains").

IOW, I don't think you *can* violate that "locks vs memory accesses"
model with any system where locking is in the same ordering domain as
the data (ie we lock by using cache coherency). And locking using
cache coherency is imnsho the only valid model for SMP. No?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
