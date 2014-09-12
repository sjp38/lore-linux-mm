Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BB0076B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 19:51:46 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so2243587pdj.6
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:51:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gk5si10380228pbc.246.2014.09.12.16.51.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 16:51:45 -0700 (PDT)
Date: Fri, 12 Sep 2014 16:51:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned
 memory
Message-Id: <20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org>
In-Reply-To: <20140830164120.29066.8857.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164120.29066.8857.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 30 Aug 2014 20:41:20 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch adds page state PageBallon() and functions __Set/ClearPageBalloon.
> Like PageBuddy() PageBalloon() looks like page-flag but actually this is special
> state of page->_mapcount counter. There is no conflict because ballooned pages
> cannot be mapped and cannot be in buddy allocator.
> 
> Ballooned pages are counted in vmstat counter NR_BALLOON_PAGES, it's shown them
> in /proc/meminfo and /proc/meminfo. Also this patch it exports PageBallon into
> userspace via /proc/kpageflags as KPF_BALLOON.
> 
> All new code is under CONFIG_MEMORY_BALLOON, it should be selected by
> ballooning driver which wants use this feature.

The delta from the (fixed) v1 is below.

What's up with those Kconfig/Makefile changes?  We're now including a
pile of balloon code into vmlinux when CONFIG_MEMORY_BALLOON=n?  These
changes were not changelogged?

Did we really need to put the BalloonPages count into per-zone vmstat,
global vmstat and /proc/meminfo?  Seems a bit overkillish - why so
important?

Consuming another page flag is a big deal.  We keep on nearly running
out and one day we'll run out for real.  page-flags-layout.h is
incomprehensible.  How many flags do we have left (worst-case) with this
change?  Is there no other way?  Needs extraordinary justification,
please.

 drivers/virtio/Kconfig  |    1 -
 include/linux/mm.h      |   14 ++++++++++++--
 mm/Makefile             |    3 +--
 mm/balloon_compaction.c |   16 ----------------
 4 files changed, 13 insertions(+), 21 deletions(-)

diff -puN drivers/virtio/Kconfig~mm-introduce-common-page-state-for-ballooned-memory-fix-v2 drivers/virtio/Kconfig
--- a/drivers/virtio/Kconfig~mm-introduce-common-page-state-for-ballooned-memory-fix-v2
+++ a/drivers/virtio/Kconfig
@@ -25,7 +25,6 @@ config VIRTIO_PCI
 config VIRTIO_BALLOON
 	tristate "Virtio balloon driver"
 	depends on VIRTIO
-	select MEMORY_BALLOON
 	---help---
 	 This driver supports increasing and decreasing the amount
 	 of memory within a KVM guest.
diff -puN include/linux/mm.h~mm-introduce-common-page-state-for-ballooned-memory-fix-v2 include/linux/mm.h
--- a/include/linux/mm.h~mm-introduce-common-page-state-for-ballooned-memory-fix-v2
+++ a/include/linux/mm.h
@@ -561,8 +561,18 @@ static inline int PageBalloon(struct pag
 	return IS_ENABLED(CONFIG_MEMORY_BALLOON) &&
 		atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
 }
-void __SetPageBalloon(struct page *page);
-void __ClearPageBalloon(struct page *page);
+
+static inline void __SetPageBalloon(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageBalloon(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageBalloon(page), page);
+	atomic_set(&page->_mapcount, -1);
+}
 
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
diff -puN mm/Makefile~mm-introduce-common-page-state-for-ballooned-memory-fix-v2 mm/Makefile
--- a/mm/Makefile~mm-introduce-common-page-state-for-ballooned-memory-fix-v2
+++ a/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o vmacache.o \
+			   compaction.o balloon_compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   iov_iter.o $(mmu-y)
 
@@ -64,4 +64,3 @@ obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
-obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
diff -puN mm/balloon_compaction.c~mm-introduce-common-page-state-for-ballooned-memory-fix-v2 mm/balloon_compaction.c
--- a/mm/balloon_compaction.c~mm-introduce-common-page-state-for-ballooned-memory-fix-v2
+++ a/mm/balloon_compaction.c
@@ -10,22 +10,6 @@
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
 
-void __SetPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
-	inc_zone_page_state(page, NR_BALLOON_PAGES);
-}
-EXPORT_SYMBOL(__SetPageBalloon);
-
-void __ClearPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageBalloon(page), page);
-	atomic_set(&page->_mapcount, -1);
-	dec_zone_page_state(page, NR_BALLOON_PAGES);
-}
-EXPORT_SYMBOL(__ClearPageBalloon);
-
 /*
  * balloon_devinfo_alloc - allocates a balloon device information descriptor.
  * @balloon_dev_descriptor: pointer to reference the balloon device which
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
