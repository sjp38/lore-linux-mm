Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 86FD46B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 10:49:47 -0400 (EDT)
Date: Fri, 3 Jun 2011 15:49:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110603144941.GI7306@suse.de>
References: <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110603020920.GA26753@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Fri, Jun 03, 2011 at 03:09:20AM +0100, Mel Gorman wrote:
> On Thu, Jun 02, 2011 at 05:37:54PM +0200, Andrea Arcangeli wrote:
> > > There is an explanation in here somewhere because as I write this,
> > > the test machine has survived 14 hours under continual stress without
> > > the isolated counters going negative with over 128 million pages
> > > successfully migrated and a million pages failed to migrate due to
> > > direct compaction being called 80,000 times. It's possible it's a
> > > co-incidence but it's some co-incidence!
> > 
> > No idea...
> 
> I wasn't able to work on this most of the day but was looking at this
> closer this evening again and I think I might have thought of another
> theory that could cause this problem.
> 
> When THP is isolating pages, it accounts for the pages isolated against
> the zone of course. If it backs out, it finds the pages from the PTEs.
> On !SMP but PREEMPT, we may not have adequate protection against a new
> page from a different zone being inserted into the PTE causing us to
> decrement against the wrong zone. While the global counter is fine,
> the per-zone counters look corrupted. You'd still think it was the
> anon counter tht got screwed rather than the file one if it really was
> THP unfortunately so it's not the full picture. I'm going to start
> a test monitoring both zoneinfo and vmstat to see if vmstat looks
> fine while the per-zone counters that are negative are offset by a
> positive count on the other zones that when added together become 0.
> Hopefully it'll actually trigger overnight :/
> 

Right idea of the wrong zone being accounted for but wrong place. I
think the following patch should fix the problem;

==== CUT HERE ===
mm: compaction: Ensure that the compaction free scanner does not move to the next zone

Compaction works with two scanners, a migration and a free
scanner. When the scanners crossover, migration within the zone is
complete. The location of the scanner is recorded on each cycle to
avoid excesive scanning.

When a zone is small and mostly reserved, it's very easy for the
migration scanner to be close to the end of the zone. Then the following
situation can occurs

  o migration scanner isolates some pages near the end of the zone
  o free scanner starts at the end of the zone but finds that the
    migration scanner is already there
  o free scanner gets reinitialised for the next cycle as
    cc->migrate_pfn + pageblock_nr_pages
    moving the free scanner into the next zone
  o migration scanner moves into the next zone but continues accounting
    against the old zone

When this happens, NR_ISOLATED accounting goes haywire because some
of the accounting happens against the wrong zone. One zones counter
remains positive while the other goes negative even though the overall
global count is accurate. This was reported on X86-32 with !SMP because
!SMP allows the negative counters to be visible. The fact that it is
difficult to reproduce on X86-64 is probably just a co-incidence as
the bug should theoritically be possible there.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a4337bc..ec1ed3b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -144,9 +144,20 @@ static void isolate_freepages(struct zone *zone,
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
+	/*
+	 * Initialise the free scanner. The starting point is where we last
+	 * scanned from (or the end of the zone if starting). The low point
+	 * is the end of the pageblock the migration scanner is using.
+	 */
 	pfn = cc->free_pfn;
 	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
-	high_pfn = low_pfn;
+
+	/*
+	 * Take care that if the migration scanner is at the end of the zone
+	 * that the free scanner does not accidentally move to the next zone
+	 * in the next isolation cycle.
+	 */
+	high_pfn = min(low_pfn, pfn);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
