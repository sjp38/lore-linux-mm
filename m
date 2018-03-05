Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51AC46B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:38:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p2so11376989wre.19
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:38:19 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b22si8069598edj.159.2018.03.05.05.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:38:18 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Date: Mon, 5 Mar 2018 13:37:40 +0000
Message-ID: <20180305133743.12746-2-guro@fb.com>
In-Reply-To: <20180305133743.12746-1-guro@fb.com>
References: <20180305133743.12746-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This patch introduces a concept of indirectly reclaimable memory
and adds the corresponding memory counter and /proc/vmstat item.

Indirectly reclaimable memory is any sort of memory, used by
the kernel (except of reclaimable slabs), which is actually
reclaimable, i.e. will be released under memory pressure.

The counter is in bytes, as it's not always possible to
count such objects in pages. The name contains BYTES
by analogy to NR_KERNEL_STACK_KB.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/mmzone.h | 1 +
 mm/vmstat.c            | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e09fe563d5dc..15e783f29e21 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -180,6 +180,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6db6b1..b6b5684f31fe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1161,6 +1161,7 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
+	"nr_indirectly_reclaimable",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
