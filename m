Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id BB6216B0075
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 22:23:16 -0500 (EST)
Message-ID: <50AC4912.7040503@redhat.com>
Date: Tue, 20 Nov 2012 22:22:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: numa/core regressions fixed - more testers wanted
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>  <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>  <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>  <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>  <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com>  <20121120175647.GA23532@gmail.com> <1353462853.31820.93.camel@oc6622382223.ibm.com>
In-Reply-To: <1353462853.31820.93.camel@oc6622382223.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: habanero@linux.vnet.ibm.com
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 11/20/2012 08:54 PM, Andrew Theurer wrote:

> I can confirm single JVM JBB is working well for me.  I see a 30%
> improvement over autoNUMA.  What I can't make sense of is some perf
> stats (taken at 80 warehouses on 4 x WST-EX, 512GB memory):

AutoNUMA does not have native THP migration, that may explain some
of the difference.

> tips numa/core:
>
>       5,429,632,865 node-loads
>       3,806,419,082 node-load-misses(70.1%)
>       2,486,756,884 node-stores
>       2,042,557,277 node-store-misses(82.1%)
>       2,878,655,372 node-prefetches
>       2,201,441,900 node-prefetch-misses
>
> autoNUMA:
>
>       4,538,975,144 node-loads
>       2,666,374,830 node-load-misses(58.7%)
>       2,148,950,354 node-stores
>       1,682,942,931 node-store-misses(78.3%)
>       2,191,139,475 node-prefetches
>       1,633,752,109 node-prefetch-misses
>
> The percentage of misses is higher for numa/core.  I would have expected
> the performance increase be due to lower "node-misses", but perhaps I am
> misinterpreting the perf data.

Lack of native THP migration may be enough to explain the
performance difference, despite autonuma having better node
locality.

>> Next I'll work on making multi-JVM more of an improvement, and
>> I'll also address any incoming regression reports.
>
> I have issues with multiple KVM VMs running either JBB or
> dbench-in-tmpfs, and I suspect whatever I am seeing is similar to
> whatever multi-jvm in baremetal is.  What I typically see is no real
> convergence of a single node for resource usage for any of the VMs.  For
> example, when running 8 VMs, 10 vCPUs each, a VM may have the following
> resource usage:

This is an issue.  I have tried understanding the new local/shared
and shared task grouping code, but have not wrapped my mind around
that code yet.

I will have to look at that code a few more times, and ask more
questions of Ingo and Peter (and maybe ask some of the same questions
again - I see that some of my comments were addressed in the next
version of the patch, but the email never got a reply).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
