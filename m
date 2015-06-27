Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1739F6B006C
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:30:58 -0400 (EDT)
Received: by oiax193 with SMTP id x193so87186554oia.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:30:56 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id jy9si23574057oeb.77.2015.06.26.19.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:30:56 -0700 (PDT)
Message-ID: <558E09CA.7020909@huawei.com>
Date: Sat, 27 Jun 2015 10:26:18 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 5/8] mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new zone_stat_item called "NR_FREE_MIRROR_PAGES", it is
used to storage free mirrored pages count.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/mmzone.h | 1 +
 include/linux/vmstat.h | 2 ++
 mm/vmstat.c            | 1 +
 3 files changed, 4 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54e891a..7cc0a29 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -166,6 +166,7 @@ enum zone_stat_item {
 	WORKINGSET_NODERECLAIM,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
+	NR_FREE_MIRROR_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7..d0a7268 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -283,6 +283,8 @@ static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
 	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
 	if (is_migrate_cma(migratetype))
 		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
+	if (is_migrate_mirror(migratetype))
+		__mod_zone_page_state(zone, NR_FREE_MIRROR_PAGES, nr_pages);
 }
 
 extern const char * const vmstat_text[];
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d0323e0..7ee11ca 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -739,6 +739,7 @@ const char * const vmstat_text[] = {
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
+	"nr_free_mirror",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
