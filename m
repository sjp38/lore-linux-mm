Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4C5946B0068
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:55:01 -0400 (EDT)
Date: Fri, 15 Jun 2012 17:54:32 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 02.5] mm: sl[au]b: first remove PFMEMALLOC flag then SLAB flag
Message-ID: <20120615155432.GA5498@breakpoint.cc>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
 <1337266231-8031-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337266231-8031-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

If we first remove the SLAB flag followed by the PFMEMALLOC flag then the
removal of the latter will trigger the VM_BUG_ON() as it can be seen in
| kernel BUG at include/linux/page-flags.h:474!
| invalid opcode: 0000 [#1] PREEMPT SMP
| Call Trace:
|  [<c10e2d77>] slab_destroy+0x27/0x70
|  [<c10e3285>] drain_freelist+0x55/0x90
|  [<c10e344e>] __cache_shrink+0x6e/0x90
|  [<c14e3211>] ? acpi_sleep_init+0xcf/0xcf
|  [<c10e349d>] kmem_cache_shrink+0x2d/0x40

because the SLAB flag is gone. This patch simply changes the order.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/slab.c |    2 +-
 mm/slub.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 00c601b..b1a39f7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2007,8 +2007,8 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
 	while (i--) {
 		BUG_ON(!PageSlab(page));
-		__ClearPageSlab(page);
 		__ClearPageSlabPfmemalloc(page);
+		__ClearPageSlab(page);
 		page++;
 	}
 	if (current->reclaim_state)
diff --git a/mm/slub.c b/mm/slub.c
index f8cbec4..d753146 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1417,8 +1417,8 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
-	__ClearPageSlab(page);
 	__ClearPageSlabPfmemalloc(page);
+	__ClearPageSlab(page);
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
