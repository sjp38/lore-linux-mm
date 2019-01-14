Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE7538E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:34:20 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c84so745668qkb.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:34:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e5sor34632502qkj.13.2019.01.14.15.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 15:34:19 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH v2] page_poison: play nicely with KASAN
Date: Mon, 14 Jan 2019 18:34:05 -0500
Message-Id: <20190114233405.67843-1-cai@lca.pw>
In-Reply-To: <2e46c139-70d3-dc86-28c9-a9f263651b57@virtuozzo.com>
References: <2e46c139-70d3-dc86-28c9-a9f263651b57@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

KASAN does not play well with the page poisoning
(CONFIG_PAGE_POISONING). It triggers false positives in the allocation
path,

BUG: KASAN: use-after-free in memchr_inv+0x2ea/0x330
Read of size 8 at addr ffff88881f800000 by task swapper/0
CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc1+ #54
Call Trace:
 dump_stack+0xe0/0x19a
 print_address_description.cold.2+0x9/0x28b
 kasan_report.cold.3+0x7a/0xb5
 __asan_report_load8_noabort+0x19/0x20
 memchr_inv+0x2ea/0x330
 kernel_poison_pages+0x103/0x3d5
 get_page_from_freelist+0x15e7/0x4d90

because KASAN has not yet unpoisoned the shadow page for allocation
before it checks memchr_inv() but only found a stale poison pattern.

Also, false positives in free path,

BUG: KASAN: slab-out-of-bounds in kernel_poison_pages+0x29e/0x3d5
Write of size 4096 at addr ffff8888112cc000 by task swapper/0/1
CPU: 5 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc1+ #55
Call Trace:
 dump_stack+0xe0/0x19a
 print_address_description.cold.2+0x9/0x28b
 kasan_report.cold.3+0x7a/0xb5
 check_memory_region+0x22d/0x250
 memset+0x28/0x40
 kernel_poison_pages+0x29e/0x3d5
 __free_pages_ok+0x75f/0x13e0

due to KASAN adds poisoned redzones around slab objects, but the page
poisoning needs to poison the whole page.

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: use kasan_disable/enable_current() instead.

 mm/page_alloc.c  | 2 +-
 mm/page_poison.c | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..906250a9b89c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1945,8 +1945,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
-	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	kernel_poison_pages(page, 1 << order, 1);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index f0c15e9017c0..21d4f97cb49b 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -6,6 +6,7 @@
 #include <linux/page_ext.h>
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
+#include <linux/kasan.h>
 
 static bool want_page_poisoning __read_mostly;
 
@@ -40,7 +41,10 @@ static void poison_page(struct page *page)
 {
 	void *addr = kmap_atomic(page);
 
+	/* KASAN still think the page is in-use, so skip it. */
+	kasan_disable_current();
 	memset(addr, PAGE_POISON, PAGE_SIZE);
+	kasan_enable_current();
 	kunmap_atomic(addr);
 }
 
-- 
2.17.2 (Apple Git-113)
