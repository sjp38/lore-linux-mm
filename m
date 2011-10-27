Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 520286B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 08:51:20 -0400 (EDT)
Date: Thu, 27 Oct 2011 07:51:15 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] cache align vm_stat
Message-ID: <20111027125115.GB21671@sgi.com>
References: <20111027085008.GA6563@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111027085008.GA6563@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Oct 27, 2011 at 10:50:25AM +0200, Mel Gorman wrote:
> On Mon, Oct 24, 2011 at 11:10:35AM -0500, Dimitri Sivanich wrote:
> > Avoid false sharing of the vm_stat array.
> > 
> > This was found to adversely affect tmpfs I/O performance.
> > 
> 
> I think this fix is overly simplistic. It is moving each counter into
> its own cache line. While I accept that this will help the preformance
> of the tmpfs-based workload, it will adversely affect workloads that
> touch a lot of counters because of the increased cache footprint.

To reiterate, this change is as follows:
  -atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
  +atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;

I think you've misunderstood the effect of the fix.  It does not move
each counter into it's own cache line.  It forces the overall array to
start on a cache line boundary.  From 'nm -n vmlinux' output:
	ffffffff81e04200 d hash_lock
	ffffffff81e04240 D vm_stat
	ffffffff81e04340 d nr_files
Unless I'm missing something, vm_stat is using 4 cachelines, not 24.
And yes, the addresses of the first 3 counters are, in fact,
ffffffff81e04240, ffffffff81e04248, and ffffffff81e04250.

Also, while this patch does make some difference in performance, it is
only an incremental step in improving vm_stat contention.  More will need
to be done.

Also, I've found that separating counters into their own cacheline has less
of an effect on performance than one might think.  It really has more to do
with the number of updates that each of these counters (especially
NR_FREE_PAGES) is receiving.

> 
> 1. Is it possible to rearrange the vmstat array such that two hot
>    counters do not share a cache line?

See my comment above.

> 2. Has Andrew's suggestion to alter the per-cpu threshold based on the
>    value of the global counter to reduce conflicts been tried?

Altering the per-cpu threshold (that returned from calculate*threshold in
mm/vmstat.c) works well, but see my previous posts about the size of
threshold required to achieve reasonable scaling performance.  Values are
much higher than the currently allowed 125 (more on the order of 1000-2000).

> 
> (I'm at Linux Con at the moment so will be even slower to respond than
> usual)
> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
