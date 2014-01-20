Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7602B6B0036
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 21:35:32 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id i57so1208893yha.32
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 18:35:32 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id n44si25070858yhn.265.2014.01.19.18.35.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Jan 2014 18:35:31 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 19 Jan 2014 19:35:30 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2DC2D3E4003F
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:35:28 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0K2ZS265702122
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:35:28 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s0K2chdh013285
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:38:45 -0700
Date: Sun, 19 Jan 2014 18:35:24 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
Message-ID: <20140120023524.GN10038@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917316.3138.16.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917316.3138.16.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:36PM -0800, Tim Chen wrote:
> This patch adds Kconfig entries to allow architectures to hook into the
> MCS lock/unlock functions in the contended case.
> 
> From: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  arch/Kconfig                 | 3 +++
>  include/linux/mcs_spinlock.h | 8 ++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 80bbb8c..8a2a056 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -303,6 +303,9 @@ config HAVE_CMPXCHG_LOCAL
>  config HAVE_CMPXCHG_DOUBLE
>  	bool
> 
> +config HAVE_ARCH_MCS_LOCK
> +	bool
> +
>  config ARCH_WANT_IPC_PARSE_VERSION
>  	bool
> 
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> index d54bb23..d2c02ad 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/include/linux/mcs_spinlock.h
> @@ -12,6 +12,14 @@
>  #ifndef __LINUX_MCS_SPINLOCK_H
>  #define __LINUX_MCS_SPINLOCK_H
> 
> +/*
> + * An architecture may provide its own lock/unlock functions for the
> + * contended case.
> + */
> +#ifdef CONFIG_HAVE_ARCH_MCS_LOCK
> +#include <asm/mcs_spinlock.h>
> +#endif
> +
>  struct mcs_spinlock {
>  	struct mcs_spinlock *next;
>  	int locked; /* 1 if lock acquired */
> -- 
> 1.7.11.7
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
