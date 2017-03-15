Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCFB46B038B
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so21974583pgc.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.01.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 01:59:59 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 2/5] mm: parallel free pages
Date: Wed, 15 Mar 2017 17:00:01 +0800
Message-Id: <1489568404-7817-3-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

For regular processes, the time taken in its exit() path to free its
used memory is not a problem. But there are heavy ones that consume
several Terabytes memory and the time taken to free its memory could
last more than ten minutes.

To optimize this use case, a parallel free method is proposed and it is
based on the current gather batch free.

The current gather batch free works like this:
For each struct mmu_gather *tlb, there is a static buffer to store those
to-be-freed page pointers. The size is MMU_GATHER_BUNDLE, which is
defined to be 8. So if a tlb tear down doesn't free more than 8 pages,
that is all we need. If 8+ pages are to be freed, new pages will need
to be allocated to store those to-be-freed page pointers.

The structure used to describe the saved page pointers is called
struct mmu_gather_batch and tlb->local is of this type. tlb->local is
different than other struct mmu_gather_batch(es) in that the page
pointer array used by tlb->local points to the previouslly described
static buffer while the other struct mmu_gather_batch(es) page pointer
array points to the dynamically allocated pages.

These batches will form a singly linked list, starting from &tlb->local.

tlb->local.pages  => tlb->pages(8 pointers)
      \|/
      next => batch1->pages => about 510 pointers
                \|/
                next => batch2->pages => about 510 pointers
                          \|/
                          next => batch3->pages => about 510 pointers
                                    ... ...

The proposed parallel free did this: if the process has many pages to be
freed, accumulate them in these struct mmu_gather_batch(es) one after
another till 256K pages are accumulated. Then take this singly linked
list starting from tlb->local.next off struct mmu_gather *tlb and free
them in a worker thread. The main thread can return to continue zap
other pages(after freeing pages pointed by tlb->local.pages).

Note that since we may be accumulating as many as 256K pages now, the
soft lockup on !CONFIG_PREEMPT issue which is fixed by
commit 53a59fc67f97 ("mm: limit mmu_gather batching to fix soft lockups
on !CONFIG_PREEMPT") can reappear. For that matter, add cond_resched()
in tlb_flush_mmu_free_batches where many pages can be freed.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/asm-generic/tlb.h | 15 +++++++------
 mm/memory.c               | 57 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 4329bc6ef04b..7c2ac179cc47 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -78,13 +78,10 @@ struct mmu_gather_batch {
 #define MAX_GATHER_BATCH	\
 	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
 
-/*
- * Limit the maximum number of mmu_gather batches to reduce a risk of soft
- * lockups for non-preemptible kernels on huge machines when a lot of memory
- * is zapped during unmapping.
- * 10K pages freed at once should be safe even without a preemption point.
- */
-#define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
+#define ASYNC_FREE_THRESHOLD (256*1024UL)
+#define MAX_GATHER_BATCH_COUNT	\
+	DIV_ROUND_UP(ASYNC_FREE_THRESHOLD, MAX_GATHER_BATCH)
+#define PAGE_FREE_NR_TO_YIELD (10000UL)
 
 /* struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
@@ -108,6 +105,10 @@ struct mmu_gather {
 	struct page		*__pages[MMU_GATHER_BUNDLE];
 	unsigned int		batch_count;
 	int page_size;
+	/* how many pages we have gathered to be freed */
+	unsigned int            page_nr;
+	/* list for spawned workers that do the free jobs */
+	struct list_head        worker_list;
 };
 
 #define HAVE_GENERIC_MMU_GATHER
diff --git a/mm/memory.c b/mm/memory.c
index cdb2a53f251f..001c7720d773 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -228,6 +228,9 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 	tlb->batch_count = 0;
+	tlb->page_nr    = 0;
+
+	INIT_LIST_HEAD(&tlb->worker_list);
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
@@ -254,22 +257,65 @@ static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
 				       bool free_batch_page)
 {
 	struct mmu_gather_batch *batch, *next;
+	int nr = 0;
 
 	for (batch = batch_start; batch; batch = next) {
 		next = batch->next;
 		if (batch->nr) {
 			free_pages_and_swap_cache(batch->pages, batch->nr);
+			nr += batch->nr;
 			batch->nr = 0;
 		}
-		if (free_batch_page)
+		if (free_batch_page) {
 			free_pages((unsigned long)batch, 0);
+			nr++;
+		}
+		if (nr >= PAGE_FREE_NR_TO_YIELD) {
+			cond_resched();
+			nr = 0;
+		}
 	}
 }
 
+struct batch_free_struct {
+	struct work_struct work;
+	struct mmu_gather_batch *batch_start;
+	struct list_head list;
+};
+
+static void batch_free_work(struct work_struct *work)
+{
+	struct batch_free_struct *batch_free = container_of(work,
+						struct batch_free_struct, work);
+	tlb_flush_mmu_free_batches(batch_free->batch_start, true);
+}
+
 static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
+	struct batch_free_struct *batch_free = NULL;
+
+	if (tlb->page_nr >= ASYNC_FREE_THRESHOLD)
+		batch_free = kmalloc(sizeof(*batch_free),
+				     GFP_NOWAIT | __GFP_NOWARN);
+
+	if (batch_free) {
+		/*
+		 * Start a worker to free pages stored
+		 * in batches following tlb->local.
+		 */
+		batch_free->batch_start = tlb->local.next;
+		INIT_WORK(&batch_free->work, batch_free_work);
+		list_add_tail(&batch_free->list, &tlb->worker_list);
+		queue_work(system_unbound_wq, &batch_free->work);
+
+		tlb->batch_count = 0;
+		tlb->local.next = NULL;
+		/* fall through to free pages stored in tlb->local */
+	}
+
 	tlb_flush_mmu_free_batches(&tlb->local, false);
 	tlb->active = &tlb->local;
+	tlb->page_nr = 0;
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -284,11 +330,18 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  */
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	struct batch_free_struct *batch_free, *n;
+
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
+	list_for_each_entry_safe(batch_free, n, &tlb->worker_list, list) {
+		flush_work(&batch_free->work);
+		kfree(batch_free);
+	}
+
 	tlb_flush_mmu_free_batches(tlb->local.next, true);
 	tlb->local.next = NULL;
 }
@@ -307,6 +360,8 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_
 	VM_BUG_ON(!tlb->end);
 	VM_WARN_ON(tlb->page_size != page_size);
 
+	tlb->page_nr++;
+
 	batch = tlb->active;
 	/*
 	 * Add the page and check if we are full. If so
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
