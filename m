Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB18A6B0271
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:26:39 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so20888594lbb.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:26:38 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ad4si1262364lbc.113.2015.11.18.01.26.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 01:26:37 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2] kasan: fix kmemleak false-positive in kasan_module_alloc()
Date: Wed, 18 Nov 2015 12:26:54 +0300
Message-ID: <1447838814-31109-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Catalin Marinas <catalin.marinas@arm.com>

Kmemleak reports the following leak:
	unreferenced object 0xfffffbfff41ea000 (size 20480):
	comm "modprobe", pid 65199, jiffies 4298875551 (age 542.568s)
	hex dump (first 32 bytes):
	  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
	backtrace:
	  [<ffffffff82354f5e>] kmemleak_alloc+0x4e/0xc0
	  [<ffffffff8152e718>] __vmalloc_node_range+0x4b8/0x740
	  [<ffffffff81574072>] kasan_module_alloc+0x72/0xc0
	  [<ffffffff810efe68>] module_alloc+0x78/0xb0
	  [<ffffffff812f6a24>] module_alloc_update_bounds+0x14/0x70
	  [<ffffffff812f8184>] layout_and_allocate+0x16f4/0x3c90
	  [<ffffffff812faa1f>] load_module+0x2ff/0x6690
	  [<ffffffff813010b6>] SyS_finit_module+0x136/0x170
	  [<ffffffff8239bbc9>] system_call_fastpath+0x16/0x1b
	  [<ffffffffffffffff>] 0xffffffffffffffff

kasan_module_alloc() allocates shadow memory for module and frees it on
module unloading. It doesn't store the pointer to allocated shadow memory
because it could be calculated from the shadowed address, i.e. kasan_mem_to_shadow(addr).
Since kmemleak cannot find pointer to allocated shadow, it thinks that
memory leaked.

Use kmemleak_ignore() to tell kmemleak that this is not a leak and shadow
memory doesn't contain any pointers.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
---
Changes since V1:
 - kmemleak_ingore() instead of kmemleak_not_leak() per Catalin

 mm/kasan/kasan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d41b21b..bc0a8d8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -19,6 +19,7 @@
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/kmemleak.h>
 #include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/mm.h>
@@ -444,6 +445,7 @@ int kasan_module_alloc(void *addr, size_t size)
 
 	if (ret) {
 		find_vm_area(addr)->flags |= VM_KASAN;
+		kmemleak_ignore(ret);
 		return 0;
 	}
 
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
