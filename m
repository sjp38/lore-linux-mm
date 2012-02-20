Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 998EB6B00E7
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:22:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:22:53 -0800 (PST)
Subject: [PATCH v2 04/22] mm: drain percpu lru add/rotate page-vectors on cpu
 hot-unplug
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:22:50 +0400
Message-ID: <20120220172250.22196.16894.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This cpu hotplug hook was accidentally removed in commit v2.6.30-rc4-18-g00a62ce
("mm: fix Committed_AS underflow on large NR_CPUS environment")

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/swap.h |    1 +
 mm/page_alloc.c      |    1 +
 mm/swap.c            |    4 ++--
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index f7df3ea..ba2c8d7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -229,6 +229,7 @@ extern void lru_add_page_tail(struct zone* zone,
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
+extern void lru_add_drain_cpu(int cpu);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_page(struct page *page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a547177..85517af 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4873,6 +4873,7 @@ static int page_alloc_cpu_notify(struct notifier_block *self,
 	int cpu = (unsigned long)hcpu;
 
 	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
+		lru_add_drain_cpu(cpu);
 		drain_pages(cpu);
 
 		/*
diff --git a/mm/swap.c b/mm/swap.c
index fff1ff7..38b2686 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -496,7 +496,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
  * Either "cpu" is the current CPU, and preemption has already been
  * disabled; or "cpu" is being hot-unplugged, and is already dead.
  */
-static void drain_cpu_pagevecs(int cpu)
+void lru_add_drain_cpu(int cpu)
 {
 	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
 	struct pagevec *pvec;
@@ -553,7 +553,7 @@ void deactivate_page(struct page *page)
 
 void lru_add_drain(void)
 {
-	drain_cpu_pagevecs(get_cpu());
+	lru_add_drain_cpu(get_cpu());
 	put_cpu();
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
