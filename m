Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 2CE176B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:56:54 -0500 (EST)
Date: Fri, 22 Feb 2013 12:56:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] add extra free kbytes tunable
Message-ID: <20130222175634.GA4824@cmpxchg.org>
References: <alpine.DEB.2.02.1302111734090.13090@dflat>
 <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com>
 <511EB5CB.2060602@redhat.com>
 <alpine.DEB.2.02.1302171546120.10836@dflat>
 <20130219152936.f079c971.akpm@linux-foundation.org>
 <alpine.DEB.2.02.1302192100100.23162@dflat>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1302192100100.23162@dflat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dormando <dormando@rydia.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "hughd@google.com" <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, Feb 19, 2013 at 09:19:27PM -0800, dormando wrote:
> >
> > The problem is that adding this tunable will constrain future VM
> > implementations.  We will forever need to at least retain the
> > pseudo-file.  We will also need to make some effort to retain its
> > behaviour.
> >
> > It would of course be better to fix things so you don't need to tweak
> > VM internals to get acceptable behaviour.
> 
> I sympathize with this. It's presently all that keeps us afloat though.
> I'll whine about it again later if nothing else pans out.
> 
> > You said:
> >
> > : We have a server workload wherein machines with 100G+ of "free" memory
> > : (used by page cache), scattered but frequent random io reads from 12+
> > : SSD's, and 5gbps+ of internet traffic, will frequently hit direct reclaim
> > : in a few different ways.
> > :
> > : 1) It'll run into small amounts of reclaim randomly (a few hundred
> > : thousand).
> > :
> > : 2) A burst of reads or traffic can cause extra pressure, which kswapd
> > : occasionally responds to by freeing up 40g+ of the pagecache all at once
> > : (!) while pausing the system (Argh).
> > :
> > : 3) A blip in an upstream provider or failover from a peer causes the
> > : kernel to allocate massive amounts of memory for retransmission
> > : queues/etc, potentially along with buffered IO reads and (some, but not
> > : often a ton) of new allocations from an application. This paired with 2)
> > : can cause the box to stall for 15+ seconds.
> >
> > Can we prioritise these?  2) looks just awful - kswapd shouldn't just
> > go off and free 40G of pagecache.  Do you know what's actually in that
> > pagecache?  Large number of small files or small number of (very) large
> > files?
> 
> We have a handful of huge files (6-12ish 200g+) that are mmap'ed and
> accessed via address. occasionally madvise (WILLNEED) applied to the
> address ranges before attempting to use them. There're a mix of other
> files but nothing significant. The mmap's are READONLY and writes are done
> via pwrite-ish functions.
> 
> I could use some guidance on inspecting/tracing the problem. I've been
> trying to reproduce it in a lab, and respecting to 2)'s issue I've found:
> 
> - The amount of memory freed back up is either a percentage of total
> memory or a percentage of free memory. (a machine with 48G of ram will
> "only" free up an extra 4-7g)
> 
> - It's most likely to happen after a fresh boot, or if "3 > drop_caches"
> is applied with the application down. As it fills it seems to get itself
> into trouble, but becomes more stable after that. Unfortunately 1) and 3)
> still apply to a stable instance.
> 
> - Protecting the DMA32 zone with something like "1 1 32" into
> lowmem_reserve_ratio makes the mass-reclaiming less likely to happen.
> 
> - While watching "sar -B 1" I'll see kswapd wake up, and scan up to a few
> hundred thousand pages before finding anything it actually wants to
> reclaim (low vmeff). I've only been able to reproduce this from a clean
> start. It can take up to 3 seconds before kswapd starts actually
> reclaiming pages.
> 
> - So far as I can tell we're almost exclusively using 0 order allocations.
> THP is disabled.
> 
> There's not much dirty memory involved. It's not flushing out writes while
> reclaiming, it just kills off massive amount of cached memory.

Mapped file pages have to get scanned twice before they are reclaimed
because we don't have enough usage information after the first scan.

In your case, when you start this workload after a fresh boot or
dropping the caches, there will be 48G of mapped file pages that have
never been scanned before and that need to be looked at twice.

Unfortunately, if kswapd does not make progress (and it won't for some
time at first), it will scan more and more aggressively with
increasing scan priority.  And when the 48G of pages are finally
cycled, kswapd's scan window is a large percentage of your machine's
memory, and it will free every single page in it.

I think we should think about capping kswapd zone reclaim cycles just
as we do for direct reclaim.  It's a little ridiculous that it can run
unbounded and reclaim every page in a zone without ever checking back
against the watermark.  We still increase the scan window evenly when
we don't make forward progress, but we are more carefully inching zone
levels back toward the watermarks.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4883eb..8a4c446 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2645,10 +2645,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		.may_unmap = 1,
 		.may_swap = 1,
 		/*
-		 * kswapd doesn't want to be bailed out while reclaim. because
-		 * we want to put equal scanning pressure on each zone.
+		 * Even kswapd zone scans want to be bailed out after
+		 * reclaiming a good chunk of pages.  It will just
+		 * come back if the watermarks are still not met.
 		 */
-		.nr_to_reclaim = ULONG_MAX,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = order,
 		.target_mem_cgroup = NULL,
 	};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
