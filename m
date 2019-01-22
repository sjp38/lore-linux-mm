Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFD4C8E0003
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:06:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so8990312edc.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:06:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r24si3443008edp.187.2019.01.22.00.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:06:39 -0800 (PST)
From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 1/2] x86: respect memory size limiting via mem= parameter
Date: Tue, 22 Jan 2019 09:06:27 +0100
Message-Id: <20190122080628.7238-2-jgross@suse.com>
In-Reply-To: <20190122080628.7238-1-jgross@suse.com>
References: <20190122080628.7238-1-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, x86@kernel.org, linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com, sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, Juergen Gross <jgross@suse.com>

When limiting memory size via kernel parameter "mem=" this should be
respected even in case of memory made accessible via a PCI card.

Today this kind of memory won't be made usable in initial memory
setup as the memory won't be visible in E820 map, but it might be
added when adding PCI devices due to corresponding ACPI table entries.

Not respecting "mem=" can be corrected by adding a global max_mem_size
variable set by parse_memopt() which will result in rejecting adding
memory areas resulting in a memory size above the allowed limit.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/kernel/e820.c         | 5 +++++
 include/linux/memory_hotplug.h | 2 ++
 mm/memory_hotplug.c            | 6 ++++++
 3 files changed, 13 insertions(+)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 50895c2f937d..e67513e2cbbb 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -14,6 +14,7 @@
 #include <linux/acpi.h>
 #include <linux/firmware-map.h>
 #include <linux/sort.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/e820/api.h>
 #include <asm/setup.h>
@@ -881,6 +882,10 @@ static int __init parse_memopt(char *p)
 
 	e820__range_remove(mem_size, ULLONG_MAX - mem_size, E820_TYPE_RAM, 1);
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	max_mem_size = mem_size;
+#endif
+
 	return 0;
 }
 early_param("mem", parse_memopt);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 07da5c6c5ba0..fb6bd0022d41 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -98,6 +98,8 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
+extern u64 max_mem_size;
+
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..7fc2a87110a3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -96,10 +96,16 @@ void mem_hotplug_done(void)
 	cpus_read_unlock();
 }
 
+u64 max_mem_size = -1;
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
 	struct resource *res, *conflict;
+
+	if (start + size > max_mem_size)
+		return ERR_PTR(-E2BIG);
+
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
-- 
2.16.4
