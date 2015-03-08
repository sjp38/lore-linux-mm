Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 08F526B006E
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 05:54:13 -0400 (EDT)
Received: by wesq59 with SMTP id q59so11371112wes.9
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 01:54:12 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id m9si11878130wia.122.2015.03.08.01.54.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 01:54:11 -0800 (PST)
Received: by wiwh11 with SMTP id h11so2870120wiw.1
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 01:54:10 -0800 (PST)
Date: Sun, 8 Mar 2015 10:54:06 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150308095406.GB15487@gmail.com>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-5-git-send-email-mgorman@suse.de>
 <20150307163657.GA9702@gmail.com>
 <20150307173720.GY3087@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150307173720.GY3087@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org


* Mel Gorman <mgorman@suse.de> wrote:

> Elapsed time is primarily worse on one benchmark -- numa01 which is 
> an adverse workload. The user time differences are also dominated by 
> that benchmark
> 
>                                            4.0.0-rc1             4.0.0-rc1                3.19.0
>                                              vanilla         slowscan-v2r7               vanilla
> Time User-NUMA01                  32883.59 (  0.00%)    35288.00 ( -7.31%)    25695.96 ( 21.86%)
> Time User-NUMA01_THEADLOCAL       17453.20 (  0.00%)    17765.79 ( -1.79%)    17404.36 (  0.28%)
> Time User-NUMA02                   2063.70 (  0.00%)     2063.22 (  0.02%)     2037.65 (  1.26%)
> Time User-NUMA02_SMT                983.70 (  0.00%)      976.01 (  0.78%)      981.02 (  0.27%)

But even for 'numa02', the simplest of the workloads, there appears to 
be some of a regression relative to v3.19, which ought to be beyond 
the noise of the measurement (which would be below 1% I suspect), and 
as such relevant, right?

And the XFS numbers still show significant regression compared to 
v3.19 - and that cannot be ignored as artificial, 'adversarial' 
workload, right?

For example, from your numbers:

xfsrepair
                                    4.0.0-rc1             4.0.0-rc1                3.19.0
                                      vanilla           slowscan-v2               vanilla
...
Amean    real-xfsrepair      507.85 (  0.00%)      459.58 (  9.50%)      447.66 ( 11.85%)
Amean    syst-xfsrepair      519.88 (  0.00%)      281.63 ( 45.83%)      202.93 ( 60.97%)

if I interpret the numbers correctly, it shows that compared to v3.19, 
system time increased by 38% - which is rather significant!

> > So what worries me is that Dave bisected the regression to:
> > 
> >   4d9424669946 ("mm: convert p[te|md]_mknonnuma and remaining page table manipulations")
> > 
> > And clearly your patch #4 just tunes balancing/migration intensity 
> > - is that a workaround for the real problem/bug?
> 
> The patch makes NUMA hinting faults use standard page table handling 
> routines and protections to trap the faults. Fundamentally it's 
> safer even though it appears to cause more traps to be handled. I've 
> been assuming this is related to the different permissions PTEs get 
> and when they are visible on all CPUs. This path is addressing the 
> symptom that more faults are being handled and that it needs to be 
> less aggressive.

But the whole cleanup ought to have been close to an identity 
transformation from the CPU's point of view - and your measurements 
seem to confirm Dave's findings.

And your measurement was on bare metal, while Dave's is on a VM, and 
both show a significant slowdown on the xfs tests even with your 
slow-tuning patch applied, so it's unlikely to be a measurement fluke 
or some weird platform property.

> I've gone through that patch and didn't spot anything else that is 
> doing wrong that is not already handled in this series. Did you spot 
> anything obviously wrong in that patch that isn't addressed in this 
> series?

I didn't spot anything wrong, but is that a basis to go forward and 
work around the regression, in a way that doesn't even recover lost 
performance?

> > And the patch Dave bisected to is a relatively simple patch. Why 
> > not simply revert it to see whether that cures much of the 
> > problem?
> 
> Because it also means reverting all the PROT_NONE handling and going 
> back to _PAGE_NUMA tricks which I expect would be naked by Linus.

Yeah, I realize that (and obviously I support the PROT_NONE direction 
that Peter Zijlstra prototyped with the original sched/numa series), 
but can we leave this much of a regression on the table?

I hate to be such a pain in the neck, but especially the 'down tuning' 
of the scanning intensity will make an apples to apples comparison 
harder!

I'd rather not do the slow-tuning part and leave sucky performance in 
place for now and have an easy method plus the motivation to find and 
fix the real cause of the regression, than to partially hide it this 
way ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
