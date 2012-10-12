Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B63A76B005A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 06:15:07 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1452102dad.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:15:07 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: =?UTF-8?q?=5BPATCH=203/3=5D=20mm=3A=20vmevent=3A=20Sum=20per=20cpu=20pagesets=20stats=20asynchronously?=
Date: Fri, 12 Oct 2012 03:11:59 -0700
Message-Id: <1350036719-29031-3-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121012101115.GA11825@lizard>
References: <20121012101115.GA11825@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Currently vmevent relies on the global page state stats, which is updated
once per stat_interval (1 second) or when the per CPU pageset stats hit
their threshold.

We can sum the vm_stat_diff values asynchronously: they will be possibly a
bit inconsistent, but overall this should improve accuracy, since with
previous scheme we would always use worst-case scenario (i.e. we'd wait
for threshold to hit or 1 second delay), but now we use somewhat average
accuracy.

The idea is very similar to zone_page_state_snapshot().

Note that this might cause more pressure on CPU caches, so we only use
this when userland explicitly asks for accuracy, plus since we gather
stats outside of any fastpath, this should be OK in general.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c | 43 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 8113bda..a059bed 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -52,10 +52,51 @@ static u64 vmevent_attr_swap_pages(struct vmevent_watch *watch,
 #endif
 }
 
+/*
+ * In the worst case, this is inaccurate by
+ *
+ *	A+-(pcp->stat_threshold * zones * online_cpus)
+ *
+ * For say 4-core 2GB setup that would be ~350 KB worst case inaccuracy,
+ * but to reach this inaccuracy, CPUs would all need have to keep
+ * allocating (or freeing) pages from all the zones at the same time, and
+ * all their current vm_stat_diff values would need to be pretty close to
+ * pcp->stat_threshold.
+ *
+ * The larger the system, the more inaccurare vm_stat is (but at the same
+ * time, on large systems we care much less about small chunks of memory).
+ * When a more predicted behaviour is needed, userland can set a desired
+ * accuracy via attr->value2.
+ */
+static ulong vmevent_global_page_state(struct vmevent_attr *attr,
+				       enum zone_stat_item si)
+{
+	ulong global = global_page_state(si);
+#ifdef CONFIG_SMP
+	struct zone *zone;
+
+	if (!attr->value2)
+		return global;
+
+	for_each_populated_zone(zone) {
+		uint cpu;
+
+		for_each_online_cpu(cpu) {
+			struct per_cpu_pageset *pcp;
+
+			pcp = per_cpu_ptr(zone->pageset, cpu);
+
+			global += pcp->vm_stat_diff[si];
+		}
+	}
+#endif
+	return global;
+}
+
 static u64 vmevent_attr_free_pages(struct vmevent_watch *watch,
 				   struct vmevent_attr *attr)
 {
-	return global_page_state(NR_FREE_PAGES);
+	return vmevent_global_page_state(attr, NR_FREE_PAGES);
 }
 
 static u64 vmevent_attr_avail_pages(struct vmevent_watch *watch,
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
