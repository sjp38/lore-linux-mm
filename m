Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5FAD56B0096
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 22:31:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DEE5C3EE0BC
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:31:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BBB45DEBE
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:31:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A849A45DEBA
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:31:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9171DB8043
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:31:39 +0900 (JST)
Received: from g01jpexchkw05.g01.fujitsu.local (g01jpexchkw05.g01.fujitsu.local [10.0.194.44])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A1581DB803E
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:31:39 +0900 (JST)
Message-ID: <506E466B.4050903@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 11:31:07 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/10] memory-hotplug : unregister memory section on SPARSEMEM_VMEMMAP
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Currently __remove_section for SPARSEMEM_VMEMMAP does nothing. But even if
we use SPARSEMEM_VMEMMAP, we can unregister the memory_section.

So the patch add unregister_memory_section() into __remove_section().

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 18:29:50.577668254 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 18:29:58.284676075 +0900
@@ -279,11 +279,14 @@ static int __meminit __add_section(int n
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
-	/*
-	 * XXX: Freeing memmap with vmemmap is not implement yet.
-	 *      This should be removed later.
-	 */
-	return -EBUSY;
+	int ret = -EINVAL;
+
+	if (!valid_section(ms))
+		return ret;
+
+	ret = unregister_memory_section(ms);
+
+	return ret;
 }
 #else
 static int __remove_section(struct zone *zone, struct mem_section *ms)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
