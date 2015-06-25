Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 972F86B0073
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:52 -0400 (EDT)
Received: by ykdy1 with SMTP id y1so43922632ykd.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:52 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id u5si11737715ykf.174.2015.06.25.10.11.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:51 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 5/8] xen/balloon: rationalize memory hotplug stats
Date: Thu, 25 Jun 2015 18:11:00 +0100
Message-ID: <1435252263-31952-6-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

The stats used for memory hotplug make no sense and are fiddled with
in odd ways.  Remove them and introduce total_pages to track the total
number of pages (both populated and unpopulated) including those within
hotplugged regions (note that this includes not yet onlined pages).

This will be useful when deciding whether additional memory needs to be
hotplugged.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/xen/balloon.c |   75 ++++++++-----------------------------------------
 include/xen/balloon.h |    5 +---
 2 files changed, 13 insertions(+), 67 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index d0121ee..960ac79 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -194,21 +194,6 @@ static enum bp_state update_schedule(enum bp_state state)
 }
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-static long current_credit(void)
-{
-	return balloon_stats.target_pages - balloon_stats.current_pages -
-		balloon_stats.hotplug_pages;
-}
-
-static bool balloon_is_inflated(void)
-{
-	if (balloon_stats.balloon_low || balloon_stats.balloon_high ||
-			balloon_stats.balloon_hotplug)
-		return true;
-	else
-		return false;
-}
-
 static struct resource *additional_memory_resource(phys_addr_t size)
 {
 	struct resource *res;
@@ -299,10 +284,7 @@ static enum bp_state reserve_additional_memory(long credit)
 		goto err;
 	}
 
-	balloon_hotplug -= credit;
-
-	balloon_stats.hotplug_pages += credit;
-	balloon_stats.balloon_hotplug = balloon_hotplug;
+	balloon_stats.total_pages += balloon_hotplug;
 
 	return BP_DONE;
   err:
@@ -318,11 +300,6 @@ static void xen_online_page(struct page *page)
 
 	__balloon_append(page);
 
-	if (balloon_stats.hotplug_pages)
-		--balloon_stats.hotplug_pages;
-	else
-		--balloon_stats.balloon_hotplug;
-
 	mutex_unlock(&balloon_mutex);
 }
 
@@ -339,32 +316,22 @@ static struct notifier_block xen_memory_nb = {
 	.priority = 0
 };
 #else
-static long current_credit(void)
+static enum bp_state reserve_additional_memory(long credit)
 {
-	unsigned long target = balloon_stats.target_pages;
-
-	target = min(target,
-		     balloon_stats.current_pages +
-		     balloon_stats.balloon_low +
-		     balloon_stats.balloon_high);
-
-	return target - balloon_stats.current_pages;
+	balloon_stats.target_pages = balloon_stats.current_pages;
+	return BP_DONE;
 }
+#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
 
-static bool balloon_is_inflated(void)
+static long current_credit(void)
 {
-	if (balloon_stats.balloon_low || balloon_stats.balloon_high)
-		return true;
-	else
-		return false;
+	return balloon_stats.target_pages - balloon_stats.current_pages;
 }
 
-static enum bp_state reserve_additional_memory(long credit)
+static bool balloon_is_inflated(void)
 {
-	balloon_stats.target_pages = balloon_stats.current_pages;
-	return BP_DONE;
+	return balloon_stats.balloon_low || balloon_stats.balloon_high;
 }
-#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
 
 static enum bp_state increase_reservation(unsigned long nr_pages)
 {
@@ -377,15 +344,6 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
-		nr_pages = min(nr_pages, balloon_stats.balloon_hotplug);
-		balloon_stats.hotplug_pages += nr_pages;
-		balloon_stats.balloon_hotplug -= nr_pages;
-		return BP_DONE;
-	}
-#endif
-
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
@@ -448,15 +406,6 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
 		.domid        = DOMID_SELF
 	};
 
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	if (balloon_stats.hotplug_pages) {
-		nr_pages = min(nr_pages, balloon_stats.hotplug_pages);
-		balloon_stats.hotplug_pages -= nr_pages;
-		balloon_stats.balloon_hotplug += nr_pages;
-		return BP_DONE;
-	}
-#endif
-
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
@@ -646,6 +595,8 @@ static void __init balloon_add_region(unsigned long start_pfn,
 		   don't subtract from it. */
 		__balloon_append(page);
 	}
+
+	balloon_stats.total_pages += extra_pfn_end - start_pfn;
 }
 
 static int __init balloon_init(void)
@@ -663,6 +614,7 @@ static int __init balloon_init(void)
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
+	balloon_stats.total_pages   = balloon_stats.current_pages;
 
 	balloon_stats.schedule_delay = 1;
 	balloon_stats.max_schedule_delay = 32;
@@ -670,9 +622,6 @@ static int __init balloon_init(void)
 	balloon_stats.max_retry_count = RETRY_UNLIMITED;
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	balloon_stats.hotplug_pages = 0;
-	balloon_stats.balloon_hotplug = 0;
-
 	set_online_page_callback(&xen_online_page);
 	register_memory_notifier(&xen_memory_nb);
 #endif
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
index cc2e1a7..c8aee7a 100644
--- a/include/xen/balloon.h
+++ b/include/xen/balloon.h
@@ -11,14 +11,11 @@ struct balloon_stats {
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
+	unsigned long total_pages;
 	unsigned long schedule_delay;
 	unsigned long max_schedule_delay;
 	unsigned long retry_count;
 	unsigned long max_retry_count;
-#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	unsigned long hotplug_pages;
-	unsigned long balloon_hotplug;
-#endif
 };
 
 extern struct balloon_stats balloon_stats;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
