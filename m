Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AD85B6B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 13:14:41 -0400 (EDT)
Date: Wed, 29 Apr 2009 13:14:36 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] vmscan: evict use-once pages first (v3)
Message-ID: <20090429131436.640f09ab@cuia.bos.redhat.com>
In-Reply-To: <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When the file LRU lists are dominated by streaming IO pages,
evict those pages first, before considering evicting other
pages.

This should be safe from deadlocks or performance problems
because only three things can happen to an inactive file page:
1) referenced twice and promoted to the active list
2) evicted by the pageout code
3) under IO, after which it will get evicted or promoted

The pages freed in this way can either be reused for streaming
IO, or allocated for something else. If the pages are used for
streaming IO, this pageout pattern continues. Otherwise, we will
fall back to the normal pageout pattern.

Signed-off-by: Rik van Riel <riel@redhat.com>

---
On Thu, 30 Apr 2009 01:07:51 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> we handle active_anon vs inactive_anon ratio by shrink_list().
> Why do you insert this logic insert shrink_zone() ?

Kosaki, this implementation mirrors the anon side of things precisely.
Does this look good?

Elladan, this patch should work just like the second version. Please
let me know how it works for you.

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a9e3b76..dbfe7ba 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -94,6 +94,7 @@ extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
+int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
@@ -239,6 +240,12 @@ mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 	return 1;
 }
 
+static inline int
+mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
+{
+	return 1;
+}
+
 static inline unsigned long
 mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
 			 enum lru_list lru)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e44fb0f..026cb5a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -578,6 +578,17 @@ int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 	return 0;
 }
 
+int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
+{
+	unsigned long active;
+	unsigned long inactive;
+
+	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
+	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+
+	return (active > inactive);
+}
+
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..a73f675 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1348,12 +1348,48 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 	return low;
 }
 
+static int inactive_file_is_low_global(struct zone *zone)
+{
+	unsigned long active, inactive;
+
+	active = zone_page_state(zone, NR_ACTIVE_FILE);
+	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+
+	return (active > inactive);
+}
+
+/**
+ * inactive_file_is_low - check if file pages need to be deactivated
+ * @zone: zone to check
+ * @sc:   scan control of this context
+ *
+ * When the system is doing streaming IO, memory pressure here
+ * ensures that active file pages get deactivated, until more
+ * than half of the file pages are on the inactive list.
+ *
+ * Once we get to that situation, protect the system's working
+ * set from being evicted by disabling active file page aging.
+ *
+ * This uses a different ratio than the anonymous pages, because
+ * the page cache uses a use-once replacement algorithm.
+ */
+static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
+{
+	int low;
+
+	if (scanning_global_lru(sc))
+		low = inactive_file_is_low_global(zone);
+	else
+		low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup);
+	return low;
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
-	if (lru == LRU_ACTIVE_FILE) {
+	if (lru == LRU_ACTIVE_FILE && inactive_file_is_low(zone, sc)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
