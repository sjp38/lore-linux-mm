Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 60F146B0069
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:39:02 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 11/11] add purged page information in vmstat
Date: Tue, 12 Mar 2013 16:38:35 +0900
Message-Id: <1363073915-25000-12-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

This patch adds vmstat information about discarded page in vrange
so admin can see how many of volatile pages are discarded by VM
and efficieny. it could be indicator for seeing vrange working
well.

PG_VRANGE_SCAN : the number of scanned pages for discarding
PG_VRANGE_DISCARD: the number of discarded pages in kswapd's vrange LRU order
PGDISCARD_DIRECT : the number of discarded pages in process context
PGDISCARD_KSWAPD : the number of discarded pages in kswapd's page LRU order

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vm_event_item.h | 4 ++++
 mm/vmstat.c                   | 4 ++++
 mm/vrange.c                   | 9 +++++++++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index bd6cf61..3d8ad18 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PG_VRANGE_SCAN,
+		PG_VRANGE_DISCARD,
+		PGDISCARD_DIRECT,
+		PGDISCARD_KSWAPD,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..55806d2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -754,6 +754,10 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pgvrange_scan",
+	"pgvrange_discard",
+	"pgdiscard_direct",
+	"pgdiscard_kswapd",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
diff --git a/mm/vrange.c b/mm/vrange.c
index 2f56d36..c0c5d50 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -518,6 +518,10 @@ int discard_vpage(struct page *page)
 		if (page_freeze_refs(page, 1)) {
 			unlock_page(page);
 			dec_zone_page_state(page, NR_ISOLATED_ANON);
+			if (current_is_kswapd())
+				count_vm_event(PGDISCARD_KSWAPD);
+			else
+				count_vm_event(PGDISCARD_DIRECT);
 			return 1;
 		}
 	}
@@ -584,11 +588,15 @@ static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	unsigned long start = addr;
 
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		vrange_pte_entry(*pte, addr, PAGE_SIZE, walk);
 	pte_unmap_unlock(pte - 1, ptl);
+
+	count_vm_events(PG_VRANGE_SCAN, (end - start) / PAGE_SIZE);
+
 	cond_resched();
 	return 0;
 
@@ -741,5 +749,6 @@ unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
 	if (start_vrange)
 		put_victim_range(start_vrange);
 
+	count_vm_events(PG_VRANGE_DISCARD, nr_discarded);
 	return nr_discarded;
 }
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
