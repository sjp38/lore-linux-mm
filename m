Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id F1B9F6B0088
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 06:40:07 -0500 (EST)
Date: Tue, 20 Nov 2012 11:40:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121120114001.GR8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <20121120104053.GA15302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121120104053.GA15302@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Nov 20, 2012 at 11:40:53AM +0100, Ingo Molnar wrote:
> 
> btw., mind sending me a fuller/longer profile than the one 
> you've sent before? In particular does your system have any 
> vsyscall emulation page fault overhead?
> 

I can't, the results for specjbb got trashed after I moved to 3.7-rc6 and
the old run was incomplete :( I'll have to re-run for profiles. I generally
do not run with profiling enabled because it can distort results very badly.

I went back and re-examined anything else that could distort the results. I
have monitoring other than profiles enabled and the heaviest monitor by
far is reading smaps every 10 seconds to see how processes are currently
distributed between nodes and what CPU they are running on. The intention
was to be able to examine after the fact if the individual java processes
were ending up on the same nodes and scheduled properly.

However, this would impact the peak performance and affect contention on
mmap_sem every 10 seconds as it's possible for the PTE scanner and smaps
reader to contend. Care is taken to only read smaps once per process. So
for each JVM instance, it would read smaps once even though it would
examine where every thread is running. This minimises the distortion.
top is also updating every 10 seconds which will also contend on locks.
The other monitors are relatively harmless and are reading files like
/proc/vmstat, each numastat file every 10 seconds. As before, all tests
had these monitors enabled so they would all have suffered evenly.

Normally when I'm looking at a series I run both with and without monitors. I
report without monitors and use monitors to help debug and problems that
are identified. Unfortunately, time pressure is not allowing me to do that
this time.

> If yes, does the patch below change anything for you?
> 

I'll check it.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
