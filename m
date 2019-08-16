Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31D1EC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8EAF206C2
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Vl1GFfYw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8EAF206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FC626B0005; Fri, 16 Aug 2019 17:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 483886B0006; Fri, 16 Aug 2019 17:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FE166B0007; Fri, 16 Aug 2019 17:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 00B5A6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:44:29 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A0A298248AD4
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:44:29 +0000 (UTC)
X-FDA: 75829620258.06.air76_7e70c4e2e7b18
X-HE-Tag: air76_7e70c4e2e7b18
X-Filterd-Recvd-Size: 17698
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:44:28 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5723bd0000>; Fri, 16 Aug 2019 14:44:29 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 16 Aug 2019 14:44:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 16 Aug 2019 14:44:27 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 16 Aug
 2019 21:44:26 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 16 Aug 2019 21:44:26 +0000
Received: from ng-desktop.nvidia.com (Not Verified[10.110.48.88]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d5723ba0000>; Fri, 16 Aug 2019 14:44:26 -0700
From: Nitin Gupta <nigupta@nvidia.com>
To: <akpm@linux-foundation.org>, <vbabka@suse.cz>,
	<mgorman@techsingularity.net>, <mhocko@suse.com>, <dan.j.williams@intel.com>
CC: Nitin Gupta <nigupta@nvidia.com>, Yu Zhao <yuzhao@google.com>, Matthew
 Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, Jann Horn
	<jannh@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Arun KS
	<arunks@codeaurora.org>, Janne Huttunen <janne.huttunen@nokia.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: [RFC] mm: Proactive compaction
Date: Fri, 16 Aug 2019 14:43:30 -0700
Message-ID: <20190816214413.15006-1-nigupta@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565991869; bh=5BGTCQVF5WBP6nPQkfgvvIsMfsFEZlG5OFC77OVEyu4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=Vl1GFfYwhpOl+wlFhKPjQ/cOCeQcBE2qoOoeP5kPVYXAocPPwfgE+2tEx9NLsGivc
	 sIjIJWgR5EyCGAdcgFobKl7sd3dyrEOw2JfFoE8qO51H3+YEZWxHzJBE61zjCT/ZWA
	 h9v9uDWhgGDWuWvzGDFn+MiJ63wIvbrcphCk+UiXp/0flrnZrtWMYVCkFC10eWF5yZ
	 8mqDIDQEz/KgaQa7KltqqIwSZ/2y0cm4zvPNQNwprEaFgkbfMNU/yYvCZrzU7KohVI
	 CnyDbox/lv90e95j6TvJkpwHhj2f20JVE5XJ2BN7ErgbjTfd0TJvFEo/Brfbrv32ax
	 VhnrOyS0l/C5Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For some applications we need to allocate almost all memory as
hugepages. However, on a running system, higher order allocations can
fail if the memory is fragmented. Linux kernel currently does
on-demand compaction as we request more hugepages but this style of
compaction incurs very high latency. Experiments with one-time full
memory compaction (followed by hugepage allocations) shows that kernel
is able to restore a highly fragmented memory state to a fairly
compacted memory state within <1 sec for a 32G system. Such data
suggests that a more proactive compaction can help us allocate a large
fraction of memory as hugepages keeping allocation latencies low.

For a more proactive compaction, the approach taken here is to define
per page-order external fragmentation thresholds and let kcompactd
threads act on these thresholds.

The low and high thresholds are defined per page-order and exposed
through sysfs:

  /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}

Per-node kcompactd thread is woken up every few seconds to check if
any zone on its node has extfrag above the extfrag_high threshold for
any order, in which case the thread starts compaction in the backgrond
till all zones are below extfrag_low level for all orders. By default
both these thresolds are set to 100 for all orders which essentially
disables kcompactd.

To avoid wasting CPU cycles when compaction cannot help, such as when
memory is full, we check both, extfrag > extfrag_high and
compaction_suitable(zone). This allows kcomapctd thread to stays inactive
even if extfrag thresholds are not met.

This patch is largely based on ideas from Michal Hocko posted here:
https://lore.kernel.org/linux-mm/20161230131412.GI13301@dhcp22.suse.cz/

Testing done (on x86):
 - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} =3D {25, 30}
 respectively.
 - Use a test program to fragment memory: the program allocates all memory
 and then for each 2M aligned section, frees 3/4 of base pages using
 munmap.
 - kcompactd0 detects fragmentation for order-9 > extfrag_high and starts
 compaction till extfrag < extfrag_low for order-9.

The patch has plenty of rough edges but posting it early to see if I'm
going in the right direction and to get some early feedback.

Signed-off-by: Nitin Gupta <nigupta@nvidia.com>
---
 include/linux/compaction.h |  12 ++
 mm/compaction.c            | 250 ++++++++++++++++++++++++++++++-------
 mm/vmstat.c                |  12 ++
 3 files changed, 228 insertions(+), 46 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..26bfedbbc64b 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -60,6 +60,17 @@ enum compact_result {
=20
 struct alloc_context; /* in mm/internal.h */
=20
+// "order-%d"
+#define COMPACTION_ORDER_STATE_NAME_LEN 16
+// Per-order compaction state
+struct compaction_order_state {
+	unsigned int order;
+	unsigned int extfrag_low;
+	unsigned int extfrag_high;
+	unsigned int extfrag_curr;
+	char name[COMPACTION_ORDER_STATE_NAME_LEN];
+};
+
 /*
  * Number of free order-0 pages that should be available above given water=
mark
  * to make sure compaction has reasonable chance of not running out of fre=
e
@@ -90,6 +101,7 @@ extern int sysctl_compaction_handler(struct ctl_table *t=
able, int write,
 extern int sysctl_extfrag_threshold;
 extern int sysctl_compact_unevictable_allowed;
=20
+extern int extfrag_for_order(struct zone *zone, unsigned int order);
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 		unsigned int order, unsigned int alloc_flags,
diff --git a/mm/compaction.c b/mm/compaction.c
index 952dc2fb24e5..21866b1ad249 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -25,6 +25,10 @@
 #include <linux/psi.h>
 #include "internal.h"
=20
+#ifdef CONFIG_COMPACTION
+struct compaction_order_state compaction_order_states[MAX_ORDER+1];
+#endif
+
 #ifdef CONFIG_COMPACTION
 static inline void count_compact_event(enum vm_event_item item)
 {
@@ -1846,6 +1850,49 @@ static inline bool is_via_compact_memory(int order)
 	return order =3D=3D -1;
 }
=20
+static int extfrag_wmark_high(struct zone *zone)
+{
+	int order;
+
+	for (order =3D 1; order <=3D MAX_ORDER; order++) {
+		int extfrag =3D extfrag_for_order(zone, order);
+		int threshold =3D compaction_order_states[order].extfrag_high;
+
+		if (extfrag > threshold)
+			return order;
+	}
+	return 0;
+}
+
+static bool node_should_compact(pg_data_t *pgdat)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone) {
+		int order =3D extfrag_wmark_high(zone);
+
+		if (order && compaction_suitable(zone, order,
+				0, zone_idx(zone)) =3D=3D COMPACT_CONTINUE) {
+			return true;
+		}
+	}
+	return false;
+}
+
+static int extfrag_wmark_low(struct zone *zone)
+{
+	int order;
+
+	for (order =3D 1; order <=3D MAX_ORDER; order++) {
+		int extfrag =3D extfrag_for_order(zone, order);
+		int threshold =3D compaction_order_states[order].extfrag_low;
+
+		if (extfrag > threshold)
+			return order;
+	}
+	return 0;
+}
+
 static enum compact_result __compact_finished(struct compact_control *cc)
 {
 	unsigned int order;
@@ -1872,7 +1919,7 @@ static enum compact_result __compact_finished(struct =
compact_control *cc)
 			return COMPACT_PARTIAL_SKIPPED;
 	}
=20
-	if (is_via_compact_memory(cc->order))
+	if (extfrag_wmark_low(cc->zone))
 		return COMPACT_CONTINUE;
=20
 	/*
@@ -1962,18 +2009,6 @@ static enum compact_result __compaction_suitable(str=
uct zone *zone, int order,
 {
 	unsigned long watermark;
=20
-	if (is_via_compact_memory(order))
-		return COMPACT_CONTINUE;
-
-	watermark =3D wmark_pages(zone, alloc_flags & ALLOC_WMARK_MASK);
-	/*
-	 * If watermarks for high-order allocation are already met, there
-	 * should be no need for compaction at all.
-	 */
-	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
-								alloc_flags))
-		return COMPACT_SUCCESS;
-
 	/*
 	 * Watermarks for order-0 must be met for compaction to be able to
 	 * isolate free pages for migration targets. This means that the
@@ -2003,31 +2038,9 @@ enum compact_result compaction_suitable(struct zone =
*zone, int order,
 					int classzone_idx)
 {
 	enum compact_result ret;
-	int fragindex;
=20
 	ret =3D __compaction_suitable(zone, order, alloc_flags, classzone_idx,
 				    zone_page_state(zone, NR_FREE_PAGES));
-	/*
-	 * fragmentation index determines if allocation failures are due to
-	 * low memory or external fragmentation
-	 *
-	 * index of -1000 would imply allocations might succeed depending on
-	 * watermarks, but we already failed the high-order watermark check
-	 * index towards 0 implies failure is due to lack of memory
-	 * index towards 1000 implies failure is due to fragmentation
-	 *
-	 * Only compact if a failure would be due to fragmentation. Also
-	 * ignore fragindex for non-costly orders where the alternative to
-	 * a successful reclaim/compaction is OOM. Fragindex and the
-	 * vm.extfrag_threshold sysctl is meant as a heuristic to prevent
-	 * excessive compaction for costly orders, but it should not be at the
-	 * expense of system stability.
-	 */
-	if (ret =3D=3D COMPACT_CONTINUE && (order > PAGE_ALLOC_COSTLY_ORDER)) {
-		fragindex =3D fragmentation_index(zone, order);
-		if (fragindex >=3D 0 && fragindex <=3D sysctl_extfrag_threshold)
-			ret =3D COMPACT_NOT_SUITABLE_ZONE;
-	}
=20
 	trace_mm_compaction_suitable(zone, order, ret);
 	if (ret =3D=3D COMPACT_NOT_SUITABLE_ZONE)
@@ -2416,7 +2429,6 @@ static void compact_node(int nid)
 		.gfp_mask =3D GFP_KERNEL,
 	};
=20
-
 	for (zoneid =3D 0; zoneid < MAX_NR_ZONES; zoneid++) {
=20
 		zone =3D &pgdat->node_zones[zoneid];
@@ -2493,9 +2505,149 @@ void compaction_unregister_node(struct node *node)
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
=20
+#ifdef CONFIG_SYSFS
+
+#define COMPACTION_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr =3D __ATTR_RO(_name)
+
+#define COMPACTION_ATTR(_name) \
+	static struct kobj_attribute _name##_attr =3D \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static struct kobject *compaction_kobj;
+static struct kobject *compaction_order_kobjs[MAX_ORDER];
+
+static struct compaction_order_state *kobj_to_compaction_order_state(
+						struct kobject *kobj)
+{
+	int i;
+
+	for (i =3D 1; i <=3D MAX_ORDER; i++) {
+		if (compaction_order_kobjs[i] =3D=3D kobj)
+			return &compaction_order_states[i];
+	}
+
+	return NULL;
+}
+
+static ssize_t extfrag_store_common(bool is_low, struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long input;
+	struct compaction_order_state *c =3D kobj_to_compaction_order_state(kobj)=
;
+
+	err =3D kstrtoul(buf, 10, &input);
+	if (err)
+		return err;
+	if (input > 100)
+		return -EINVAL;
+
+	if (is_low)
+		c->extfrag_low =3D input;
+	else
+		c->extfrag_high =3D input;
+
+	return count;
+}
+
+static ssize_t extfrag_low_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	struct compaction_order_state *c =3D kobj_to_compaction_order_state(kobj)=
;
+
+	return sprintf(buf, "%u\n", c->extfrag_low);
+}
+
+static ssize_t extfrag_low_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	return extfrag_store_common(true, kobj, attr, buf, count);
+}
+COMPACTION_ATTR(extfrag_low);
+
+static ssize_t extfrag_high_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct compaction_order_state *c =3D kobj_to_compaction_order_state(kobj)=
;
+
+	return sprintf(buf, "%u\n", c->extfrag_high);
+}
+
+static ssize_t extfrag_high_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	return extfrag_store_common(false, kobj, attr, buf, count);
+}
+COMPACTION_ATTR(extfrag_high);
+
+static struct attribute *compaction_order_attrs[] =3D {
+	&extfrag_low_attr.attr,
+	&extfrag_high_attr.attr,
+	NULL,
+};
+
+static const struct attribute_group compaction_order_attr_group =3D {
+	.attrs =3D compaction_order_attrs,
+};
+
+static int compaction_sysfs_add_order(struct compaction_order_state *c,
+	struct kobject *parent, struct kobject **compaction_order_kobjs,
+	const struct attribute_group *compaction_order_attr_group)
+{
+	int retval;
+
+	compaction_order_kobjs[c->order] =3D
+			kobject_create_and_add(c->name, parent);
+	if (!compaction_order_kobjs[c->order])
+		return -ENOMEM;
+
+	retval =3D sysfs_create_group(compaction_order_kobjs[c->order],
+				compaction_order_attr_group);
+	if (retval)
+		kobject_put(compaction_order_kobjs[c->order]);
+
+	return retval;
+}
+
+static void __init compaction_sysfs_init(void)
+{
+	struct compaction_order_state *c;
+	int i, err;
+
+	compaction_kobj =3D kobject_create_and_add("compaction", mm_kobj);
+	if (!compaction_kobj)
+		return;
+
+	for (i =3D 1; i <=3D MAX_ORDER; i++) {
+		c =3D &compaction_order_states[i];
+		err =3D compaction_sysfs_add_order(c, compaction_kobj,
+					compaction_order_kobjs,
+					&compaction_order_attr_group);
+		if (err)
+			pr_err("compaction: Unable to add state %s", c->name);
+	}
+}
+
+static void __init compaction_init_order_states(void)
+{
+	int i;
+
+	for (i =3D 0; i <=3D MAX_ORDER; i++) {
+		struct compaction_order_state *c =3D &compaction_order_states[i];
+
+		c->order =3D i;
+		c->extfrag_low =3D 100;
+		c->extfrag_high =3D 100;
+		snprintf(c->name, COMPACTION_ORDER_STATE_NAME_LEN,
+						"order-%d", i);
+	}
+}
+#endif
+
 static inline bool kcompactd_work_requested(pg_data_t *pgdat)
 {
-	return pgdat->kcompactd_max_order > 0 || kthread_should_stop();
+	return kthread_should_stop() || node_should_compact(pgdat);
 }
=20
 static bool kcompactd_node_suitable(pg_data_t *pgdat)
@@ -2527,15 +2679,16 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	int zoneid;
 	struct zone *zone;
 	struct compact_control cc =3D {
-		.order =3D pgdat->kcompactd_max_order,
-		.search_order =3D pgdat->kcompactd_max_order,
+		.order =3D -1,
 		.total_migrate_scanned =3D 0,
 		.total_free_scanned =3D 0,
-		.classzone_idx =3D pgdat->kcompactd_classzone_idx,
-		.mode =3D MIGRATE_SYNC_LIGHT,
-		.ignore_skip_hint =3D false,
+		.mode =3D MIGRATE_SYNC,
+		.ignore_skip_hint =3D true,
+		.whole_zone =3D false,
 		.gfp_mask =3D GFP_KERNEL,
+		.classzone_idx =3D MAX_NR_ZONES - 1,
 	};
+
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
 	count_compact_event(KCOMPACTD_WAKE);
@@ -2565,7 +2718,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (kthread_should_stop())
 			return;
 		status =3D compact_zone(&cc, NULL);
-
 		if (status =3D=3D COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
 		} else if (status =3D=3D COMPACT_PARTIAL_SKIPPED || status =3D=3D COMPAC=
T_COMPLETE) {
@@ -2650,11 +2802,14 @@ static int kcompactd(void *p)
 	pgdat->kcompactd_classzone_idx =3D pgdat->nr_zones - 1;
=20
 	while (!kthread_should_stop()) {
-		unsigned long pflags;
+		unsigned long ret, pflags;
=20
 		trace_mm_compaction_kcompactd_sleep(pgdat->node_id);
-		wait_event_freezable(pgdat->kcompactd_wait,
-				kcompactd_work_requested(pgdat));
+		ret =3D wait_event_freezable_timeout(pgdat->kcompactd_wait,
+				kcompactd_work_requested(pgdat),
+				msecs_to_jiffies(5000));
+		if (!ret)
+			continue;
=20
 		psi_memstall_enter(&pflags);
 		kcompactd_do_work(pgdat);
@@ -2735,6 +2890,9 @@ static int __init kcompactd_init(void)
 		return ret;
 	}
=20
+	compaction_init_order_states();
+	compaction_sysfs_init();
+
 	for_each_node_state(nid, N_MEMORY)
 		kcompactd_run(nid);
 	return 0;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16ca6996..e9090a5595d1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1074,6 +1074,18 @@ static int __fragmentation_index(unsigned int order,=
 struct contig_page_info *in
 	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, request=
ed))), info->free_blocks_total);
 }
=20
+int extfrag_for_order(struct zone *zone, unsigned int order)
+{
+	struct contig_page_info info;
+
+	fill_contig_page_info(zone, order, &info);
+	if (info.free_pages =3D=3D 0)
+		return 0;
+
+	return (info.free_pages - (info.free_blocks_suitable << order)) * 100
+							/ info.free_pages;
+}
+
 /* Same as __fragmentation index but allocs contig_page_info on stack */
 int fragmentation_index(struct zone *zone, unsigned int order)
 {
--=20
2.20.1


