Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 667B26B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 10:54:49 -0500 (EST)
Date: Thu, 5 Jan 2012 15:54:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120105155445.GC27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1325499859-2262-8-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Mon, Jan 02, 2012 at 12:24:18PM +0200, Gilad Ben-Yossef wrote:
> <SNIP>
> This patch saves 99% of IPIs asking to drain per-cpu
> pages in case of severe memory preassure that leads
> to OOM since in these cases multiple, possibly concurrent,
> allocation requests end up in the direct reclaim code
> path so when the per-cpu pages end up reclaimed on first
> allocation failure for most of the proceeding allocation
> attempts until the memory pressure is off (possibly via
> the OOM killer) there are no per-cpu pages on most CPUs
> (and there can easily be hundreds of them).
> 

Ok. I also noticed this independently within the last day while
investing a CPU hotplug problem. Specifically, in low memory situations
(not necessarily OOM) a number of processes hit direct reclaim at
the same time, drain at the same time so there were multiple IPIs
draining the lists of which only the first one had useful work to do.
The workload in this case was a large number of kernel compiles but
I suspect any fork-heavy workload doing order-1 allocations under
memory pressure encounters this.

> <SNIP>
> Tested by running "hackbench 400" on a 4 CPU x86 otherwise
> idle VM and observing the difference between the number
> of direct reclaim attempts that end up in drain_all_pages()
> and those were more then 1/2 of the online CPU had any
> per-cpu page in them, using the vmstat counters introduced
> in the next patch in the series and using proc/interrupts.
> 
> In the test sceanrio, this saved around 500 global IPIs.
> After trigerring an OOM:
> 
> $ cat /proc/vmstat
> ...
> pcp_global_drain 627
> pcp_global_ipi_saved 578
> 

This isn't 99% savings as you claim earlier but they are still great.

Thanks for doing the stats. Just to be clear, I didn't expect these
stats to be merged, nor do I want them to. I wanted to be sure the patch
was really behaving as advertised.

Acked-by: Mel Gorman <mgorman@suse.de>


> +	for_each_online_cpu(cpu)
> +		for_each_populated_zone(zone) {
> +			pcp = per_cpu_ptr(zone->pageset, cpu);
> +			if (pcp->pcp.count)
> +				cpumask_set_cpu(cpu, cpus_with_pcps);
> +			else
> +				cpumask_clear_cpu(cpu, cpus_with_pcps);
> +		}
> +	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);

As a heads-up, I'm looking at a candidate CPU hotplug patch that almost
certainly will collide with this patch. If/when I get it fixed, I'll be
sure to CC you so we can figure out what order the patches need to go
in. Ordinarily it wouldn't matter but if this really is a CPU hotplug
fix, it might also be a -stable candidate so it would need to go in
before your patches.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
