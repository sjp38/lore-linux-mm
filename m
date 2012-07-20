Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6D8906B0068
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:05:48 -0400 (EDT)
Message-ID: <5009046C.106@cn.fujitsu.com>
Date: Fri, 20 Jul 2012 15:10:36 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 3/8] memory-hotplug: call remove_memory() to cleanup when
 removing memory device
References: <5009038A.4090001@cn.fujitsu.com>
In-Reply-To: <5009038A.4090001@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

We should remove the following things when removing the memory device:
1. memmap and related sysfs files
2. iomem_resource
3. mem_section and related sysfs files
4. node and related sysfs files

The function remove_memory() can do this. So call it after the memory device
is offlined.

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
 drivers/acpi/acpi_memhotplug.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 712e767..58e4e63 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -315,7 +315,7 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 {
 	int result;
 	struct acpi_memory_info *info, *n;
-
+	int node = mem_device->nid;
 
 	/*
 	 * Ask the VM to offline this memory range.
@@ -330,6 +330,11 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 				if (result)
 					return result;
 			}
+
+			result = remove_memory(node, info->start_addr,
+					       info->length);
+			if (result)
+				return result;
 		}
 		list_del(&info->list);
 		kfree(info);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
