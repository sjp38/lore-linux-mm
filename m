Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 4724D6B0075
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 22:33:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so703514pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:33:19 -0800 (PST)
Date: Tue, 20 Nov 2012 19:33:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: numa/core regressions fixed - more testers wanted
In-Reply-To: <20121120175647.GA23532@gmail.com>
Message-ID: <alpine.DEB.2.00.1211201913410.6458@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com> <20121120175647.GA23532@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> The current updated table of performance results is:
> 
> -------------------------------------------------------------------------
>   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
>   [ lower is better ]   -----  --------   |  -------------    -----------
>                                           |
>   numa01                340.3    192.3    |      139.4          +144.1%
>   numa01_THREAD_ALLOC   425.1    135.1    |	 121.1          +251.0%
>   numa02                 56.1     25.3    |       17.5          +220.5%
>                                           |
>   [ SPECjbb transactions/sec ]            |
>   [ higher is better         ]            |
>                                           |
>   SPECjbb 1x32 +THP      524k     507k    |	  638k           +21.7%
>   SPECjbb 1x32 !THP      395k             |       512k           +29.6%
>                                           |
> -----------------------------------------------------------------------
>                                           |
>   [ SPECjbb multi-4x8 ]                   |
>   [ tx/sec            ]  v3.7             |  numa/core-v16
>   [ higher is better  ] -----             |  -------------
>                                           |
>               +THP:      639k             |       655k            +2.5%
>               -THP:      510k             |       517k            +1.3%
> 
> So I think I've addressed all regressions reported so far - if 
> anyone can still see something odd, please let me know so I can 
> reproduce and fix it ASAP.
> 

I started profiling on a new machine that is an exact duplicate of the 
16-way, 4 node, 32GB machine I was profiling with earlier to rule out any 
machine-specific problems.  I pulled master and ran new comparisons with 
THP enabled at c418de93e398 ("Merge branch 'x86/mm'"): 

  CONFIG_NUMA_BALANCING disabled	136521.55 SPECjbb2005 bops
  CONFIG_NUMA_BALANCING enabled		132476.07 SPECjbb2005 bops (-3.0%)

Aside: neither 4739578c3ab3 ("x86/mm: Don't flush the TLB on #WP pmd 
fixups") nor 01e9c2441eee ("x86/vsyscall: Add Kconfig option to use native 
vsyscalls and switch to it") significantly improved upon the throughput on 
this system.

Over the past 24 hours, however, throughput has significantly improved 
from a 6.3% regression to a 3.0% regression because of 246c0b9a1caf ("mm, 
numa: Turn 4K pte NUMA faults into effective hugepage ones")!

One request: I noticed that the entire patchset doesn't add any fields to 
/proc/vmstat through count_vm_event() like thp did, which I found very 
useful when profiling that set when it was being reviewed.  Would it be 
possible to add some vm events to the balancing code so we can capture 
data of how the NUMA balancing is behaving?  Their usefulness would extend 
beyond just the review period.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
