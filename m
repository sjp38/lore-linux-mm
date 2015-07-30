Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDE76B025D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:29 -0400 (EDT)
Received: by ykay190 with SMTP id y190so39043018yka.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:28 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o142si1264864ywd.173.2015.07.30.10.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:20 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 06/10] xen/balloon: only hotplug additional memory if required
Date: Thu, 30 Jul 2015 18:03:08 +0100
Message-ID: <1438275792-5726-7-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

Now that we track the total number of pages (included hotplugged
regions), it is easy to determine if more memory needs to be
hotplugged.

Add a new BP_WAIT state to signal that the balloon process needs to
wait until kicked by the memory add notifier (when the new section is
onlined by userspace).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
v3:
- Return BP_WAIT if enough sections are already hotplugged.

v2:
- New BP_WAIT status after adding new memory sections.
---
 drivers/xen/balloon.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 932d232..e8b45e8 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -75,12 +75,14 @@
  * balloon_process() state:
  *
  * BP_DONE: done or nothing to do,
+ * BP_WAIT: wait to be rescheduled,
  * BP_EAGAIN: error, go to sleep,
  * BP_ECANCELED: error, balloon operation canceled.
  */
 
 enum bp_state {
 	BP_DONE,
+	BP_WAIT,
 	BP_EAGAIN,
 	BP_ECANCELED
 };
@@ -167,6 +169,9 @@ static struct page *balloon_next_page(struct page *page)
 
 static enum bp_state update_schedule(enum bp_state state)
 {
+	if (state == BP_WAIT)
+		return BP_WAIT;
+
 	if (state == BP_ECANCELED)
 		return BP_ECANCELED;
 
@@ -231,12 +236,22 @@ static void release_memory_resource(struct resource *resource)
 	kfree(resource);
 }
 
-static enum bp_state reserve_additional_memory(long credit)
+static enum bp_state reserve_additional_memory(void)
 {
+	long credit;
 	struct resource *resource;
 	int nid, rc;
 	unsigned long balloon_hotplug;
 
+	credit = balloon_stats.target_pages - balloon_stats.total_pages;
+
+	/*
+	 * Already hotplugged enough pages?  Wait for them to be
+	 * onlined.
+	 */
+	if (credit <= 0)
+		return BP_WAIT;
+
 	balloon_hotplug = round_up(credit, PAGES_PER_SECTION);
 
 	resource = additional_memory_resource(balloon_hotplug * PAGE_SIZE);
@@ -276,7 +291,7 @@ static enum bp_state reserve_additional_memory(long credit)
 
 	balloon_stats.total_pages += balloon_hotplug;
 
-	return BP_DONE;
+	return BP_WAIT;
   err:
 	release_memory_resource(resource);
 	return BP_ECANCELED;
@@ -306,7 +321,7 @@ static struct notifier_block xen_memory_nb = {
 	.priority = 0
 };
 #else
-static enum bp_state reserve_additional_memory(long credit)
+static enum bp_state reserve_additional_memory(void)
 {
 	balloon_stats.target_pages = balloon_stats.current_pages;
 	return BP_DONE;
@@ -473,7 +488,7 @@ static void balloon_process(struct work_struct *work)
 			if (balloon_is_inflated())
 				state = increase_reservation(credit);
 			else
-				state = reserve_additional_memory(credit);
+				state = reserve_additional_memory();
 		}
 
 		if (credit < 0)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
