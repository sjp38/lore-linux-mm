Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id EB1AC6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 07:45:08 -0500 (EST)
Received: by wgbds11 with SMTP id ds11so611818wgb.26
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 04:45:07 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 11 Jan 2012 20:45:07 +0800
Message-ID: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
Subject: [PATCH] mm: vmscan: deactivate isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

Spinners on other CPUs, if any, could take the lru lock and do their jobs while
isolated pages are deactivated on the current CPU if the lock is released
actively. And no risk of race raised as pages are already queued on locally
private list.


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Wed Jan 11 20:40:40 2012
@@ -1464,6 +1464,7 @@ update_isolated_counts(struct mem_cgroup
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);

 	nr_active = clear_active_flags(isolated_list, count);
+	spin_lock_irq(&zone->lru_lock);
 	__count_vm_events(PGDEACTIVATE, nr_active);

 	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
@@ -1482,6 +1483,7 @@ update_isolated_counts(struct mem_cgroup

 	reclaim_stat->recent_scanned[0] += *nr_anon;
 	reclaim_stat->recent_scanned[1] += *nr_file;
+	spin_unlock_irq(&zone->lru_lock);
 }

 /*
@@ -1577,15 +1579,13 @@ shrink_inactive_list(unsigned long nr_to
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
 	}
+	spin_unlock_irq(&zone->lru_lock);

-	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+	if (nr_taken == 0)
 		return 0;
-	}

 	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);

-	spin_unlock_irq(&zone->lru_lock);

 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
