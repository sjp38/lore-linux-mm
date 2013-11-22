Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id D17F66B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:06:42 -0500 (EST)
Received: by mail-ve0-f170.google.com with SMTP id oy12so1267231veb.1
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:06:42 -0800 (PST)
Received: from mail-vb0-x22d.google.com (mail-vb0-x22d.google.com [2607:f8b0:400c:c02::22d])
        by mx.google.com with ESMTPS id tq4si13016162vdc.103.2013.11.22.11.06.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 11:06:41 -0800 (PST)
Received: by mail-vb0-f45.google.com with SMTP id p14so1139265vbm.4
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:06:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122184937.GX4138@linux.vnet.ibm.com>
References: <20131120214402.GM4138@linux.vnet.ibm.com>
	<1384991514.11046.504.camel@schen9-DESK>
	<20131121045333.GO4138@linux.vnet.ibm.com>
	<CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
	<20131121225208.GJ4138@linux.vnet.ibm.com>
	<CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
	<20131122040856.GK4138@linux.vnet.ibm.com>
	<CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
	<20131122062314.GN4138@linux.vnet.ibm.com>
	<20131122151600.GA14988@gmail.com>
	<20131122184937.GX4138@linux.vnet.ibm.com>
Date: Fri, 22 Nov 2013 11:06:41 -0800
Message-ID: <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 10:49 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> You see, my problem is not the "crazy ordering" DEC Alpha, Itanium,
> PowerPC, or even ARM.  It is really obvious what instructions to use in
> a stiffened-up smp_store_release() for those guys: "mb" for DEC Alpha,
> "st.rel" for Itanium, "sync" for PowerPC, and "dmb" for ARM.  Believe it
> or not, my problem is instead with good old tightly ordered x86.
>
> We -could- just put an mfence into x86's smp_store_release() and
> be done with it

Why would you bother? The *acquire* has a memory barrier. End of
story. On x86, it has to (since otherwise a load inside the locked
region could be re-ordered wrt the write that takes the lock).

Basically, any time you think you need to add a memory barrier on x86,
you should go "I'm doing something wrong". It's that simple.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
