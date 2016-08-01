Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE6F36B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:44:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so16371030ith.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:44:12 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00104.outbound.protection.outlook.com. [40.107.0.104])
        by mx.google.com with ESMTPS id c133si19807053oif.84.2016.08.01.07.44.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:44:11 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/6] mm/kasan: don't reduce quarantine in atomic contexts
Date: Mon, 1 Aug 2016 17:45:11 +0300
Message-ID: <1470062715-14077-2-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Currently we call quarantine_reduce() for ___GFP_KSWAPD_RECLAIM
(implied by __GFP_RECLAIM) allocation. So, basically we call it on
almost every allocation. quarantine_reduce() sometimes is heavy operation,
and calling it with disabled interrupts may trigger hard LOCKUP:

 NMI watchdog: Watchdog detected hard LOCKUP on cpu 2irq event stamp: 1411258
 Call Trace:
  <NMI>  [<ffffffff98a48532>] dump_stack+0x68/0x96
  [<ffffffff98357fbb>] watchdog_overflow_callback+0x15b/0x190
  [<ffffffff9842f7d1>] __perf_event_overflow+0x1b1/0x540
  [<ffffffff98455b14>] perf_event_overflow+0x14/0x20
  [<ffffffff9801976a>] intel_pmu_handle_irq+0x36a/0xad0
  [<ffffffff9800ba4c>] perf_event_nmi_handler+0x2c/0x50
  [<ffffffff98057058>] nmi_handle+0x128/0x480
  [<ffffffff980576d2>] default_do_nmi+0xb2/0x210
  [<ffffffff980579da>] do_nmi+0x1aa/0x220
  [<ffffffff99a0bb07>] end_repeat_nmi+0x1a/0x1e
  <<EOE>>  [<ffffffff981871e6>] __kernel_text_address+0x86/0xb0
  [<ffffffff98055c4b>] print_context_stack+0x7b/0x100
  [<ffffffff98054e9b>] dump_trace+0x12b/0x350
  [<ffffffff98076ceb>] save_stack_trace+0x2b/0x50
  [<ffffffff98573003>] set_track+0x83/0x140
  [<ffffffff98575f4a>] free_debug_processing+0x1aa/0x420
  [<ffffffff98578506>] __slab_free+0x1d6/0x2e0
  [<ffffffff9857a9b6>] ___cache_free+0xb6/0xd0
  [<ffffffff9857db53>] qlist_free_all+0x83/0x100
  [<ffffffff9857df07>] quarantine_reduce+0x177/0x1b0
  [<ffffffff9857c423>] kasan_kmalloc+0xf3/0x100

Reduce the quarantine_reduce iff direct reclaim is allowed.

Fixes: 55834c59098d("mm: kasan: initial memory quarantine implementation")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 3019cec..c99ef40 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -565,7 +565,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-	if (flags & __GFP_RECLAIM)
+	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
 
 	if (unlikely(object == NULL))
@@ -596,7 +596,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-	if (flags & __GFP_RECLAIM)
+	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
 
 	if (unlikely(ptr == NULL))
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
