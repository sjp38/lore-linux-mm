Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 02E4C6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:25:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8AEBA3EE081
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:25:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6777A45DE5A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:25:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C7CA45DE4E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:25:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 402A51DB8041
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:25:20 +0900 (JST)
Received: from g01jpexchyt02.g01.fujitsu.local (g01jpexchyt02.g01.fujitsu.local [10.128.194.41])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDE641DB8038
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:25:19 +0900 (JST)
Message-ID: <4FFAB17F.2090209@jp.fujitsu.com>
Date: Mon, 9 Jul 2012 19:25:03 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v3 3/13] memory-hotplug : unify argument of firmware_map_add_early/hotplug
References: <4FFAB0A2.8070304@jp.fujitsu.com>
In-Reply-To: <4FFAB0A2.8070304@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

There are two ways to create /sys/firmware/memmap/X sysfs:

  - firmware_map_add_early
    When the system starts, it is calledd from e820_reserve_resources()
  - firmware_map_add_hotplug
    When the memory is hot plugged, it is called from add_memory()

But these functions are called without unifying value of end argument as below:

  - end argument of firmware_map_add_early()   : start + size - 1
  - end argument of firmware_map_add_hogplug() : start + size

The patch unifies them to "start + size - 1".

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
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-3.5-rc6/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-09 18:08:43.476719455 +0900
+++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-09 18:13:57.664791810 +0900
@@ -642,7 +642,7 @@ int __ref add_memory(int nid, u64 start,
 	}

 	/* create new memmap entry */
-	firmware_map_add_hotplug(start, start + size, "System RAM");
+	firmware_map_add_hotplug(start, start + size - 1, "System RAM");

 	goto out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
