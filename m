Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E96A66B0095
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:20:35 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v9 PATCH 20/21] memory-hotplug: clear hwpoisoned flag when onlining pages
Date: Wed, 5 Sep 2012 17:25:54 +0800
Message-Id: <1346837155-534-21-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

hwpoisoned may set when we offline a page by the sysfs interface
/sys/devices/system/memory/soft_offline_page or
/sys/devices/system/memory/hard_offline_page. If we don't clear
this flag when onlining pages, this page can't be freed, and will
not in free list. So we can't offline these pages again. So we
should clear this flag when onlining pages.

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
 mm/memory_hotplug.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 270c249..140c080 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -661,6 +661,11 @@ EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
+#ifdef CONFIG_MEMORY_FAILURE
+	/* The page may be marked HWPoisoned by soft/hard offline page */
+	ClearPageHWPoison(page);
+#endif
+
 	ClearPageReserved(page);
 	init_page_count(page);
 	__free_page(page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
