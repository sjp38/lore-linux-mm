Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E2DD76B005D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 07:35:07 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1285331bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 04:35:06 -0800 (PST)
Date: Mon, 10 Dec 2012 13:35:01 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210123501.GA8968@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210050710.GC22164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121210050710.GC22164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


hi Srikar,

* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> > 
> > Either way, last night I applied a patch on top of latest tip/master to
> > remove the nr_cpus_allowed check so that numacore would be enabled again
> > and tested that. In some places it has indeed much improved. In others
> > it is still regressing badly and in two case, it's corrupting memory --
> > specjbb when THP is enabled crashes when running for single or multiple
> > JVMs. It is likely that a zero page is being inserted due to a race with
> > migration and causes the JVM to throw a null pointer exception. Here is
> > the comparison on the rough off-chance you actually read it this time.
> 
> I see this failure when running with THP and KSM enabled on 
> Friday's Tip master. Not sure if Mel was talking about the same issue.
> 
> ------------[ cut here ]------------
> kernel BUG at ../kernel/sched/fair.c:2371!

Could you check whether today's -tip (7ea8701a1a51 or later), 
plus the patch below, addresses the crash - while still giving 
good NUMA performance?

Thanks,

	Ingo

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9d11a8a..6a89787 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2351,6 +2351,9 @@ void task_numa_fault(unsigned long addr, int node, int last_cpupid, int pages, b
 	int priv;
 	int idx;
 
+	if (!p->numa_faults)
+		return;
+
 	if (last_cpupid != cpu_pid_to_cpupid(-1, -1)) {
 		/* Did we access it last time around? */
 		if (last_pid == this_pid) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
