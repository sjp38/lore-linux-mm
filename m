Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id C15566B002B
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 22:13:26 -0400 (EDT)
Date: Sun, 12 Aug 2012 22:13:13 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC][PATCH -mm -v2 3/3] mm,vmscan: evict inactive file pages first
Message-ID: <20120812221313.429db08b@annuminas.surriel.com>
In-Reply-To: <20120812235616.GA9033@x61.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
	<20120808174904.5d241c38@cuia.bos.redhat.com>
	<20120812235616.GA9033@x61.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On Sun, 12 Aug 2012 20:56:16 -0300
Rafael Aquini <aquini@redhat.com> wrote:

> Howdy Rik,
> 
> On Wed, Aug 08, 2012 at 05:49:04PM -0400, Rik van Riel wrote:
> > @@ -1687,6 +1700,14 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> >  		reclaim_stat->recent_rotated[1] /= 2;
> >  	}
> >  
> > +	/* Lots of inactive file pages? Reclaim those only. */
> > +	if (reclaim_file_only(lruvec, sc, anon, file)) {
> > +		fraction[0] = 0;
> > +		fraction[1] = 1;
> > +		denominator = 1;
> > +		goto out;
> > +	}
> > +
> 
> This hunk causes a &zone->lru_lock spinlock lockup down this path:
>  shrink_zone()->shrink_lruvec()->shrink_list()->shrink_inactive_list()

Oops.  Looks like I put it in the wrong spot in get_scan_count,
the spot that is under the lru lock, which we really do not
need for this code.

Can you try this one?
---8<---

Subject: vm,vmscan: evict inactive file pages first

When a lot of streaming file IO is happening, it makes sense to
evict just the inactive file pages and leave the other LRU lists
alone.

Likewise, when driving a cgroup hierarchy into its hard limit,
or over its soft limit, it makes sense to pick a child cgroup
that has lots of inactive file pages, and evict those first.

Being over its soft limit is considered a stronger preference
than just having a lot of inactive file pages, so a well behaved
cgroup is allowed to keep its file cache when there is a "badly
behaving" one in the same hierarchy.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   37 +++++++++++++++++++++++++++++++++----
 1 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1a9688b..0844b09 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1576,6 +1576,19 @@ static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
 		return inactive_anon_is_low(lruvec);
 }
 
+/* If this lruvec has lots of inactive file pages, reclaim those only. */
+static bool reclaim_file_only(struct lruvec *lruvec, struct scan_control *sc,
+			      unsigned long anon, unsigned long file)
+{
+	if (inactive_file_is_low(lruvec))
+		return false;
+
+	if (file > (anon + file) >> sc->priority)
+		return true;
+
+	return false;
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
@@ -1658,6 +1671,14 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 		}
 	}
 
+	/* Lots of inactive file pages? Reclaim those only. */
+	if (reclaim_file_only(lruvec, sc, anon, file)) {
+		fraction[0] = 0;
+		fraction[1] = 1;
+		denominator = 1;
+		goto out;
+	}
+
 	/*
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
@@ -1922,8 +1943,8 @@ static void age_recent_pressure(struct lruvec *lruvec, struct zone *zone)
  * should always be larger than recent_rotated, and the size should
  * always be larger than recent_pressure.
  */
-static u64 reclaim_score(struct mem_cgroup *memcg,
-			 struct lruvec *lruvec)
+static u64 reclaim_score(struct mem_cgroup *memcg, struct lruvec *lruvec,
+			 struct scan_control *sc)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 anon, file;
@@ -1949,6 +1970,14 @@ static u64 reclaim_score(struct mem_cgroup *memcg,
 		anon *= 10000;
 	}
 
+	/*
+	 * Prefer reclaiming from an lruvec with lots of inactive file
+	 * pages. Once those have been reclaimed, the score will drop so
+	 * far we will pick another lruvec to reclaim from.
+	 */
+	if (reclaim_file_only(lruvec, sc, anon, file))
+		file *= 100;
+
 	return max(anon, file);
 }
 
@@ -1974,7 +2003,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 
 		age_recent_pressure(lruvec, zone);
 
-		score = reclaim_score(memcg, lruvec);
+		score = reclaim_score(memcg, lruvec, sc);
 
 		/* Pick the lruvec with the highest score. */
 		if (score > max_score) {
@@ -1995,7 +2024,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 	 */
 	do {
 		shrink_lruvec(victim, sc);
-		score = reclaim_score(memcg, victim);
+		score = reclaim_score(memcg, victim, sc);
 	} while (sc->nr_to_reclaim > 0 && score > max_score / 2);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
