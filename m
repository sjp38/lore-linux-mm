Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id E534B6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 07:20:25 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 142so4282325ykq.2
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:20:25 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id n44si1035047yhn.65.2014.01.20.04.20.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 04:20:24 -0800 (PST)
Date: Mon, 20 Jan 2014 13:19:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 5/6] MCS Lock: allow architectures to hook in to
 contended paths
Message-ID: <20140120121948.GD31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917311.3138.15.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917311.3138.15.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:31PM -0800, Tim Chen wrote:
> +#ifndef arch_mcs_spin_lock_contended
> +/*
> + * Using smp_load_acquire() provides a memory barrier that ensures
> + * subsequent operations happen after the lock is acquired.
> + */
> +#define arch_mcs_spin_lock_contended(l)					\
> +	while (!(smp_load_acquire(l))) {				\
> +		arch_mutex_cpu_relax();					\
> +	}
> +#endif

I think that wants to be:

#define arch_mcs_spin_lock_contended(l)				\
do {								\
	while (!smp_load_acquire(l))				\
		arch_mutex_cpu_relax();				\
} while (0)

So that we properly eat the ';' in: arch_mcs_spin_lock_contended(l);.

> +#ifndef arch_mcs_spin_unlock_contended
> +/*
> + * smp_store_release() provides a memory barrier to ensure all
> + * operations in the critical section has been completed before
> + * unlocking.
> + */
> +#define arch_mcs_spin_unlock_contended(l)				\
> +	smp_store_release((l), 1)
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
