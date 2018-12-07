Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 784BB8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 17:35:01 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so5134426qtc.22
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 14:35:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v54sor5889826qta.59.2018.12.07.14.35.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 14:35:00 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] arm64: increase stack size for KASAN_EXTRA
Date: Fri,  7 Dec 2018 17:34:49 -0500
Message-Id: <20181207223449.38808-1-cai@lca.pw>
In-Reply-To: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us>
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com
Cc: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, arnd@arndb.de, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

If the kernel is configured with KASAN_EXTRA, the stack size is
increasted significantly due to enable this option will set
-fstack-reuse to "none" in GCC [1]. As the results, it could trigger
stack overrun quite often with 32k stack size compiled using GCC 8. For
example, this reproducer

https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/\
syscalls/madvise/madvise06.c

could trigger a "corrupted stack end detected inside scheduler" very
reliably with CONFIG_SCHED_STACK_END_CHECK enabled. Also, See other bug
reports,

https://lore.kernel.org/lkml/1542144497.12945.29.camel@gmx.us/
https://lore.kernel.org/lkml/721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us/

There are just too many functions that could have a large stack with
KASAN_EXTRA due to large local variables that have been called over and
over again without being able to reuse the stacks. Some noticiable ones
are,

size
7536 shrink_inactive_list
7440 shrink_page_list
6560 fscache_stats_show
3920 jbd2_journal_commit_transaction
3216 try_to_unmap_one
3072 migrate_page_move_mapping
3584 migrate_misplaced_transhuge_page
3920 ip_vs_lblcr_schedule
4304 lpfc_nvme_info_show
3888 lpfc_debugfs_nvmestat_data.constprop

There are other 49 functions are over 2k in size while compiling kernel
with "-Wframe-larger-than=" on this machine. Hence, it is too much work
to change Makefiles for each object to compile without
-fsanitize-address-use-after-scope individually.

[1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715#c23

Signed-off-by: Qian Cai <cai@lca.pw>
---
 arch/arm64/include/asm/memory.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index b96442960aea..56562ff01076 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -76,12 +76,17 @@
 /*
  * KASAN requires 1/8th of the kernel virtual address space for the shadow
  * region. KASAN can bloat the stack significantly, so double the (minimum)
- * stack size when KASAN is in use.
+ * stack size when KASAN is in use, and then double it again if KASAN_EXTRA is
+ * on.
  */
 #ifdef CONFIG_KASAN
 #define KASAN_SHADOW_SCALE_SHIFT 3
 #define KASAN_SHADOW_SIZE	(UL(1) << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
+#ifdef CONFIG_KASAN_EXTRA
+#define KASAN_THREAD_SHIFT	2
+#else
 #define KASAN_THREAD_SHIFT	1
+#endif /* CONFIG_KASAN_EXTRA */
 #else
 #define KASAN_SHADOW_SIZE	(0)
 #define KASAN_THREAD_SHIFT	0
-- 
2.17.2 (Apple Git-113)
