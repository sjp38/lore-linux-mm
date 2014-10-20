Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A7C186B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 06:06:48 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so4649260pdj.23
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 03:06:48 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id fr3si7308368pdb.233.2014.10.20.03.06.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 03:06:47 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4791F3EE1B8
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 19:06:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 3A44EAC02AB
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 19:06:45 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE43C1DB8038
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 19:06:44 +0900 (JST)
Message-ID: <5444DE75.6010206@jp.fujitsu.com>
Date: Mon, 20 Oct 2014 19:05:41 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: Clear pgdat which is allocated by bootmem
 in try_offline_node()
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: zhenzhang.zhang@huawei.com, wangnan0@huawei.com, tangchen@cn.fujitsu.com, toshi.kani@hp.com, dave.hansen@intel.com, rientjes@google.com

When hot adding the same memory after hot removing a memory,
the following messages are shown:

WARNING: CPU: 20 PID: 6 at mm/page_alloc.c:4968 free_area_init_node+0x3fe/0x426()
...
Call Trace:
 [<...>] dump_stack+0x46/0x58
 [<...>] warn_slowpath_common+0x81/0xa0
 [<...>] warn_slowpath_null+0x1a/0x20
 [<...>] free_area_init_node+0x3fe/0x426
 [<...>] ? up+0x32/0x50
 [<...>] hotadd_new_pgdat+0x90/0x110
 [<...>] add_memory+0xd4/0x200
 [<...>] acpi_memory_device_add+0x1aa/0x289
 [<...>] acpi_bus_attach+0xfd/0x204
 [<...>] ? device_register+0x1e/0x30
 [<...>] acpi_bus_attach+0x178/0x204
 [<...>] acpi_bus_scan+0x6a/0x90
 [<...>] ? acpi_bus_get_status+0x2d/0x5f
 [<...>] acpi_device_hotplug+0xe8/0x418
 [<...>] acpi_hotplug_work_fn+0x1f/0x2b
 [<...>] process_one_work+0x14e/0x3f0
 [<...>] worker_thread+0x11b/0x510
 [<...>] ? rescuer_thread+0x350/0x350
 [<...>] kthread+0xe1/0x100
 [<...>] ? kthread_create_on_node+0x1b0/0x1b0
 [<...>] ret_from_fork+0x7c/0xb0
 [<...>] ? kthread_create_on_node+0x1b0/0x1b0

The detaled explanation is as follows:

When hot removing memory, pgdat is set to 0 in try_offline_node().
But if the pgdat is allocated by bootmem allocator, the clearing
step is skipped. And when hot adding the same memory, the uninitialized
pgdat is reused. But free_area_init_node() chacks wether pgdat is set
to zero. As a result, free_area_init_node() hits WARN_ON().

This patch clears pgdat which is allocated by bootmem allocator
in try_offline_node().

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Zhang Zhen <zhenzhang.zhang@huawei.com>
CC: Wang Nan <wangnan0@huawei.com>
CC: Tang Chen <tangchen@cn.fujitsu.com>
CC: Toshi Kani <toshi.kani@hp.com>
CC: Dave Hansen <dave.hansen@intel.com>
CC: David Rientjes <rientjes@google.com>

---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 29d8693..7649f7c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1943,7 +1943,7 @@ void try_offline_node(int nid)

 	if (!PageSlab(pgdat_page) && !PageCompound(pgdat_page))
 		/* node data is allocated from boot memory */
-		return;
+		goto out;

 	/* free waittable in each zone */
 	for (i = 0; i < MAX_NR_ZONES; i++) {
@@ -1957,6 +1957,7 @@ void try_offline_node(int nid)
 			vfree(zone->wait_table);
 	}

+out:
 	/*
 	 * Since there is no way to guarentee the address of pgdat/zone is not
 	 * on stack of any kernel threads or used by other kernel objects
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
