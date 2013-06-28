Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 58A3C6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:45:07 -0400 (EDT)
Date: Fri, 28 Jun 2013 09:45:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: vmscan: Avoid direct reclaim scanning at maximum
 priority
Message-ID: <20130628084500.GQ1875@suse.de>
References: <1372250364-20640-1-git-send-email-mgorman@suse.de>
 <1372250364-20640-2-git-send-email-mgorman@suse.de>
 <20130626123925.6a15ce3874fa4b0cc8390a0a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130626123925.6a15ce3874fa4b0cc8390a0a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 12:39:25PM -0700, Andrew Morton wrote:
> On Wed, 26 Jun 2013 13:39:23 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Page reclaim at priority 0 will scan the entire LRU as priority 0 is
> > considered to be a near OOM condition. Direct reclaim can reach this
> > priority while still making reclaim progress. This patch avoids
> > reclaiming at priority 0 unless no reclaim progress was made and
> > the page allocator would consider firing the OOM killer. The
> > user-visible impact is that direct reclaim will not easily reach
> > priority 0 and start swapping prematurely.
> 
> That's a bandaid.
> 
> Priority 0 should be a pretty darn rare condition.  How often is it
> occurring, and do you know why?
> 

There are no flys on you.

The actual rescanning never happens in my experience but priority 0
is reached quickly. Instrumentation showed that it was due to a bug in
reclaim/compaction. Please consider replacing the patch with this.

---8<---
mm: vmscan: Do not continue scanning if reclaim was aborted for compaction

Direct reclaim is not aborting to allow compaction to go ahead properly.
do_try_to_free_pages is told to abort reclaim which is happily ignores
and instead increases priority instead until it reaches 0 and starts
shrinking file/anon equally. This patch corrects the situation by
aborting reclaim when requested instead of raising priority.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2a5dee2..2f0193c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2381,8 +2381,10 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
 		/*
-		 * Don't shrink slabs when reclaiming memory from
-		 * over limit cgroups
+		 * Don't shrink slabs when reclaiming memory from over limit
+		 * cgroups but do shrink slab at least once when aborting
+		 * reclaim for compaction to avoid unevenly scanning file/anon
+		 * LRU pages over slab pages.
 		 */
 		if (global_reclaim(sc)) {
 			unsigned long lru_pages = 0;
@@ -2428,7 +2430,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
-	} while (--sc->priority >= 0);
+	} while (--sc->priority >= 0 && !aborted_reclaim);
 
 out:
 	delayacct_freepages_end();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
