Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2DECA6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:05:26 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so2029253qcx.24
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:05:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e9si11476760qar.20.2014.01.10.11.05.23
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 11:05:24 -0800 (PST)
From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping is specified by user [v2]
Date: Fri, 10 Jan 2014 14:04:58 -0500
Message-Id: <1389380698-19361-4-git-send-email-prarit@redhat.com>
In-Reply-To: <1389380698-19361-1-git-send-email-prarit@redhat.com>
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Prarit Bhargava <prarit@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, kosaki.motohiro@gmail.com, dyoung@redhat.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org

kdump uses memmap=exactmap and mem=X values to configure the memory
mapping for the kdump kernel.  If memory is hotadded during the boot of
the kdump kernel it is possible that the page tables for the new memory
cause the kdump kernel to run out of memory.

Since the user has specified a specific mapping ACPI Memory Hotplug should be
disabled in this case.

[v2]: really add mem=

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Len Brown <lenb@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Linn Crosetto <linn@hp.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: kosaki.motohiro@gmail.com
Cc: dyoung@redhat.com
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-acpi@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/x86/kernel/e820.c         |   10 +++++++++-
 drivers/acpi/acpi_memhotplug.c |    7 ++++++-
 include/linux/memory_hotplug.h |    3 +++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 174da5f..747f36a 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -20,6 +20,7 @@
 #include <linux/firmware-map.h>
 #include <linux/memblock.h>
 #include <linux/sort.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -834,6 +835,8 @@ static int __init parse_memopt(char *p)
 		return -EINVAL;
 	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
 
+	set_acpi_no_memhotplug();
+
 	return 0;
 }
 early_param("mem", parse_memopt);
@@ -880,15 +883,20 @@ static int __init parse_memmap_one(char *p)
 
 	return *p == '\0' ? 0 : -EINVAL;
 }
+
 static int __init parse_memmap_opt(char *str)
 {
+	int ret;
+
 	while (str) {
 		char *k = strchr(str, ',');
 
 		if (k)
 			*k++ = 0;
 
-		parse_memmap_one(str);
+		ret = parse_memmap_one(str);
+		if (!ret)
+			set_acpi_no_memhotplug();
 		str = k;
 	}
 
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 4a0fa94..48b9267 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -363,6 +363,11 @@ static void acpi_memory_device_remove(struct acpi_device *device)
 
 static bool acpi_no_memhotplug;
 
+void set_acpi_no_memhotplug(void)
+{
+	acpi_no_memhotplug = true;
+}
+
 void __init acpi_memory_hotplug_init(void)
 {
 	if (acpi_no_memhotplug)
@@ -373,7 +378,7 @@ void __init acpi_memory_hotplug_init(void)
 
 static int __init disable_acpi_memory_hotplug(char *str)
 {
-	acpi_no_memhotplug = true;
+	set_acpi_no_memhotplug();
 	return 1;
 }
 __setup("acpi_no_memhotplug", disable_acpi_memory_hotplug);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4ca3d95..80f5a23 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -12,6 +12,9 @@ struct pglist_data;
 struct mem_section;
 struct memory_block;
 
+/* set flag to disable ACPI memory hotplug */
+extern void set_acpi_no_memhotplug(void);
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 /*
-- 
1.7.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
