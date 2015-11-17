Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 16EBC6B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 11:20:05 -0500 (EST)
Received: by lffu14 with SMTP id u14so8689632lff.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 08:20:04 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 197si25378291lfk.13.2015.11.17.08.20.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 08:20:03 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kasan: fix kmemleak false-positive in kasan_module_alloc()
Date: Tue, 17 Nov 2015 19:20:22 +0300
Message-ID: <1447777222-13396-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

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

kasan_module_alloc() allocates shadow memory for module and frees it on module
unloading. It doesn't store the pointer to allocated shadow memory because
it could be calculated from the shadowed address, i.e. kasan_mem_to_shadow(addr).
Since kmemleak cannot find pointer to allocated shadow, it thinks that memory leaked.
We should tell kmemleak that this is not a leak.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d41b21b..413b12d 100644
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
+		kmemleak_not_leak(ret);
 		return 0;
 	}
 
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
