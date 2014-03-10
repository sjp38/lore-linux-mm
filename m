Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 716D66B0069
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:48:40 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id j5so21536659qga.4
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 10:48:40 -0700 (PDT)
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [2001:4b98:c:538::197])
        by mx.google.com with ESMTPS id c50si3870086qgf.109.2014.03.10.10.48.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 10:48:39 -0700 (PDT)
Date: Mon, 10 Mar 2014 10:48:27 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH] mm: Disable mm/balloon_compaction.c completely when
 !CONFIG_BALLOON_COMPACTION
Message-ID: <20140310174738.GA2660@leaf>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Josh Triplett <josh@joshtriplett.org>, Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mm/balloon_compaction.c contains ifdefs around some of its functions
when !CONFIG_BALLOON_COMPACTION, but the remaining functions aren't used
in that case either.  Drop the ifdefs in the file, and move
mm/balloon_compaction.o to obj-$(CONFIG_BALLOON_COMPACTION).

In addition to eliminating that ifdef, this also saves some space;
bloat-o-meter statistics:
add/remove: 0/3 grow/shrink: 0/0 up/down: 0/-281 (-281)
function                                     old     new   delta
balloon_devinfo_alloc                         63       -     -63
balloon_page_enqueue                          84       -     -84
balloon_page_dequeue                         134       -    -134

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/Makefile             | 4 ++--
 mm/balloon_compaction.c | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/Makefile b/mm/Makefile
index 310c90a..1e6ab7d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o balloon_compaction.o \
+			   compaction.o \
 			   interval_tree.o list_lru.o $(mmu-y)
 
 obj-y += init-mm.o
@@ -28,7 +28,7 @@ else
 endif
 
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
-
+obj-$(CONFIG_BALLOON_COMPACTION) += balloon_compaction.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 6e45a50..8339787 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -131,7 +131,6 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 }
 EXPORT_SYMBOL_GPL(balloon_page_dequeue);
 
-#ifdef CONFIG_BALLOON_COMPACTION
 /*
  * balloon_mapping_alloc - allocates a special ->mapping for ballooned pages.
  * @b_dev_info: holds the balloon device information descriptor.
@@ -299,4 +298,3 @@ int balloon_page_migrate(struct page *newpage,
 	unlock_page(newpage);
 	return rc;
 }
-#endif /* CONFIG_BALLOON_COMPACTION */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
