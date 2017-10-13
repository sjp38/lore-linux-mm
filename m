Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5B96B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:03:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f31so2021611lfi.3
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:03:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 17sor86780ljp.68.2017.10.13.02.03.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 02:03:31 -0700 (PDT)
Date: Fri, 13 Oct 2017 11:03:33 +0200
From: Johan Hovold <johan@kernel.org>
Subject: Dramatic lockdep slowdown in 4.14
Message-ID: <20171013090333.GA17356@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi,

I had noticed that the BeagleBone Black boot time appeared to have
increased significantly with 4.14 and yesterday I finally had time to
investigate it.

Boot time (from "Linux version" to login prompt) had in fact doubled
since 4.13 where it took 17 seconds (with my current config) compared to
the 35 seconds I now see with 4.14-rc4.

I quick bisect pointed to lockdep and specifically the following commit:

	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
	               of a crosslock")

which I've verified is the commit which doubled the boot time (compared
to 28a903f63ec0^) (added by lockdep crossrelease series [1]).

I also verified that simply disabling CONFIG_PROVE_LOCKING on 4.14-rc4
brought boot time down to about 14 seconds.

Now since it's lockdep I guess this can't really be considered a
regression if these changes did improve lockdep correctness, but still,
this dramatic slow down essentially forces me to disable PROVE_LOCKING
by default on this system.

Is this lockdep slowdown expected and desirable?

Johan

[1] https://lkml.kernel.org/r/1502089981-21272-1-git-send-email-byungchul.park@lge.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
