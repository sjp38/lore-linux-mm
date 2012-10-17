Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 26A2B6B005D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 08:03:21 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v2 2/5] memory-hotplug: update mce_bad_pages when removing the memory
Date: Wed, 17 Oct 2012 20:08:52 +0800
Message-Id: <1350475735-26136-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>

From: Wen Congyang <wency@cn.fujitsu.com>

When we hotremove a memory device, we will free the memory to store
struct page. If the page is hwpoisoned page, we should decrease
mce_bad_pages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/sparse.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index fac95f2..24072e4 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -773,6 +773,23 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_MEMORY_FAILURE
+static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+{
+	int i;
+
+	if (!memmap)
+		return;
+
+	for (i = 0; i < PAGES_PER_SECTION; i++) {
+		if (PageHWPoison(&memmap[i])) {
+			atomic_long_sub(1, &mce_bad_pages);
+			ClearPageHWPoison(&memmap[i]);
+		}
+	}
+}
+#endif
+
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
@@ -786,6 +803,10 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 		ms->pageblock_flags = NULL;
 	}
 
+#ifdef CONFIG_MEMORY_FAILURE
+	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
+#endif
+
 	free_section_usemap(memmap, usemap);
 }
 #endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
