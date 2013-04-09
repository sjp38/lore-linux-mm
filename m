Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id EC8CD6B0071
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:52:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 07:44:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1EF873578050
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:52:10 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LcJGd54591694
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:38:19 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LpZoj003803
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:51:36 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 14/15] mm: Add alloc-free handshake to trigger memory
 region compaction
Date: Wed, 10 Apr 2013 03:18:56 +0530
Message-ID: <20130409214853.4500.63619.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We need a way to decide when to trigger the worker threads to perform
region evacuation/compaction. So the strategy used is as follows:

Alloc path of page allocator:
----------------------------

This accurately tracks the allocations and detects the first allocation
in a new region and notes down that region number. Performing compaction
rightaway is not going to be helpful because we need free pages in the
lower regions to be able to do that. And the page allocator allocated in
this region precisely because there was no memory available in lower regions.
So the alloc path just notes down the freshly used region's id.

Free path of page allocator:
---------------------------

When we enter this path, we know that some memory is being freed. Here we
check if the alloc path had noted down any region for compaction. If so,
we trigger the worker function that tries to compact that memory.

Also, we avoid any locking/synchronization overhead over this worker
function in the alloc/free path, by attaching appropriate semantics to the
available status flags etc, such that we won't need any special locking
around them.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 57 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index db7b892..675a435 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -631,6 +631,7 @@ static void add_to_freelist(struct page *page, struct free_list *free_list,
 	struct list_head *prev_region_list, *lru;
 	struct mem_region_list *region;
 	int region_id, prev_region_id;
+	struct mem_power_ctrl *mpc;
 
 	lru = &page->lru;
 	region_id = page_zone_region_id(page);
@@ -639,6 +640,17 @@ static void add_to_freelist(struct page *page, struct free_list *free_list,
 	region->nr_free++;
 	region->zone_region->nr_free += 1 << order;
 
+	/*
+	 * If the alloc path detected the usage of a new region, now is
+	 * the time to complete the handshake and queue a worker
+	 * to try compaction on that region.
+	 */
+	mpc = &page_zone(page)->mem_power_ctrl;
+	if (!is_mem_pwr_work_in_progress(mpc) && mpc->region) {
+		set_mem_pwr_work_in_progress(mpc);
+		queue_work(system_unbound_wq, &mpc->work);
+	}
+
 	if (region->page_block) {
 		list_add_tail(lru, region->page_block);
 		return;
@@ -696,7 +708,9 @@ static void rmqueue_del_from_freelist(struct page *page,
 {
 	struct list_head *lru = &page->lru;
 	struct mem_region_list *mr_list;
-	int region_id;
+	struct zone_mem_region *zmr;
+	struct mem_power_ctrl *mpc;
+	int region_id, mt;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	WARN((free_list->list.next != lru),
@@ -706,8 +720,27 @@ static void rmqueue_del_from_freelist(struct page *page,
 	list_del(lru);
 
 	/* Fastpath */
+	region_id = free_list->next_region - free_list->mr_list;
 	mr_list = free_list->next_region;
-	mr_list->zone_region->nr_free -= 1 << order;
+	zmr = mr_list->zone_region;
+	if (region_id != 0 && (zmr->nr_free == zmr->present_pages)) {
+		/*
+		 * This is the first alloc in this memory region. So try
+		 * compacting this region in the near future. Don't bother
+		 * if this is an unmovable/non-reclaimable allocation.
+		 * Also don't try compacting region 0 because its pointless.
+		 */
+		mt = get_freepage_migratetype(page);
+		if (is_migrate_cma(mt) || mt == MIGRATE_MOVABLE ||
+						mt == MIGRATE_RECLAIMABLE) {
+
+			mpc = &page_zone(page)->mem_power_ctrl;
+			if (!is_mem_pwr_work_in_progress(mpc))
+				mpc->region = zmr;
+		}
+	}
+
+	zmr->nr_free -= 1 << order;
 
 	if (--(mr_list->nr_free)) {
 
@@ -723,7 +756,6 @@ static void rmqueue_del_from_freelist(struct page *page,
 	 * in this freelist.
 	 */
 	free_list->next_region->page_block = NULL;
-	region_id = free_list->next_region - free_list->mr_list;
 	clear_region_bit(region_id, free_list);
 
 	/* Set 'next_region' to the new first region in the freelist. */
@@ -736,7 +768,9 @@ static void del_from_freelist(struct page *page, struct free_list *free_list,
 {
 	struct list_head *prev_page_lru, *lru, *p;
 	struct mem_region_list *region;
-	int region_id;
+	struct zone_mem_region *zmr;
+	struct mem_power_ctrl *mpc;
+	int region_id, mt;
 
 	lru = &page->lru;
 
@@ -746,6 +780,25 @@ static void del_from_freelist(struct page *page, struct free_list *free_list,
 
 	region_id = page_zone_region_id(page);
 	region = &free_list->mr_list[region_id];
+
+	zmr = region->zone_region;
+	if (region_id != 0 && (zmr->nr_free == zmr->present_pages)) {
+		/*
+		 * This is the first alloc in this memory region. So try
+		 * compacting this region in the near future. Don't bother
+		 * if this is an unmovable/non-reclaimable allocation.
+		 * Also don't try compacting region 0 because its pointless.
+		 */
+		mt = get_freepage_migratetype(page);
+		if (is_migrate_cma(mt) || mt == MIGRATE_MOVABLE ||
+						mt == MIGRATE_RECLAIMABLE) {
+
+			mpc = &page_zone(page)->mem_power_ctrl;
+			if (!is_mem_pwr_work_in_progress(mpc))
+				mpc->region = zmr;
+		}
+	}
+
 	region->nr_free--;
 	region->zone_region->nr_free -= 1 << order;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
