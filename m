Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D964A6B0070
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 06:07:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E30093EE0C0
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CABF445DE7E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 741DC45DEB4
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F5CD1DB8049
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:57 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 04C7F1DB8042
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:57 +0900 (JST)
Message-ID: <50068AE9.3050804@jp.fujitsu.com>
Date: Wed, 18 Jul 2012 19:07:37 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v4 3/13] memory-hotplug : check whether memory is present
 or not
References: <50068974.1070409@jp.fujitsu.com>
In-Reply-To: <50068974.1070409@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

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
 include/linux/mmzone.h |   21 +++++++++++++++++++++
 mm/memory_hotplug.c    |   13 +++++++++++++
 2 files changed, 34 insertions(+)

Index: linux-3.5-rc6/include/linux/mmzone.h
===================================================================
--- linux-3.5-rc6.orig/include/linux/mmzone.h	2012-07-08 09:23:56.000000000 +0900
+++ linux-3.5-rc6/include/linux/mmzone.h	2012-07-17 16:10:21.588186145 +0900
@@ -1168,6 +1168,27 @@ void sparse_init(void);
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_SPARSEMEM
+static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
+{
+	int i;
+	for (i = 0; i < nr_pages; i++) {
+		if (pfn_present(pfn + 1))
+			continue;
+		else {
+			unlock_memory_hotplug();
+			return -EINVAL;
+		}
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
Index: linux-3.5-rc6/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-17 14:26:40.000000000 +0900
+++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-17 16:09:50.070580170 +0900
@@ -467,6 +467,19 @@ int __ref online_pages(unsigned long pfn
 	struct memory_notify arg;
 
 	lock_memory_hotplug();
+	/*
+ 	 * If system supports memory hot-remove, the memory may have been
+ 	 * removed. So we check whether the memory has been removed or not.
+ 	 *
+ 	 * Note: When CONFIG_SPARSEMEM is defined, pfns_present() become
+ 	 *       effective. If CONFIG_SPARSEMEM is not defined, pfns_present()
+ 	 *       always returns 0.
+ 	 */
+	ret = pfns_present(pfn, nr_pages);
+	if (ret) {
+		unlock_memory_hotplug();
+		return ret;
+	}
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
 	arg.status_change_nid = -1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
