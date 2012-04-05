Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 598C36B004D
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 14:07:54 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1981082bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 11:07:52 -0700 (PDT)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [PATCH 1/2] acpi: remove section mappings on memory hot-remove
Date: Thu,  5 Apr 2012 20:07:01 +0200
Message-Id: <1333649222-24285-2-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1333649222-24285-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1333649222-24285-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>


Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/acpi_memhotplug.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index d985713..75d33cd 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
+#include <linux/mm.h>
 #include <linux/memory_hotplug.h>
 #include <linux/slab.h>
 #include <acpi/acpi_drivers.h>
@@ -310,7 +311,8 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 {
 	int result;
 	struct acpi_memory_info *info, *n;
-
+	int start_pfn, end_pfn;
+	struct zone *zone;
 
 	/*
 	 * Ask the VM to offline this memory range.
@@ -321,6 +323,19 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 			result = remove_memory(info->start_addr, info->length);
 			if (result)
 				return result;
+			/*
+			 * Remove section mappings and sysfs entries for the
+			 * section of the memory we are removing.
+			 */
+
+			start_pfn = PFN_DOWN(info->start_addr);
+			end_pfn = start_pfn + PFN_DOWN(info->length);
+			zone = page_zone(pfn_to_page(start_pfn));
+			result = __remove_pages(zone, start_pfn,
+						end_pfn - start_pfn);
+			if (result)
+				return result;
+
 		}
 		kfree(info);
 	}
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
