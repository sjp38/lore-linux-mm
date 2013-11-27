Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 445B26B0035
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 20:05:16 -0500 (EST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so4749167veb.30
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:05:16 -0800 (PST)
Received: from mail-vb0-x236.google.com (mail-vb0-x236.google.com [2607:f8b0:400c:c02::236])
        by mx.google.com with ESMTPS id uh5si20246032vcb.127.2013.11.26.17.05.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 17:05:15 -0800 (PST)
Received: by mail-vb0-f54.google.com with SMTP id p6so4576035vbe.27
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:05:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131127003904.GI4137@linux.vnet.ibm.com>
References: <20131125173540.GK3694@twins.programming.kicks-ass.net>
	<20131125180250.GR4138@linux.vnet.ibm.com>
	<20131125182715.GG10022@twins.programming.kicks-ass.net>
	<20131125235252.GA4138@linux.vnet.ibm.com>
	<20131126095945.GI10022@twins.programming.kicks-ass.net>
	<CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
	<20131126192003.GA4137@linux.vnet.ibm.com>
	<CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
	<20131126225136.GG4137@linux.vnet.ibm.com>
	<CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
	<20131127003904.GI4137@linux.vnet.ibm.com>
Date: Tue, 26 Nov 2013 17:05:14 -0800
Message-ID: <CA+55aFwhC0kk6TwsTsFEuoUoTe45qBza2=Nf+mrbPONyEGx-Ug@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 4:39 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Cross-CPU ordering.

Ok, in that case I *suspect* we want an actual "spin_lock_mb()"
primitive, because if we go with the MCS lock approach, it's quite
possible that we find cases where the fast-case is already a barrier
(like it is on x86 by virtue of the locked instruction) but the MCS
case then is not. And then a separate barrier wouldn't be able to make
that kind of judgement.

Or maybe we don't care enough. It *sounds* like on x86, we do probably
already get the cross-cpu case for free, and on other architectures we
may always need the memory barrier, so maybe the whole
"mb_after_spin_lock()" thing is fine.

Ugh.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
