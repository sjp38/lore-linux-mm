Message-ID: <480BD01D.4000201@linux.intel.com>
Date: Sun, 20 Apr 2008 16:22:05 -0700
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Proof of concept: sorting per-cpu-page lists to reduce memory fragmentation
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

Right now, the per-cpu page lists are interfering somewhat with the buddy allocator in
terms of keeping the free memory pool unfragmented. This proof-of-concept patch
(just to show the idea) tries to improve that situation by sorting the per-cpu page
lists by physical address, with the idea that when the pcp list gives a chunk of itself
back to the global pool, the chunk it gives back isn't random but actually very localized,
if not already containing contiguous parts.. as opposed to pure random ordering.

Now, there's some issues I need to resolve before I can really propose this for merging:
1) Measuring success. Measuring fragmentation is a *hard* problem. Measurements I've done so
    far tend to show a little improvement, but that's very subjective since it's basically
    impossible to get reproducable results. Ideas on how to measure this are VERY welcome
2) Cache locality; the head of the pcp list in theory is cache hot; the current code doesn't
    take that into account. It's easy to not sort the, say, first 5 pages though; not done
    in the current implementation

The patch below implements this, and has a hacky sysreq to print cpu 0's pcp list out
(I use this to verify that the sort works).


I'm posting this to get early feedback/comments on the approach; I fully realize that the code
is far from perfect obviously...




---
  arch/x86/kernel/process_64.c |    3 +
  drivers/char/sysrq.c         |   30 +++++++++++++-
  mm/page_alloc.c              |   87 ++++++++++++++++++++++++++++++++++++++++++
  3 files changed, 118 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 91dc9c1..341a775 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -158,6 +158,8 @@ static inline void play_dead(void)
  }
  #endif /* CONFIG_HOTPLUG_CPU */

+extern void sort_pcp_list(void);
+
  /*
   * The idle thread. There's no useful work to be
   * done, so just try to conserve power and have a
@@ -181,6 +183,7 @@ void cpu_idle(void)
  	/* endless idle loop with no priority at all */
  	while (1) {
  		tick_nohz_stop_sched_tick();
+		sort_pcp_list();
  		while (!need_resched()) {
  			void (*idle)(void);

diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
index de60e1e..21e42b5 100644
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -148,6 +148,32 @@ static struct sysrq_key_op sysrq_reboot_op = {
  	.enable_mask	= SYSRQ_ENABLE_BOOT,
  };

+extern void print_pcp_list(unsigned int cpu);
+extern void sort_pcp_list(void);
+
+static void sysrq_handle_memdump(int key, struct tty_struct *tty)
+{
+	 print_pcp_list(0);
+}
+static struct sysrq_key_op sysrq_memdump_op = {
+	.handler	= sysrq_handle_memdump,
+	.help_msg	= "memdumpY",
+	.action_msg	= "Dumping",
+	.enable_mask	= SYSRQ_ENABLE_BOOT,
+};
+
+static void sysrq_handle_memsort(int key, struct tty_struct *tty)
+{
+	sort_pcp_list();
+}
+static struct sysrq_key_op sysrq_memsort_op = {
+	.handler	= sysrq_handle_memsort,
+	.help_msg	= "memsortZ",
+	.action_msg	= "Sorting",
+	.enable_mask	= SYSRQ_ENABLE_BOOT,
+};
+
+
  static void sysrq_handle_sync(int key, struct tty_struct *tty)
  {
  	emergency_sync();
@@ -357,8 +383,8 @@ static struct sysrq_key_op *sysrq_key_table[36] = {
  	&sysrq_showstate_blocked_op,	/* w */
  	/* x: May be registered on ppc/powerpc for xmon */
  	NULL,				/* x */
-	NULL,				/* y */
-	NULL				/* z */
+	&sysrq_memdump_op,		/* y */
+	&sysrq_memsort_op		/* z */
  };

  /* key2index calculation, -1 on invalid index */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 402a504..414f7ec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -900,6 +900,93 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
  }
  #endif

+static int swaps;
+
+/*
+ * Print continuity count for per cpu page lists
+ */
+void print_pcp_list(unsigned int cpu)
+{
+	unsigned long flags;
+	struct zone *zone;
+	struct page *page;
+
+	printk("Swaps done so far: %i \n", swaps);
+
+	for_each_zone(zone) {
+		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
+
+		if (!populated_zone(zone))
+			continue;
+
+
+		pset = zone_pcp(zone, cpu);
+
+		pcp = &pset->pcp;
+		printk("Zone %s \n", zone->name);
+		local_irq_save(flags);
+			list_for_each_entry(page, &pcp->list, lru)
+				printk("Page %x \n", page_to_pfn(page));
+	
+		local_irq_restore(flags);
+	}
+}
+
+/*
+ * Print continuity count for per cpu page lists
+ */
+void sort_pcp_list(void)
+{
+	unsigned long flags;
+	struct zone *zone;
+	struct page *page, *page2;
+
+	for_each_zone(zone) {
+		struct per_cpu_pageset *pset;
+		struct list_head *cursor, *next;
+		struct per_cpu_pages *pcp;
+
+
+		if (!populated_zone(zone))
+			continue;
+
+
+		local_irq_save(flags);
+		pset = zone_pcp(zone, smp_processor_id());
+
+		pcp = &pset->pcp;
+		cursor = &pcp->list;
+		cursor = cursor->next;
+		while (cursor != &pcp->list) {
+			next = cursor->next;
+			if (next == &pcp->list)
+				break;
+
+			if (need_resched())
+				break;
+
+			page  = list_entry(cursor, struct page, lru);
+			page2 = list_entry(next, struct page, lru);
+
+			if (page_to_pfn(page) > page_to_pfn(page2)) {
+				page->lru.prev->next = &page2->lru;
+				page2->lru.next->prev = &page->lru;
+				page->lru.next = page2->lru.next;
+				page2->lru.prev = page->lru.prev;
+
+				page->lru.prev = &page2->lru;
+				page2->lru.next = &page->lru;
+				swaps++;
+			} else {
+				cursor = cursor->next;
+			}
+		}
+	
+		local_irq_restore(flags);
+	}
+}
+
  /*
   * Drain pages of the indicated processor.
   *
-- 
1.5.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
