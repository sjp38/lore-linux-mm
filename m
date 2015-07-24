Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id C21899003CC
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:48:22 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so17391731ykd.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:48:22 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id p7si5876537ywc.86.2015.07.24.04.48.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 04:48:18 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 06/10] xen/balloon: only hotplug additional memory if required
Date: Fri, 24 Jul 2015 12:47:44 +0100
Message-ID: <1437738468-24110-7-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

Now that we track the total number of pages (included hotplugged
regions), it is easy to determine if more memory needs to be
hotplugged.

Add a new BP_WAIT state to signal that the balloon process needs to
wait until kicked by the memory add notifier (when the new section is
onlined by userspace).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
v2:
- New BP_WAIT status after adding new memory sections.
---
 drivers/xen/balloon.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index b5037b1..ced34cd 100644
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
 
@@ -242,12 +247,22 @@ static void release_memory_resource(struct resource *resource)
  * bit set). Real size of added memory is established at page onlining stage.
  */
 
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
+		return BP_EAGAIN;
+
 	balloon_hotplug = round_up(credit, PAGES_PER_SECTION);
 
 	resource = additional_memory_resource(balloon_hotplug * PAGE_SIZE);
@@ -287,7 +302,7 @@ static enum bp_state reserve_additional_memory(long credit)
 
 	balloon_stats.total_pages += balloon_hotplug;
 
-	return BP_DONE;
+	return BP_WAIT;
   err:
 	release_memory_resource(resource);
 	return BP_ECANCELED;
@@ -317,7 +332,7 @@ static struct notifier_block xen_memory_nb = {
 	.priority = 0
 };
 #else
-static enum bp_state reserve_additional_memory(long credit)
+static enum bp_state reserve_additional_memory(void)
 {
 	balloon_stats.target_pages = balloon_stats.current_pages;
 	return BP_DONE;
@@ -484,7 +499,7 @@ static void balloon_process(struct work_struct *work)
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
