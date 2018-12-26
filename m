Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA73C8E0005
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so13962427plb.17
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.348801665@intel.com>
Date: Wed, 26 Dec 2018 21:14:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 05/21] mmzone: new pgdat flags for DRAM and PMEM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0003-mmzone-Introduce-new-flag-to-tag-pgdat-type.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

One system with DRAM and PMEM, we need new flag
to tag pgdat is made of DRAM or peristent memory.

This patch serves as preparetion one for follow up patch.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mmzone.h |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

--- linux.orig/include/linux/mmzone.h	2018-12-23 19:29:42.430602202 +0800
+++ linux/include/linux/mmzone.h	2018-12-23 19:29:42.430602202 +0800
@@ -522,6 +522,8 @@ enum pgdat_flags {
 					 * many pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	PGDAT_DRAM,			/* Volatile DRAM memory node */
+	PGDAT_PMEM,			/* Persistent memory node */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
@@ -919,6 +921,30 @@ extern struct pglist_data contig_page_da
 
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
+static inline int is_node_pmem(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	return test_bit(PGDAT_PMEM, &pgdat->flags);
+}
+
+static inline int is_node_dram(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	return test_bit(PGDAT_DRAM, &pgdat->flags);
+}
+
+static inline void set_node_type(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	if (node_isset(nid, numa_nodes_pmem))
+		set_bit(PGDAT_PMEM, &pgdat->flags);
+	else
+		set_bit(PGDAT_DRAM, &pgdat->flags);
+}
+
 extern struct pglist_data *first_online_pgdat(void);
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
 extern struct zone *next_zone(struct zone *zone);
