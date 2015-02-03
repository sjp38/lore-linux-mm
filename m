Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3314A6B0070
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:35 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so98778651pab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:34 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id p12si3321255pdj.116.2015.02.03.09.43.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:32 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700KROIRBGX50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:35 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 03/19] kasan: disable memory hotplug
Date: Tue, 03 Feb 2015 20:42:56 +0300
Message-id: <1422985392-28652-4-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

Currently memory hotplug won't work with KASan.
As we don't have shadow for hotplugged memory,
kernel will crash on the first access to it.
To make this work we will need to allocate shadow
for new memory.

At some future point proper memory hotplug support
will be implemented. Until then, print a warning at startup and
disable memory hot-add.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/kasan/kasan.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 6dc1aa7..def8110 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/memblock.h>
+#include <linux/memory.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
 #include <linux/sched.h>
@@ -300,3 +301,23 @@ EXPORT_SYMBOL(__asan_storeN_noabort);
 /* to shut up compiler complaints */
 void __asan_handle_no_return(void) {}
 EXPORT_SYMBOL(__asan_handle_no_return);
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static int kasan_mem_notifier(struct notifier_block *nb,
+			unsigned long action, void *data)
+{
+	return (action == MEM_GOING_ONLINE) ? NOTIFY_BAD : NOTIFY_OK;
+}
+
+static int __init kasan_memhotplug_init(void)
+{
+	pr_err("WARNING: KASan doesn't support memory hot-add\n");
+	pr_err("Memory hot-add will be disabled\n");
+
+	hotplug_memory_notifier(kasan_mem_notifier, 0);
+
+	return 0;
+}
+
+module_init(kasan_memhotplug_init);
+#endif
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
