Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 419A76B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:28:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z20-v6so2457471pgv.17
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:28:57 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id l14-v6si6051941pgs.155.2018.06.22.02.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 02:28:55 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 1/1] kasan: fix shadow_size calculation error in kasan_module_alloc
Date: Fri, 22 Jun 2018 17:27:06 +0800
Message-ID: <1529659626-12660-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>

There is a special case that the size is "(N << KASAN_SHADOW_SCALE_SHIFT)
Pages plus X", the value of X is [1, KASAN_SHADOW_SCALE_SIZE-1]. The
operation "size >> KASAN_SHADOW_SCALE_SHIFT" will drop X, and the roundup
operation can not retrieve the missed one page. For example: size=0x28006,
PAGE_SIZE=0x1000, KASAN_SHADOW_SCALE_SHIFT=3, we will get
shadow_size=0x5000, but actually we need 6 pages.

shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT, PAGE_SIZE);

This can lead kernel to be crashed, when kasan is enabled and the value
of mod->core_layout.size or mod->init_layout.size is like above. Because
the shadow memory of X has not been allocated and mapped.

move_module:
ptr = module_alloc(mod->core_layout.size);
...
memset(ptr, 0, mod->core_layout.size);		//crashed

Unable to handle kernel paging request at virtual address ffff0fffff97b000
......
Call trace:
[<ffff8000004694d4>] __asan_storeN+0x174/0x1a8
[<ffff800000469844>] memset+0x24/0x48
[<ffff80000025cf28>] layout_and_allocate+0xcd8/0x1800
[<ffff80000025dbe0>] load_module+0x190/0x23e8
[<ffff8000002601e8>] SyS_finit_module+0x148/0x180

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 mm/kasan/kasan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 81a2f45..f5ac4ac 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -427,12 +427,13 @@ void kasan_kfree_large(const void *ptr)
 int kasan_module_alloc(void *addr, size_t size)
 {
 	void *ret;
+	size_t scaled_size;
 	size_t shadow_size;
 	unsigned long shadow_start;

 	shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
-	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
-			PAGE_SIZE);
+	scaled_size = (size + KASAN_SHADOW_MASK) >> KASAN_SHADOW_SCALE_SHIFT;
+	shadow_size = round_up(scaled_size, PAGE_SIZE);

 	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
 		return -EINVAL;
--
1.8.3
