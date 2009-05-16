Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E61CA6B0085
	for <linux-mm@kvack.org>; Sat, 16 May 2009 09:20:47 -0400 (EDT)
Date: Sat, 16 May 2009 15:20:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
Message-ID: <20090516132042.GB5606@cmpxchg.org>
References: <20090516090005.916779788@intel.com> <20090516090448.410032840@intel.com> <20090516092858.GA12104@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090516092858.GA12104@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 16, 2009 at 05:28:58PM +0800, Wu Fengguang wrote:
> [trivial update on comment text, according to Rik's comment]
> 
> --
> vmscan: make mapped executable pages the first class citizen
> 
> Protect referenced PROT_EXEC mapped pages from being deactivated.
> 
> PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
> currently running executables and their linked libraries, they shall really be
> cached aggressively to provide good user experiences.
> 
> Thanks to Johannes Weiner for the advice to reuse the VMA walk in
> page_referenced() to get the PROT_EXEC bit.
> 
> 
> [more details]
> 
> ( The consequences of this patch will have to be discussed together with
>   Rik van Riel's recent patch "vmscan: evict use-once pages first". )
> 
> ( Some of the good points and insights are taken into this changelog.
>   Thanks to all the involved people for the great LKML discussions. )
> 
> the problem
> -----------
> 
> For a typical desktop, the most precious working set is composed of
> *actively accessed*
> 	(1) memory mapped executables
> 	(2) and their anonymous pages
> 	(3) and other files
> 	(4) and the dcache/icache/.. slabs
> while the least important data are
> 	(5) infrequently used or use-once files
> 
> For a typical desktop, one major problem is busty and large amount of (5)
> use-once files flushing out the working set.
> 
> Inside the working set, (4) dcache/icache have already been too sticky ;-)
> So we only have to care (2) anonymous and (1)(3) file pages.
> 
> anonymous pages
> ---------------
> Anonymous pages are effectively immune to the streaming IO attack, because we
> now have separate file/anon LRU lists. When the use-once files crowd into the
> file LRU, the list's "quality" is significantly lowered. Therefore the scan
> balance policy in get_scan_ratio() will choose to scan the (low quality) file
> LRU much more frequently than the anon LRU.
> 
> file pages
> ----------
> Rik proposed to *not* scan the active file LRU when the inactive list grows
> larger than active list. This guarantees that when there are use-once streaming
> IO, and the working set is not too large(so that active_size < inactive_size),
> the active file LRU will *not* be scanned at all. So the not-too-large working
> set can be well protected.
> 
> But there are also situations where the file working set is a bit large so that
> (active_size >= inactive_size), or the streaming IOs are not purely use-once.
> In these cases, the active list will be scanned slowly. Because the current
> shrink_active_list() policy is to deactivate active pages regardless of their
> referenced bits. The deactivated pages become susceptible to the streaming IO
> attack: the inactive list could be scanned fast (500MB / 50MBps = 10s) so that
> the deactivated pages don't have enough time to get re-referenced. Because a
> user tend to switch between windows in intervals from seconds to minutes.
> 
> This patch holds mapped executable pages in the active list as long as they
> are referenced during each full scan of the active list.  Because the active
> list is normally scanned much slower, they get longer grace time (eg. 100s)
> for further references, which better matches the pace of user operations.
> 
> Therefore this patch greatly prolongs the in-cache time of executable code,
> when there are moderate memory pressures.
> 
> 	before patch: guaranteed to be cached if reference intervals < I
> 	after  patch: guaranteed to be cached if reference intervals < I+A
> 		      (except when randomly reclaimed by the lumpy reclaim)
> where
> 	A = time to fully scan the   active file LRU
> 	I = time to fully scan the inactive file LRU
> 
> Note that normally A >> I.
> 
> side effects
> ------------
> 
> This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
> but in a much smaller and well targeted scope.
> 
> One may worry about some one to abuse the PROT_EXEC heuristic.  But as
> Andrew Morton stated, there are other tricks to getting that sort of boost.
> 
> Another concern is the PROT_EXEC mapped pages growing large in rare cases,
> and therefore hurting reclaim efficiency. But a sane application targeted for
> large audience will never use PROT_EXEC for data mappings. If some home made
> application tries to abuse that bit, it shall be aware of the consequences.
> If it is abused to scale of 2/3 total memory, it gains nothing but overheads.
> 
> CC: Elladan <elladan@eskimo.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
