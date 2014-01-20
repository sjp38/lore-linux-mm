Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id F10816B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 07:16:23 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id 9so941770ykp.1
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:16:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id t26si986472yhl.205.2014.01.20.04.16.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 04:16:21 -0800 (PST)
Date: Mon, 20 Jan 2014 13:15:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 3/6] MCS Lock: Move mcs_lock/unlock function into its
 own file
Message-ID: <20140120121547.GC31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917304.3138.13.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917304.3138.13.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:24PM -0800, Tim Chen wrote:
> copy to kernel/locking/mcs_spinlock.c
> index 96f14299..44fb092 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/kernel/locking/mcs_spinlock.c
> +/*
> + * asm/processor.h may define arch_mutex_cpu_relax().
> + * If it is not defined, cpu_relax() will be used.
> + */
> +#include <asm/barrier.h>
> +#include <asm/cmpxchg.h>
> +#include <asm/processor.h>
> +#include <linux/compiler.h>
> +#include <linux/mcs_spinlock.h>
> +#include <linux/export.h>
>  
> +#ifndef arch_mutex_cpu_relax
> +# define arch_mutex_cpu_relax() cpu_relax()
> +#endif

Why not include <linux/mutex.h> to obtain arch_mutex_cpu_relax() ?

Now you have duplicated the definition, and in a file unrelated to its
name 'mutex'.

Now, arguable, we should maybe look at renaming the thing now that its
used outside of mutices, but whatever we do, I think its sane to keep a
single 'generic' definition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
