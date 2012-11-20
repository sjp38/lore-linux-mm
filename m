Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 4AC956B0073
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 05:20:17 -0500 (EST)
Date: Tue, 20 Nov 2012 10:20:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121120102010.GP8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121120071704.GA14199@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

> > Ingo, stop doing this kind of crap.
> > 
> > Let's make it clear: if the NUMA patches continue to regress 
> > performance for reasonable loads (and that very much includes 
> > "no THP") then they won't be merged.
> > 
> > You seem to be in total denial. Every time Mel sends out 
> > results that show that your patches MAKE PERFORMANCE WORSE you 
> > blame Mel, or blame the load, and never seem to admit that 
> > performance got worse.
> 
> No doubt numa/core should not regress with THP off or on and 
> I'll fix that.
> 
> As a background, here's how SPECjbb gets slower on mainline 
> (v3.7-rc6) if you boot Mel's kernel config and turn THP forcibly
> off:
> 
>   (avg: 502395 ops/sec)
>   (avg: 505902 ops/sec)
>   (avg: 509271 ops/sec)
> 
>   # echo never > /sys/kernel/mm/transparent_hugepage/enabled
> 
>   (avg: 376989 ops/sec)
>   (avg: 379463 ops/sec)
>   (avg: 378131 ops/sec)
> 
> A ~30% slowdown.
> 
> [ How do I know? I asked for Mel's kernel config days ago and
>   actually booted Mel's very config in the past few days, 
>   spending hours on testing it on 4 separate NUMA systems, 
>   trying to find Mel's regression. In the past Mel was a 
>   reliable tester so I blindly trusted his results. Was that 
>   some weird sort of denial on my part? :-) ]
> 
> Every time a regression is reported I take it seriously - and 
> there were performance regression reports against numa/core not 
> just from Mel and I'm sure there will be more in the future. For 
> example I'm taking David Rijentje's fresh performance regression 
> report seriously as well.
> 
> What I have some problem with is Mel sending me his kernel 
> config as the thing he tested, and which config included:
> 
>   CONFIG_TRANSPARENT_HUGEPAGE=y
>   CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> 
> but he apparently went and explicitly disabled THP on top of 
> that - which was just a weird choice of 'negative test tuning' 
> to keep unreported.

I've already apologised for this omission and I'll apologise again if
necessary. The whole point of implementing MM Tests was to mitigate exactly
this sort of situation where the testing conditions are suspicious so the
configuration file and scripts can be rechecked. I was assuming the lack
of THP usage was due to the JVM using shared memory because a few years ago
the JVM I was using at the time did this if configured for hugepage usage.
Assumptions made a complete ass out of me here. When I did the recheck of
what the JVM was actually doing and reexamined the configuration, I saw
the mistake and admitted it immediately.

I want to be absolutely clear that it was unintentional to disable THP like
this which is why I did not report it. I did not deliberately hide such
information because that would be completely unacceptable. The root of the
mistake is actually from a few years ago where tests would be configured
to run with base pages, huge pages and transparent hugepages -- similar to
how we might currently test vanilla kernel, hard bindings and automatic
migration. Because of their history, some mmtest scripts support running
with multiple page sizes and I neglected to properly identify this and
retrofit a "default hugepage" configuration.

I've also been already clear that this was done for *all* the specjbb
tests. It was still a mistake but it was evenly applied.

I've added two extra configuration files to run specjbb single and multi
JVMs with THP enabled. It takes about 1.5 to 2 hours to complete a single
test which means a full battery of tests for autonuma, vanilla kernel and
schednuma will take a little over 24 hours (4 specjbb tests, autobench and
a few basic performance tests like kernbench, hackbench etc). They will
not be running back-to-back as the machine is not dedicated to this. I'll
report when they're done.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
