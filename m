Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id D67656B0075
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:55 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so43932397ykd.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:55 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id o130si11743678ykf.72.2015.06.25.10.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:53 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 8/8] xen/balloon: use hotplugged pages for foreign mappings etc.
Date: Thu, 25 Jun 2015 18:11:03 +0100
Message-ID: <1435252263-31952-9-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

alloc_xenballooned_pages() is used to get ballooned pages to back
foreign mappings etc.  Instead of having to balloon out real pages,
use (if supported) hotplugged memory.

This makes more memory available to the guest and reduces
fragmentation in the p2m.

If userspace is lacking a udev rule (or similar) to online hotplugged
regions automatically, alloc_xenballooned_pages() will timeout and
fall back to the old behaviour of ballooning out pages.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/xen/balloon.c |   32 ++++++++++++++++++++++++++------
 include/xen/balloon.h |    1 +
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 95c261c..a26c5f3 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -97,6 +97,7 @@ static xen_pfn_t frame_list[PAGE_SIZE / sizeof(unsigned long)];
 
 /* List of ballooned pages, threaded through the mem_map array. */
 static LIST_HEAD(ballooned_pages);
+static DECLARE_WAIT_QUEUE_HEAD(balloon_wq);
 
 /* Main work function, always executed in process context. */
 static void balloon_process(struct work_struct *work);
@@ -125,6 +126,7 @@ static void __balloon_append(struct page *page)
 		list_add(&page->lru, &ballooned_pages);
 		balloon_stats.balloon_low++;
 	}
+	wake_up(&balloon_wq);
 }
 
 static void balloon_append(struct page *page)
@@ -247,7 +249,8 @@ static enum bp_state reserve_additional_memory(void)
 	int nid, rc;
 	unsigned long balloon_hotplug;
 
-	credit = balloon_stats.target_pages - balloon_stats.total_pages;
+	credit = balloon_stats.target_pages + balloon_stats.target_unpopulated
+		- balloon_stats.total_pages;
 
 	/*
 	 * Already hotplugged enough pages?  Wait for them to be
@@ -328,7 +331,7 @@ static struct notifier_block xen_memory_nb = {
 static enum bp_state reserve_additional_memory(void)
 {
 	balloon_stats.target_pages = balloon_stats.current_pages;
-	return BP_DONE;
+	return BP_ECANCELED;
 }
 #endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
 
@@ -532,13 +535,31 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
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
 			enum bp_state st;
+
+			st = reserve_additional_memory();
+			if (st != BP_ECANCELED) {
+				int ret;
+
+				mutex_unlock(&balloon_mutex);
+				ret = wait_event_timeout(balloon_wq,
+					!list_empty(&ballooned_pages),
+					msecs_to_jiffies(100));
+				mutex_lock(&balloon_mutex);
+				if (ret > 0)
+					continue;
+			}
+
 			st = decrease_reservation(nr_pages - pgno, GFP_USER);
 			if (st != BP_DONE)
 				goto out_undo;
@@ -547,11 +568,8 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
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
@@ -572,6 +590,8 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
 			balloon_append(pages[i]);
 	}
 
+	balloon_stats.target_unpopulated -= nr_pages;
+
 	/* The balloon may be too large now. Shrink it if needed. */
 	if (current_credit())
 		schedule_delayed_work(&balloon_worker, 0);
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
