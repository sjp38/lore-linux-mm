Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D14876B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:23:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y10so2180258wmd.4
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:23:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s14si10156874wrf.380.2017.10.18.06.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 06:23:40 -0700 (PDT)
Date: Wed, 18 Oct 2017 15:23:32 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
In-Reply-To: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
Message-ID: <alpine.DEB.2.20.1710181519580.1925@nanos>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, 18 Oct 2017, Byungchul Park wrote:
>  #ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
>  #define MAX_XHLOCK_TRACE_ENTRIES 5
> +#else
> +#define MAX_XHLOCK_TRACE_ENTRIES 1
> +#endif
>  
>  /*
>   * This is for keeping locks waiting for commit so that true dependencies
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index e36e652..5c2ddf2 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -4863,8 +4863,13 @@ static void add_xhlock(struct held_lock *hlock)
>  	xhlock->trace.nr_entries = 0;
>  	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
>  	xhlock->trace.entries = xhlock->trace_entries;
> +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
>  	xhlock->trace.skip = 3;
>  	save_stack_trace(&xhlock->trace);
> +#else
> +	xhlock->trace.nr_entries = 1;
> +	xhlock->trace.entries[0] = hlock->acquire_ip;
> +#endif

Hmm. Would it be possible to have this switchable at boot time via a
command line parameter? So in case of a splat with no stack trace, one
could just reboot and set something like 'lockdep_fullstack' on the kernel
command line to get the full data without having to recompile the kernel.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
