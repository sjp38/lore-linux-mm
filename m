Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8939A6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:42:04 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id d13so4204726wiw.0
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:41:47 -0800 (PST)
Received: from mail-ea0-x22a.google.com (mail-ea0-x22a.google.com [2a00:1450:4013:c01::22a])
        by mx.google.com with ESMTPS id hm6si2965199wjb.5.2014.01.21.02.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 02:41:47 -0800 (PST)
Received: by mail-ea0-f170.google.com with SMTP id k10so3673031eaj.1
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:41:47 -0800 (PST)
Date: Tue, 21 Jan 2014 11:41:40 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 4/6] MCS Lock: Move mcs_lock/unlock function into its
 own
Message-ID: <20140121104140.GA4092@gmail.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
 <1390267471.3138.38.camel@schen9-DESK>
 <20140121101915.GS31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121101915.GS31570@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Jan 20, 2014 at 05:24:31PM -0800, Tim Chen wrote:
> > +EXPORT_SYMBOL_GPL(mcs_spin_lock);
> > +EXPORT_SYMBOL_GPL(mcs_spin_unlock);
> 
> Do we really need the EXPORTs? The only user so far is mutex and that's
> core code. The other planned users are rwsems and rwlocks, for both it
> would be in the slow path, which is also core code.
>
> We should generally only add EXPORTs once theres a need.

In fact I'd argue the hot path needs to be inlined.

We only don't inline regular locking primitives because it would blow 
up the kernel's size in too many critical places.

But inlining an _internal_ locking implementation used in just a 
handful of places is a no-brainer...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
