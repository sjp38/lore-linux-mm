Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BACAF6B0089
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:06:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 510143EE0C3
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:06:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36BC445DEB4
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:06:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AD6145DEA6
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:06:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F8D1DB8040
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:06:20 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ACDE21DB803E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:06:19 +0900 (JST)
Message-ID: <4FF28BCE.7000904@jp.fujitsu.com>
Date: Tue, 3 Jul 2012 15:06:06 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2 13/13] memory-hotplug : remove sysfs file of node
References: <4FF287C3.4030901@jp.fujitsu.com>
In-Reply-To: <4FF287C3.4030901@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

The patch adds node_set_offline() and unregister_one_node() to remove_memory()
for removing sysfs file of node.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 mm/memory_hotplug.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:21.012982694 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:25.405925554 +0900
@@ -702,6 +702,11 @@ int remove_memory(int nid, u64 start, u6
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size - 1, "System RAM");

+	if (!node_present_pages(nid)) {
+		node_set_offline(nid);
+		unregister_one_node(nid);
+	}
+
 	__remove_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT);
 	unlock_memory_hotplug();
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
