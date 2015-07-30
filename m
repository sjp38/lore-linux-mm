Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id B1A436B025C
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:26 -0400 (EDT)
Received: by ykba194 with SMTP id a194so39222683ykb.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:26 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id t123si1305303ywe.6.2015.07.30.10.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:19 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 08/10] xen/balloon: use hotplugged pages for foreign mappings etc.
Date: Thu, 30 Jul 2015 18:03:10 +0100
Message-ID: <1438275792-5726-9-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

alloc_xenballooned_pages() is used to get ballooned pages to back
foreign mappings etc.  Instead of having to balloon out real pages,
use (if supported) hotplugged memory.

This makes more memory available to the guest and reduces
fragmentation in the p2m.

This is only enabled if the xen.balloon.hotplug_unpopulated sysctl is
set to 1.  This sysctl defaults to 0 in case the udev rules to
automatically online hotplugged memory do not exist.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
v3:
- Add xen.balloon.hotplug_unpopulated sysctl to enable use of hotplug
  for unpopulated pages.
---
 drivers/xen/balloon.c | 87 +++++++++++++++++++++++++++++++++++++++++++++------
 include/xen/balloon.h |  1 +
 2 files changed, 79 insertions(+), 9 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 2a01da7..3094f38f 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -55,6 +55,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/percpu-defs.h>
 #include <linux/slab.h>
+#include <linux/sysctl.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -71,6 +72,46 @@
 #include <xen/features.h>
 #include <xen/page.h>
 
+static int xen_hotplug_unpopulated;
+
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+
+static int zero;
+static int one = 1;
+
+static struct ctl_table balloon_table[] = {
+	{
+		.procname	= "hotplug_unpopulated",
+		.data		= &xen_hotplug_unpopulated,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1         = &zero,
+		.extra2         = &one,
+	},
+	{ }
+};
+
+static struct ctl_table balloon_root[] = {
+	{
+		.procname	= "balloon",
+		.mode		= 0555,
+		.child		= balloon_table,
+	},
+	{ }
+};
+
+static struct ctl_table xen_root[] = {
+	{
+		.procname	= "xen",
+		.mode		= 0555,
+		.child		= balloon_root,
+	},
+	{ }
+};
+
+#endif
+
 /*
  * balloon_process() state:
  *
@@ -99,6 +140,7 @@ static xen_pfn_t frame_list[PAGE_SIZE / sizeof(unsigned long)];
 
 /* List of ballooned pages, threaded through the mem_map array. */
 static LIST_HEAD(ballooned_pages);
+static DECLARE_WAIT_QUEUE_HEAD(balloon_wq);
 
 /* Main work function, always executed in process context. */
 static void balloon_process(struct work_struct *work);
@@ -127,6 +169,7 @@ static void __balloon_append(struct page *page)
 		list_add(&page->lru, &ballooned_pages);
 		balloon_stats.balloon_low++;
 	}
+	wake_up(&balloon_wq);
 }
 
 static void balloon_append(struct page *page)
@@ -242,7 +285,8 @@ static enum bp_state reserve_additional_memory(void)
 	int nid, rc;
 	unsigned long balloon_hotplug;
 
-	credit = balloon_stats.target_pages - balloon_stats.total_pages;
+	credit = balloon_stats.target_pages + balloon_stats.target_unpopulated
+		- balloon_stats.total_pages;
 
 	/*
 	 * Already hotplugged enough pages?  Wait for them to be
@@ -323,7 +367,7 @@ static struct notifier_block xen_memory_nb = {
 static enum bp_state reserve_additional_memory(void)
 {
 	balloon_stats.target_pages = balloon_stats.current_pages;
-	return BP_DONE;
+	return BP_ECANCELED;
 }
 #endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
 
@@ -517,6 +561,28 @@ void balloon_set_new_target(unsigned long target)
 }
 EXPORT_SYMBOL_GPL(balloon_set_new_target);
 
+static int add_ballooned_pages(int nr_pages)
+{
+	enum bp_state st;
+
+	if (xen_hotplug_unpopulated) {
+		st = reserve_additional_memory();
+		if (st != BP_ECANCELED) {
+			mutex_unlock(&balloon_mutex);
+			wait_event(balloon_wq,
+				   !list_empty(&ballooned_pages));
+			mutex_lock(&balloon_mutex);
+			return 0;
+		}
+	}
+
+	st = decrease_reservation(nr_pages, GFP_USER);
+	if (st != BP_DONE)
+		return -ENOMEM;
+
+	return 0;
+}
+
 /**
  * alloc_xenballooned_pages - get pages that have been ballooned out
  * @nr_pages: Number of pages to get
@@ -527,26 +593,26 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 {
 	int pgno = 0;
 	struct page *page;
+
 	mutex_lock(&balloon_mutex);
+
+	balloon_stats.target_unpopulated += nr_pages;
+
 	while (pgno < nr_pages) {
 		page = balloon_retrieve(true);
 		if (page) {
 			pages[pgno++] = page;
 		} else {
-			enum bp_state st;
-			st = decrease_reservation(nr_pages - pgno, GFP_USER);
-			if (st != BP_DONE)
+			ret = add_ballooned_pages(nr_pages - pgno);
+			if (ret < 0)
 				goto out_undo;
 		}
 	}
 	mutex_unlock(&balloon_mutex);
 	return 0;
  out_undo:
-	while (pgno)
-		balloon_append(pages[--pgno]);
-	/* Free the memory back to the kernel soon */
-	schedule_delayed_work(&balloon_worker, 0);
 	mutex_unlock(&balloon_mutex);
+	free_xenballooned_pages(pgno, pages);
 	return -ENOMEM;
 }
 EXPORT_SYMBOL(alloc_xenballooned_pages);
@@ -567,6 +633,8 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
 			balloon_append(pages[i]);
 	}
 
+	balloon_stats.target_unpopulated -= nr_pages;
+
 	/* The balloon may be too large now. Shrink it if needed. */
 	if (current_credit())
 		schedule_delayed_work(&balloon_worker, 0);
@@ -624,6 +692,7 @@ static int __init balloon_init(void)
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
 	set_online_page_callback(&xen_online_page);
 	register_memory_notifier(&xen_memory_nb);
+	register_sysctl_table(xen_root);
 #endif
 
 	/*
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
index 83efdeb..d1767df 100644
--- a/include/xen/balloon.h
+++ b/include/xen/balloon.h
@@ -8,6 +8,7 @@ struct balloon_stats {
 	/* We aim for 'current allocation' == 'target allocation'. */
 	unsigned long current_pages;
 	unsigned long target_pages;
+	unsigned long target_unpopulated;
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
