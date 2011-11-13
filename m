Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A41B6B0073
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 05:18:37 -0500 (EST)
Received: by mail-bw0-f41.google.com with SMTP id 17so5188133bke.14
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 02:18:36 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 5/5] mm: Only IPI CPUs to drain local pages if they exist
Date: Sun, 13 Nov 2011 12:17:29 +0200
Message-Id: <1321179449-6675-6-git-send-email-gilad@benyossef.com>
In-Reply-To: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

Calculate a cpumask of CPUs with per-cpu pages in any zone
and only send an IPI requesting CPUs to drain these pages
to the buddy allocator if they actually have pages when
asked to flush.

The code path of memory allocation failure for CPUMASK_OFFSTACK=y
config was tested using fault injection framework.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
---
 mm/page_alloc.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..44dc6c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1119,7 +1119,23 @@ void drain_local_pages(void *arg)
  */
 void drain_all_pages(void)
 {
-	on_each_cpu(drain_local_pages, NULL, 1);
+	int cpu;
+	struct zone *zone;
+	cpumask_var_t cpus;
+	struct per_cpu_pageset *pageset;
+
+	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
+		for_each_populated_zone(zone) {
+			for_each_online_cpu(cpu) {
+				pageset = per_cpu_ptr(zone->pageset, cpu);
+				if (pageset->pcp.count)
+					cpumask_set_cpu(cpu, cpus);
+		}
+	}
+		on_each_cpu_mask(cpus, drain_local_pages, NULL, 1);
+		free_cpumask_var(cpus);
+	} else
+		on_each_cpu(drain_local_pages, NULL, 1);
 }
 
 #ifdef CONFIG_HIBERNATION
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
