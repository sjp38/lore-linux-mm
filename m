Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1309C6B0031
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 05:17:31 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so8451277pad.11
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 02:17:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id qj1si7593462pbc.234.2013.11.05.02.17.28
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 02:17:29 -0800 (PST)
Date: Tue, 5 Nov 2013 10:15:38 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 4/4] MCS Lock: Make mcs_spinlock.h includable in other
 files
Message-ID: <20131105101538.GA26895@mudshark.cambridge.arm.com>
References: <cover.1383604526.git.tim.c.chen@linux.intel.com>
 <1383608233.11046.263.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383608233.11046.263.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

Hello,

On Mon, Nov 04, 2013 at 11:37:13PM +0000, Tim Chen wrote:
> The following changes are made to enable mcs_spinlock.h file to be
> widely included in other files without causing problem:
> 
> 1) Include a number of prerequisite header files and define
>    arch_mutex_cpu_relax(), if not previously defined.
> 2) Separate out mcs_spin_lock() into a mcs_spinlock.c file.
> 3) Make mcs_spin_unlock() an inlined function.

[...]

> +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +{
> +	struct mcs_spinlock *prev;
> +
> +	/* Init node */
> +	node->locked = 0;
> +	node->next   = NULL;
> +
> +	prev = xchg(lock, node);
> +	if (likely(prev == NULL)) {
> +		/* Lock acquired */
> +		node->locked = 1;
> +		return;
> +	}
> +	ACCESS_ONCE(prev->next) = node;
> +	smp_wmb();
> +	/* Wait until the lock holder passes the lock down */
> +	while (!ACCESS_ONCE(node->locked))
> +		arch_mutex_cpu_relax();
> +}

You have the barrier in a different place than the version in the header
file; is this intentional?

Also, why is an smp_wmb() sufficient (as opposed to a full smp_mb()?). Are
there restrictions on the types of access that can occur in the critical
section?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
