Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0336B0283
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 03:27:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so10792437wmu.2
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 00:27:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o15sor1160644wrg.56.2017.10.14.00.27.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 00:27:03 -0700 (PDT)
Date: Sat, 14 Oct 2017 09:26:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Dramatic lockdep slowdown in 4.14
Message-ID: <20171014072659.f2yr6mhm5ha3eou7@gmail.com>
References: <20171013090333.GA17356@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013090333.GA17356@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johan Hovold <johan@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org


* Johan Hovold <johan@kernel.org> wrote:

> Hi,
> 
> I had noticed that the BeagleBone Black boot time appeared to have
> increased significantly with 4.14 and yesterday I finally had time to
> investigate it.
> 
> Boot time (from "Linux version" to login prompt) had in fact doubled
> since 4.13 where it took 17 seconds (with my current config) compared to
> the 35 seconds I now see with 4.14-rc4.
> 
> I quick bisect pointed to lockdep and specifically the following commit:
> 
> 	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
> 	               of a crosslock")
> 
> which I've verified is the commit which doubled the boot time (compared
> to 28a903f63ec0^) (added by lockdep crossrelease series [1]).
> 
> I also verified that simply disabling CONFIG_PROVE_LOCKING on 4.14-rc4
> brought boot time down to about 14 seconds.
> 
> Now since it's lockdep I guess this can't really be considered a
> regression if these changes did improve lockdep correctness, but still,
> this dramatic slow down essentially forces me to disable PROVE_LOCKING
> by default on this system.
> 
> Is this lockdep slowdown expected and desirable?

It's not desirable at all.

Does the patch below fix the regression for you - or does the introduction and 
handling of ->nr_acquire hurt as well?

Thanks,

	Ingo

====================>
 lib/Kconfig.debug | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c6401d325b0e..f5b40c1668ea 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1138,8 +1138,8 @@ config PROVE_LOCKING
 	select DEBUG_MUTEXES
 	select DEBUG_RT_MUTEXES if RT_MUTEXES
 	select DEBUG_LOCK_ALLOC
-	select LOCKDEP_CROSSRELEASE
-	select LOCKDEP_COMPLETIONS
+#	select LOCKDEP_CROSSRELEASE
+#	select LOCKDEP_COMPLETIONS
 	select TRACE_IRQFLAGS
 	default n
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
