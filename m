Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id B44ED6B003D
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:42:43 -0400 (EDT)
Date: Mon, 29 Jul 2013 14:42:51 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
Message-ID: <20130729194250.GC26476@sgi.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
 <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
 <20130618164537.GJ16067@sgi.com>
 <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
 <20130619093212.GX3658@sgi.com>
 <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com>
 <20130620022739.GF3658@sgi.com>
 <alpine.DEB.2.02.1306191939250.24151@chino.kir.corp.google.com>
 <1371697844.5739.29.camel@marge.simpson.net>
 <alpine.DEB.2.02.1306201334460.24145@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306201334460.24145@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Mike Galbraith <bitbucket@online.de>, Robin Holt <holt@sgi.com>, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Alex Thorlton <athorlton@sgi.com>

We've re-evaluated the need for a patch to support some sort of finer
grained control over thp, and, based on some tests performed by our 
benchmarking team, we're seeing that we'd definitely still like to
implement some method to support this.  Here's an e-mail from John 
Baron (jbaron@sgi.com), on our benchmarking team,  containing some data
which shows a decrease in performance for some SPEC OMP benchmarks when
thp is enabled:

> Here are results for SPEC OMP benchmarks on UV2 using 512 threads / 64
> sockets.  These show the performance ratio for jobs run with THP
> disabled versus THP enabled (so > 1.0 means THP disabled is faster).  
> One possible reason for lower performance with THP enabled is that the 
> larger page granularity can result in more remote data accesses.
> 
> 
> SPEC OMP2012:
> 
> 350.md          1.0
> 351.bwaves      1.3
> 352.nab         1.0
> 357.bt331       0.9
> 358.botsalgn    1.0
> 359.botsspar    1.1
> 360.ilbdc       1.8
> 362.fma3d       1.0
> 363.swim        1.4
> 367.imagick     0.9
> 370.mgrid331    1.1
> 371.applu331    0.9
> 372.smithwa     1.0
> 376.kdtree      1.0
> 
> SPEC OMPL2001:
> 
> 311.wupwise_l   1.1
> 313.swim_l      1.5
> 315.mgrid_l     1.0
> 317.applu_l     1.1
> 321.equake_l    5.8
> 325.apsi_l      1.5
> 327.gafort_l    1.0
> 329.fma3d_l     1.0
> 331.art_l       0.8
> 
> One could argue that real-world applications could be modified to avoid
> these kinds of effects, but (a) it is not always possible to modify code
> (e.g. in benchmark situations) and (b) even if it is possible to do so,
> it is not necessarily easy to do so (e.g. for customers with large
> legacy Fortran codes).
> 
> We have also observed on Intel Sandy Bridge processors that, as
> counter-intuitive as it may seem, local memory bandwidth is actually
> slightly lower with THP enabled (1-2%), even with unit stride data
> accesses.  This may not seem like much of a performance hit but
> it is important for HPC workloads.  No code modification will help here.

In light of the previous issues discussed in this thread, and some
suggestions from David Rientjes:

> why not make it per-process so users don't have to configure
> cpusets to control it?

Robin and I have come up with a proposal for a way to replicate behavior
similar to what this patch introduced, only on a per-process level
instead of at the cpuset level.

Our idea would be to add a flag somewhere in the task_struct to keep
track of whether or not thp is enabled for each task.  The flag would be
controlled by an additional option included in prctl(), allowing
programmers to set/unset this flag via the prctl() syscall.  We would 
also introduce some code into the clone() syscall to ensure that this 
flag is copied down from parent to child tasks when necessary.  The flag
would be checked in the same place the the per-cpuset flag was checked
in my original patch, thereby allowing the same behavior to be
replicated on a per-process level.

In this way, we will also be able to get static binaries to behave
appropriately by setting this flag in a userland program, and then
having that program exec the static binary for which we need to disable
thp.

This solution allows us to incorporate the behavior that we're looking
for into the kernel, without abusing cpusets for the purpose of
containerization.

Please let me know if anyone has any objections to this approach, or if
you have any suggestions as to how we could improve upon this idea.

Thanks!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
