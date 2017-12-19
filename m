Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE2A6B025E
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:41:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 3so14067912pfo.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 22:41:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k91si10570919pld.115.2017.12.18.22.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 22:41:41 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
Date: Tue, 19 Dec 2017 14:39:24 +0800
Message-Id: <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

We have seen significant overhead in cache bouncing caused by NUMA counters
update in multi-threaded page allocation. See 'commit 1d90ca897cb0 ("mm:
update NUMA counter threshold size")' for more details.

This patch updates NUMA counters to a fixed size of (MAX_S16 - 2) and deals
with global counter update using different threshold size for node page
stats.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 mm/vmstat.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9c681cc..64e08ae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -30,6 +30,8 @@
 
 #include "internal.h"
 
+#define VM_NUMA_STAT_THRESHOLD (S16_MAX - 2)
+
 #ifdef CONFIG_NUMA
 int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
 
@@ -394,7 +396,11 @@ void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
 	s16 v, t;
 
 	v = __this_cpu_inc_return(*p);
-	t = __this_cpu_read(pcp->stat_threshold);
+	if (item >= NR_VM_NUMA_STAT_ITEMS)
+		t = __this_cpu_read(pcp->stat_threshold);
+	else
+		t = VM_NUMA_STAT_THRESHOLD;
+
 	if (unlikely(v > t)) {
 		s16 overstep = t >> 1;
 
@@ -549,7 +555,10 @@ static inline void mod_node_state(struct pglist_data *pgdat,
 		 * Most of the time the thresholds are the same anyways
 		 * for all cpus in a node.
 		 */
-		t = this_cpu_read(pcp->stat_threshold);
+		if (item >= NR_VM_NUMA_STAT_ITEMS)
+			t = this_cpu_read(pcp->stat_threshold);
+		else
+			t = VM_NUMA_STAT_THRESHOLD;
 
 		o = this_cpu_read(*p);
 		n = delta + o;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
