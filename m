Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 881396B0074
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:53 -0400 (EDT)
Received: by ykfy125 with SMTP id y125so44022801ykf.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:53 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id o130si11743678ykf.72.2015.06.25.10.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:52 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 6/8] xen/balloon: only hotplug additional memory if required
Date: Thu, 25 Jun 2015 18:11:01 +0100
Message-ID: <1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

Now that we track the total number of pages (included hotplugged
regions), it is easy to determine if more memory needs to be
hotplugged.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/xen/balloon.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 960ac79..dd41da8 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -241,12 +241,22 @@ static void release_memory_resource(struct resource *resource)
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
@@ -316,7 +326,7 @@ static struct notifier_block xen_memory_nb = {
 	.priority = 0
 };
 #else
-static enum bp_state reserve_additional_memory(long credit)
+static enum bp_state reserve_additional_memory(void)
 {
 	balloon_stats.target_pages = balloon_stats.current_pages;
 	return BP_DONE;
@@ -483,7 +493,7 @@ static void balloon_process(struct work_struct *work)
 			if (balloon_is_inflated())
 				state = increase_reservation(credit);
 			else
-				state = reserve_additional_memory(credit);
+				state = reserve_additional_memory();
 		}
 
 		if (credit < 0)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
