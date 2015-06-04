Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8C6900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:07:05 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so30798533pdb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:07:05 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id rf8si5802910pdb.180.2015.06.04.06.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:07:04 -0700 (PDT)
Message-ID: <55704BB0.7030606@huawei.com>
Date: Thu, 4 Jun 2015 20:59:28 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 04/12] mm: add mirrored pages to buddy system
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Set mirrored pageblock's migratetype to MIGRATE_MIRROR, so they could free to
buddy system's MIGRATE_MIRROR list when free bootmem.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b2ff46..8fe0187 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -572,6 +572,25 @@ static void __init print_mirror_info(void)
 			mirror_info.info[i].start +
 				mirror_info.info[i].size - 1);
 }
+
+static inline bool is_mirror_pfn(unsigned long pfn)
+{
+	int i;
+	unsigned long addr = pfn << PAGE_SHIFT;
+
+	/* 0-4G is always mirrored, so ignore it */
+	if (addr < (4UL << 30))
+		return false;
+
+	for (i = 0; i < mirror_info.count; i++) {
+		if (addr >= mirror_info.info[i].start &&
+		    addr < mirror_info.info[i].start +
+			   mirror_info.info[i].size)
+			return true;
+	}
+
+	return false;
+}
 #endif
 
 /*
@@ -4147,6 +4166,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 
 		block_migratetype = get_pageblock_migratetype(page);
 
+		if (is_migrate_mirror(block_migratetype))
+			continue;
+
 		/* Only test what is necessary when the reserves are not met */
 		if (reserve > 0) {
 			/*
@@ -4246,6 +4268,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		    && !(pfn & (pageblock_nr_pages - 1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
+#ifdef CONFIG_MEMORY_MIRROR
+		if (is_mirror_pfn(pfn))
+			set_pageblock_migratetype(page, MIGRATE_MIRROR);
+#endif
+
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
