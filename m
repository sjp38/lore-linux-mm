Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 434386B13F6
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 08:49:44 -0500 (EST)
Received: by mail-ey0-f169.google.com with SMTP id g11so2419561eaa.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 05:49:43 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v8 8/8] mm: add vmstat counters for tracking PCP drains
Date: Sun,  5 Feb 2012 15:48:42 +0200
Message-Id: <1328449722-15959-7-git-send-email-gilad@benyossef.com>
In-Reply-To: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

This patch introduces two new vmstat counters for testing purposes:
pcp_global_drain that counts the number of times a per-cpu pages
global drain was requested and pcp_global_ipi_saved that counts
the number of times the number of CPUs with per-cpu pages in any
zone were less then 1/2 of the number of online CPUs.

The patch purpose is to show the usefulness of only sending an IPI
asking to drain per-cpu pages to CPUs that actually have them
instead of a blind global IPI. It is not inteded to be merged.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Avi Kivity <avi@redhat.com>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
CC: Milton Miller <miltonm@bga.com>
---
 include/linux/vm_event_item.h |    1 +
 mm/page_alloc.c               |    5 +++++
 mm/vmstat.c                   |    2 ++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 03b90cd..3657f6f 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -58,6 +58,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_COLLAPSE_ALLOC_FAILED,
 		THP_SPLIT,
 #endif
+		PCP_GLOBAL_DRAIN, PCP_GLOBAL_IPI_SAVED,
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3ff5aff..09d47eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1201,6 +1201,11 @@ void drain_all_pages(void)
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
 	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
+
+	count_vm_event(PCP_GLOBAL_DRAIN);
+	if (cpumask_weight(&cpus_with_pcps) <
+	   (cpumask_weight(cpu_online_mask) / 2))
+		count_vm_event(PCP_GLOBAL_IPI_SAVED);
 }
 
 #ifdef CONFIG_HIBERNATION
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..3ee5f99 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -786,6 +786,8 @@ const char * const vmstat_text[] = {
 	"thp_collapse_alloc_failed",
 	"thp_split",
 #endif
+	"pcp_global_drain",
+	"pcp_global_ipi_saved"
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
