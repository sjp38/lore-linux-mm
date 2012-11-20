Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 80EEF6B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 19:50:05 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4057817pad.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 16:50:04 -0800 (PST)
Date: Mon, 19 Nov 2012 16:50:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
In-Reply-To: <20121119162909.GL8218@suse.de>
Message-ID: <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, 19 Nov 2012, Mel Gorman wrote:

> I was not able to run a full sets of tests today as I was distracted so
> all I have is a multi JVM comparison. I'll keep it shorter than average
> 
>                           3.7.0                 3.7.0
>                  rc5-stats-v4r2   rc5-schednuma-v16r1
> TPut   1     101903.00 (  0.00%)     77651.00 (-23.80%)
> TPut   2     213825.00 (  0.00%)    160285.00 (-25.04%)
> TPut   3     307905.00 (  0.00%)    237472.00 (-22.87%)
> TPut   4     397046.00 (  0.00%)    302814.00 (-23.73%)
> TPut   5     477557.00 (  0.00%)    364281.00 (-23.72%)
> TPut   6     542973.00 (  0.00%)    420810.00 (-22.50%)
> TPut   7     540466.00 (  0.00%)    448976.00 (-16.93%)
> TPut   8     543226.00 (  0.00%)    463568.00 (-14.66%)
> TPut   9     513351.00 (  0.00%)    468238.00 ( -8.79%)
> TPut   10    484126.00 (  0.00%)    457018.00 ( -5.60%)
> TPut   11    467440.00 (  0.00%)    457999.00 ( -2.02%)
> TPut   12    430423.00 (  0.00%)    447928.00 (  4.07%)
> TPut   13    445803.00 (  0.00%)    434823.00 ( -2.46%)
> TPut   14    427388.00 (  0.00%)    430667.00 (  0.77%)
> TPut   15    437183.00 (  0.00%)    423746.00 ( -3.07%)
> TPut   16    423245.00 (  0.00%)    416259.00 ( -1.65%)
> TPut   17    417666.00 (  0.00%)    407186.00 ( -2.51%)
> TPut   18    413046.00 (  0.00%)    398197.00 ( -3.59%)
> 
> This version of the patches manages to cripple performance entirely. I
> do not have a single JVM comparison available as the machine has been in
> use during the day. I accept that it is very possible that the single
> JVM figures are better.
> 

I confirm that SPECjbb2005 1.07 -Xmx4g regresses in terms of throughput on 
my 16-way, 4 node system with 32GB of memory using 16 warehouses and 240 
measurement seconds.  I averaged the throughput for five runs on each 
kernel.

Java(TM) SE Runtime Environment (build 1.6.0_06-b02)
Java HotSpot(TM) 64-Bit Server VM (build 10.0-b22, mixed mode)

Both kernels have
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y

numa/core at 01aa90068b12 ("sched: Use the best-buddy 'ideal cpu' in 
balancing decisions") with

CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_NUMA_GENERIC_PGPROT=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_HUGEPAGE=y
CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT=y
CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE=y

had a throughput of 128315.19 SPECjbb2005 bops.

numa/core at ec05a2311c35 ("Merge branch 'sched/urgent' into sched/core") 
had an average throughput of 136918.34 SPECjbb2005 bops, which is a 6.3% 
regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
