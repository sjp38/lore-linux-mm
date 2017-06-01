Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 206726B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:22:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f124so51139036oia.14
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:22:26 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50111.outbound.protection.outlook.com. [40.107.5.111])
        by mx.google.com with ESMTPS id n130si8445866oib.181.2017.06.01.09.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 09:22:24 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 4/4] mm/kasan: Add support for memory hotplug
Date: Thu, 1 Jun 2017 19:23:38 +0300
Message-ID: <20170601162338.23540-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170601162338.23540-1-aryabinin@virtuozzo.com>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

KASAN doesn't happen work with memory hotplug because hotplugged memory
doesn't have any shadow memory. So any access to hotplugged memory
would cause a crash on shadow check.

Use memory hotplug notifier to allocate and map shadow memory when the
hotplugged memory is going online and free shadow after the memory
offlined.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/Kconfig       |  1 -
 mm/kasan/kasan.c | 40 +++++++++++++++++++++++++++++++++++-----
 2 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f1fbde17d45d..c8df94059974 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -161,7 +161,6 @@ config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on ARCH_ENABLE_MEMORY_HOTPLUG
-	depends on COMPILE_TEST || !KASAN
 
 config MEMORY_HOTPLUG_SPARSE
 	def_bool y
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e6fe07a98677..ca11bc4ce205 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -737,17 +737,47 @@ void __asan_unpoison_stack_memory(const void *addr, size_t size)
 EXPORT_SYMBOL(__asan_unpoison_stack_memory);
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-static int kasan_mem_notifier(struct notifier_block *nb,
+static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 			unsigned long action, void *data)
 {
-	return (action == MEM_GOING_ONLINE) ? NOTIFY_BAD : NOTIFY_OK;
+	struct memory_notify *mem_data = data;
+	unsigned long nr_shadow_pages, start_kaddr, shadow_start;
+	unsigned long shadow_end, shadow_size;
+
+	nr_shadow_pages = mem_data->nr_pages >> KASAN_SHADOW_SCALE_SHIFT;
+	start_kaddr = (unsigned long)pfn_to_kaddr(mem_data->start_pfn);
+	shadow_start = (unsigned long)kasan_mem_to_shadow((void *)start_kaddr);
+	shadow_size = nr_shadow_pages << PAGE_SHIFT;
+	shadow_end = shadow_start + shadow_size;
+
+	if (WARN_ON(mem_data->nr_pages % KASAN_SHADOW_SCALE_SIZE) ||
+		WARN_ON(start_kaddr % (KASAN_SHADOW_SCALE_SIZE << PAGE_SHIFT)))
+		return NOTIFY_BAD;
+
+	switch (action) {
+	case MEM_GOING_ONLINE: {
+		void *ret;
+
+		ret = __vmalloc_node_range(shadow_size, PAGE_SIZE, shadow_start,
+					shadow_end, GFP_KERNEL,
+					PAGE_KERNEL, VM_NO_GUARD,
+					pfn_to_nid(mem_data->start_pfn),
+					__builtin_return_address(0));
+		if (!ret)
+			return NOTIFY_BAD;
+
+		kmemleak_ignore(ret);
+		return NOTIFY_OK;
+	}
+	case MEM_OFFLINE:
+		vfree((void *)shadow_start);
+	}
+
+	return NOTIFY_OK;
 }
 
 static int __init kasan_memhotplug_init(void)
 {
-	pr_info("WARNING: KASAN doesn't support memory hot-add\n");
-	pr_info("Memory hot-add will be disabled\n");
-
 	hotplug_memory_notifier(kasan_mem_notifier, 0);
 
 	return 0;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
