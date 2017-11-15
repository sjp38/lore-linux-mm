Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC3046B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:55:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b189so339201wmd.5
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 00:55:58 -0800 (PST)
Received: from outbound-smtp19.blacknight.com (outbound-smtp19.blacknight.com. [46.22.139.246])
        by mx.google.com with ESMTPS id m26si10840524edf.324.2017.11.15.00.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 00:55:57 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp19.blacknight.com (Postfix) with ESMTPS id B3E5C1C4CB7
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 08:55:56 +0000 (GMT)
Date: Wed, 15 Nov 2017 08:55:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@techsingularity.net, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
but only 16GB was available due to deferred memory initialisation.

The allocation context is within smp_init() so there are no opportunities
to do the deferred meminit earlier. Furthermore, the partial initialisation
of memory occurs before the size of the trace buffers is set so there is
no opportunity to adjust the amount of memory that is pre-initialised. We
could potentially catch when memory is low during system boot and adjust the
amount that is initialised serially but it's a little clumsy as it would
require a check in the failure path of the page allocator.  Given that
deferred meminit is basically a minor optimisation that only benefits very
large machines and trace_buf_size is somewhat specialised, it follows that
the most straight-forward option is to go back to serialised meminit if
trace_buf_size is specified.

Reported-and-tested-by: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h  | 13 +++++++++++++
 init/main.c          |  2 ++
 kernel/trace/trace.c |  7 +++++++
 mm/page_alloc.c      | 30 ++++++++++++++++++++++++++++++
 4 files changed, 52 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 710143741eb5..6ef0ab13f774 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -558,6 +558,19 @@ void drain_local_pages(struct zone *zone);
 
 void page_alloc_init_late(void);
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+extern void __init disable_deferred_meminit(void);
+extern void page_alloc_init_late_prepare(void);
+#else
+static inline void disable_deferred_meminit(void)
+{
+}
+
+static inline void page_alloc_init_late_prepare(void)
+{
+}
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
  * GFP flags are used before interrupts are enabled. Once interrupts are
diff --git a/init/main.c b/init/main.c
index 0ee9c6866ada..0248b8b5bc3a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1058,6 +1058,8 @@ static noinline void __init kernel_init_freeable(void)
 	do_pre_smp_initcalls();
 	lockup_detector_init();
 
+	page_alloc_init_late_prepare();
+
 	smp_init();
 	sched_init_smp();
 
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 752e5daf0896..cfa7175ff093 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -1115,6 +1115,13 @@ static int __init set_buf_size(char *str)
 	if (buf_size == 0)
 		return 0;
 	trace_buf_size = buf_size;
+
+	/*
+	 * The size of buffers are unpredictable so initialise all memory
+	 * before the allocation attempt occurs.
+	 */
+	disable_deferred_meminit();
+
 	return 1;
 }
 __setup("trace_buf_size=", set_buf_size);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..4dd0e153b0f2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -290,6 +290,19 @@ EXPORT_SYMBOL(nr_online_nodes);
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+bool __initdata deferred_meminit_disabled;
+
+/*
+ * Allow deferred meminit to be disabled by subsystems that require large
+ * allocations before the memory allocator is fully initialised. It should
+ * only be used in cases where the size of the allocation may not fit into
+ * the 2G per node that is allocated serially.
+ */
+void __init disable_deferred_meminit(void)
+{
+	deferred_meminit_disabled = true;
+}
+
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
 	unsigned long max_initialise;
@@ -1567,6 +1580,23 @@ static int __init deferred_init_memmap(void *data)
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+/*
+ * Serialised init of remaining memory if large buffers of unknown size
+ * are required that might fail before parallelised meminit can start
+ */
+void __init page_alloc_init_late_prepare(void)
+{
+	int nid;
+
+	if (!deferred_meminit_disabled)
+		return;
+
+	for_each_node_state(nid, N_MEMORY)
+		deferred_init_memmap(NODE_DATA(nid));
+}
+#endif
+
 void __init page_alloc_init_late(void)
 {
 	struct zone *zone;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
