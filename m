Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id C00256B006C
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:07:21 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id i50so7464593qgf.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 12:07:21 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0146.outbound.protection.outlook.com. [65.55.169.146])
        by mx.google.com with ESMTPS id a4si1644350qcf.32.2015.01.20.12.07.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Jan 2015 12:07:20 -0800 (PST)
Date: Tue, 20 Jan 2015 14:02:00 -0600
From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages' on
 PPC builds
Message-ID: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, Josh Triplett <josh@joshtriplett.org>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

It's possible to configure DEBUG_PAGEALLOC without PAGE_POISONING on
ppc.  Fix building the generic kernel_map_pages() implementation in
this case:

  LD      init/built-in.o
mm/built-in.o: In function `free_pages_prepare':
mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
mm/built-in.o: In function `prep_new_page':
mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
mm/built-in.o: In function `map_pages':
mm/compaction.c:61: undefined reference to `.kernel_map_pages'
make: *** [vmlinux] Error 1

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 mm/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Makefile b/mm/Makefile
index 4bf586e..2956467 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
+obj-$(CONFIG_DEBUG_PAGEALLOC) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
