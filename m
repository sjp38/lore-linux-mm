Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C30B76B008C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:20:33 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v9 PATCH 05/21] memory-hotplug: check whether memory is present or not
Date: Wed, 5 Sep 2012 17:25:39 +0800
Message-Id: <1346837155-534-6-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

If system supports memory hot-remove, online_pages() may online removed pages.
So online_pages() need to check whether onlining pages are present or not.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 include/linux/mmzone.h |   19 +++++++++++++++++++
 mm/memory_hotplug.c    |   13 +++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..ac3ae30 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1180,6 +1180,25 @@ void sparse_init(void);
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_SPARSEMEM
+static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
+{
+	int i;
+	for (i = 0; i < nr_pages; i++) {
+		if (pfn_present(pfn + i))
+			continue;
+		else
+			return -EINVAL;
+	}
+	return 0;
+}
+#else
+static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
+{
+	return 0;
+}
+#endif /* CONFIG_SPARSEMEM*/
+
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
 bool early_pfn_in_nid(unsigned long pfn, int nid);
 #else
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 49f7747..299747d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -467,6 +467,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	struct memory_notify arg;
 
 	lock_memory_hotplug();
+	/*
+	 * If system supports memory hot-remove, the memory may have been
+	 * removed. So we check whether the memory has been removed or not.
+	 *
+	 * Note: When CONFIG_SPARSEMEM is defined, pfns_present() become
+	 *       effective. If CONFIG_SPARSEMEM is not defined, pfns_present()
+	 *       always returns 0.
+	 */
+	ret = pfns_present(pfn, nr_pages);
+	if (ret) {
+		unlock_memory_hotplug();
+		return ret;
+	}
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
 	arg.status_change_nid = -1;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
