Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA6B6B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:09:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u78so1943197wmd.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:09:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l72sor2895662wmi.72.2017.10.18.03.09.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 03:09:47 -0700 (PDT)
Date: Wed, 18 Oct 2017 12:09:44 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171018100944.g2mc6yorhtm5piom@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> Johan Hovold reported a performance regression by crossrelease like:
> 
> > Boot time (from "Linux version" to login prompt) had in fact doubled
> > since 4.13 where it took 17 seconds (with my current config) compared to
> > the 35 seconds I now see with 4.14-rc4.
> >
> > I quick bisect pointed to lockdep and specifically the following commit:
> >
> > 	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
> > 	               of a crosslock")
> >
> > which I've verified is the commit which doubled the boot time (compared
> > to 28a903f63ec0^) (added by lockdep crossrelease series [1]).
> 
> Currently crossrelease performs unwind on every acquisition. But, that
> overloads systems too much. So this patch makes unwind optional and set
> it to N as default. Instead, it records only acquire_ip normally. Of
> course, unwind is sometimes required for full analysis. In that case, we
> can set CROSSRELEASE_STACK_TRACE to Y and use it.
> 
> In my qemu ubuntu machin (x86_64, 4 cores, 512M), the regression was
> fixed like, measuring timestamp of "Freeing unused kernel memory":
> 
> 1. No lockdep enabled
>    Average : 1.543353 secs
> 
> 2. Lockdep enabled
>    Average : 1.570806 secs
> 
> 3. Lockdep enabled + crossrelease enabled
>    Average : 1.870317 secs
> 
> 4. Lockdep enabled + crossrelease enabled + this patch applied
>    Average : 1.574143 secs

Ok, that looks really nice, recovers almost all of the lost performance, right?

Could you please run perf stat --null --repeat type of stats of a boot test (for 
example running init=/bin/true should boot up Qemu and make it exit), so that we 
can see how stable the numbers are and what the real slowdown is?

> +config CROSSRELEASE_STACK_TRACE
> +	bool "Record more than one entity of stack trace in crossrelease"
> +	depends on LOCKDEP_CROSSRELEASE
> +	default n
> +	help
> +	 Crossrelease feature needs to record stack traces for all
> +	 acquisitions for later use. And only acquire_ip is normally
> +	 recorded because the unwind operation is too expensive. However,
> +	 sometimes more than acquire_ip are required for full analysis.
> +	 In the case that we need to record more than one entity of
> +	 stack trace using unwind, this feature would be useful, with
> +	 taking more overhead.
> +
> +	 If unsure, say N.

Fixed the text for you:

> +	 The lockdep "cross-release" feature needs to record stack traces
> +	 (of calling functions) for all acquisitions, for eventual later use
> +	 during analysis.
> +	 By default only a single caller is recorded, because the unwind
> +	 operation can be very expensive with deeper stack chains.
> +	 However, sometimes deeper traces are required for full analysis.
> +	 This option turns on the saving of the full stack trace entries.
> +
> +	 If unsure, say N.

BTW., have you attempted limiting the depth of the stack traces? I suspect more 
than 2-4 are rarely required to disambiguate the calling context.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
