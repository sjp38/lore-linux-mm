From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103330.5564.31067.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 9/9] mm: lockless test threads
Date: Thu, 12 Apr 2007 14:46:20 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Introduce a basic lockless pagecache test harness. I don't know what value
this has, because it hasn't caught a bug yet, but it might help with testing.

Signed-off-by: Nick Piggin <npiggin@suse.de>

 lib/Kconfig.debug |   12 +++
 mm/Makefile       |    1 
 mm/lpctest.c      |  194 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 207 insertions(+)

Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug
+++ linux-2.6/lib/Kconfig.debug
@@ -379,6 +379,18 @@ config FORCED_INLINING
 	  become the default in the future, until then this option is there to
 	  test gcc for this.
 
+config LPC_TEST
+	tristate "Background tests for lockless pagecache"
+	depends on DEBUG_KERNEL
+	default n
+	help
+	  This option provides a kernel module that runs some background
+	  threads that exercise lockless pagecache races more than usual.
+
+	  Say Y here if you want LPC test threads start automatically at
+	  boot. Say M to be able to start them by inserting the module.
+	  Say N if you are unsure.
+
 config RCU_TORTURE_TEST
 	tristate "torture tests for RCU"
 	depends on DEBUG_KERNEL
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_MEMORY_HOTPLUG) += memory_h
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
+obj-$(CONFIG_LPC_TEST) += lpctest.o
Index: linux-2.6/mm/lpctest.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/lpctest.c
@@ -0,0 +1,194 @@
+/*
+ * Lockless pagecache test thread
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Based on kernel/rcutorture.c, which is
+ * Copyright (C) IBM Corporation, 2005, 2006
+ *
+ * Copyright (C) Nick Piggin, SUSE Labs, Novell Inc, 2007
+ */
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kthread.h>
+#include <linux/err.h>
+#include <linux/spinlock.h>
+#include <linux/smp.h>
+#include <linux/interrupt.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/module.h>
+#include <linux/completion.h>
+#include <linux/moduleparam.h>
+#include <linux/percpu.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
+#include <linux/random.h>
+#include <linux/delay.h>
+#include <linux/byteorder/swabb.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Nick Piggin <npiggin@suse.de");
+
+static int random_threads = 2;	/* # random pfn threads */
+static int verbose;		/* Print more debug info. */
+
+module_param(random_threads, int, 0444);
+MODULE_PARM_DESC(nreaders, "Number of random pfn threads");
+module_param(verbose, bool, 0444);
+MODULE_PARM_DESC(verbose, "Enable verbose debugging printk()s");
+
+static struct task_struct **random_tasks;
+
+struct lpc_random_state {
+	unsigned long rrs_state;
+	long rrs_count;
+};
+
+#define LPC_RANDOM_MULT 39916801  /* prime */
+#define LPC_RANDOM_ADD	479001701 /* prime */
+#define LPC_RANDOM_REFRESH 10000
+
+#define DEFINE_LPC_RANDOM(name) struct lpc_random_state name = { 0, 0 }
+
+/*
+ * Crude but fast random-number generator.  Uses a linear congruential
+ * generator, with occasional help from get_random_bytes().
+ */
+static unsigned long lpc_random(struct lpc_random_state *rrsp)
+{
+	long refresh;
+
+	if (--rrsp->rrs_count < 0) {
+		get_random_bytes(&refresh, sizeof(refresh));
+		rrsp->rrs_state += refresh;
+		rrsp->rrs_count = LPC_RANDOM_REFRESH;
+	}
+	rrsp->rrs_state = rrsp->rrs_state * LPC_RANDOM_MULT + LPC_RANDOM_ADD;
+	return swahw32(rrsp->rrs_state);
+}
+
+/*
+ * Definitions for lpc testing.
+ */
+static void lpc_page_delay(struct lpc_random_state *rrsp)
+{
+	long rnd;
+
+	/* We want there to be long-held pages, but not all the time. */
+
+	rnd = lpc_random(rrsp);
+	if (rnd % 200 == 0)
+		udelay(20);
+	else if (rnd % 300 == 0)
+		schedule_timeout(2);
+
+}
+
+/*
+ * LPC test random kthread.  Repeatedly takes speculative references on
+ * random pages, then dropping them (possibly after a delay).
+ *
+ * This will not work properly if things start using synchronize_rcu to
+ * ensure a page will not be touched by speculative references, but so
+ * far we have avoided that.
+ */
+static int lpc_random_thread(void *arg)
+{
+	DEFINE_LPC_RANDOM(rand);
+
+	set_user_nice(current, 19);
+	current->flags |= PF_NOFREEZE;
+
+	do {
+		struct zone *zone;
+		for_each_zone(zone) {
+			unsigned long pfn;
+			unsigned int times;
+			struct page *page;
+
+			pfn = zone->zone_start_pfn +
+				lpc_random(&rand) % zone->spanned_pages;
+			if (!pfn_valid(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+
+			for (times = 1+lpc_random(&rand)%100; times; times--) {
+				int ret;
+				rcu_read_lock();
+				ret = page_cache_get_speculative(page);
+				rcu_read_unlock();
+				if (ret) {
+					lpc_page_delay(&rand);
+					page_cache_release(page);
+				}
+				lpc_page_delay(&rand);
+			}
+		}
+	} while (!kthread_should_stop());
+
+	return 0;
+}
+
+static void lpc_test_cleanup(void)
+{
+	int i;
+
+	if (random_tasks != NULL) {
+		for (i = 0; i < random_threads; i++) {
+			if (random_tasks[i] != NULL) {
+				kthread_stop(random_tasks[i]);
+				random_tasks[i] = NULL;
+			}
+		}
+		kfree(random_tasks);
+		random_tasks = NULL;
+	}
+}
+
+static int lpc_test_init(void)
+{
+	int i;
+	int err = 0;
+
+	random_tasks = kzalloc(random_threads * sizeof(random_tasks[0]),
+			       GFP_KERNEL);
+	if (random_tasks == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < random_threads; i++) {
+		random_tasks[i] = kthread_run(lpc_random_thread, NULL,
+					      "lpc_random_thread");
+		if (IS_ERR(random_tasks[i])) {
+			err = PTR_ERR(random_tasks[i]);
+			random_tasks[i] = NULL;
+			goto out;
+		}
+	}
+
+out:
+	if (err)
+		lpc_test_cleanup();
+	return err;
+}
+
+module_init(lpc_test_init);
+module_exit(lpc_test_cleanup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
