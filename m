Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id D43B6828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 11:56:34 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id 6so354682405qgy.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 08:56:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si24107401qhd.90.2016.01.12.08.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 08:56:34 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v4 2/2] xen_balloon: support memory auto onlining policy
Date: Tue, 12 Jan 2016 17:56:17 +0100
Message-Id: <1452617777-10598-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

Add support for the newly added kernel memory auto onlining policy to Xen
ballon driver.

Suggested-by: Daniel Kiper <daniel.kiper@oracle.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/xen/Kconfig   | 20 +++++++++++++-------
 drivers/xen/balloon.c | 30 +++++++++++++++++++-----------
 2 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 73708ac..098ab49 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -37,23 +37,29 @@ config XEN_BALLOON_MEMORY_HOTPLUG
 
 	  Memory could be hotplugged in following steps:
 
-	    1) dom0: xl mem-max <domU> <maxmem>
+	    1) domU: ensure that memory auto online policy is in effect by
+	       checking /sys/devices/system/memory/auto_online_blocks file
+	       (should be 'online').
+
+	    2) dom0: xl mem-max <domU> <maxmem>
 	       where <maxmem> is >= requested memory size,
 
-	    2) dom0: xl mem-set <domU> <memory>
+	    3) dom0: xl mem-set <domU> <memory>
 	       where <memory> is requested memory size; alternatively memory
 	       could be added by writing proper value to
 	       /sys/devices/system/xen_memory/xen_memory0/target or
 	       /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,
 
-	    3) domU: for i in /sys/devices/system/memory/memory*/state; do \
-	               [ "`cat "$i"`" = offline ] && echo online > "$i"; done
+	  Alternatively, if memory auto onlining was not requested at step 1
+	  the newly added memory can be manually onlined in domU by doing the
+	  following:
 
-	  Memory could be onlined automatically on domU by adding following line to udev rules:
+		for i in /sys/devices/system/memory/memory*/state; do \
+		  [ "`cat "$i"`" = offline ] && echo online > "$i"; done
 
-	  SUBSYSTEM=="memory", ACTION=="add", RUN+="/bin/sh -c '[ -f /sys$devpath/state ] && echo online > /sys$devpath/state'"
+	  or by adding the following line to udev rules:
 
-	  In that case step 3 should be omitted.
+	  SUBSYSTEM=="memory", ACTION=="add", RUN+="/bin/sh -c '[ -f /sys$devpath/state ] && echo online > /sys$devpath/state'"
 
 config XEN_BALLOON_MEMORY_HOTPLUG_LIMIT
 	int "Hotplugged memory limit (in GiB) for a PV guest"
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 890c3b5..68f0aa2 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -284,7 +284,7 @@ static void release_memory_resource(struct resource *resource)
 	kfree(resource);
 }
 
-static enum bp_state reserve_additional_memory(void)
+static enum bp_state reserve_additional_memory(bool online)
 {
 	long credit;
 	struct resource *resource;
@@ -338,7 +338,18 @@ static enum bp_state reserve_additional_memory(void)
 	}
 #endif
 
-	rc = add_memory_resource(nid, resource, false);
+	/*
+	 * add_memory_resource() will call online_pages() which in its turn
+	 * will call xen_online_page() callback causing deadlock if we don't
+	 * release balloon_mutex here. It is safe because there can only be
+	 * one balloon_process() running at a time and balloon_mutex is
+	 * internal to Xen driver, generic memory hotplug code doesn't mess
+	 * with it.
+	 */
+	mutex_unlock(&balloon_mutex);
+	rc = add_memory_resource(nid, resource, online);
+	mutex_lock(&balloon_mutex);
+
 	if (rc) {
 		pr_warn("Cannot add additional memory (%i)\n", rc);
 		goto err;
@@ -562,14 +573,11 @@ static void balloon_process(struct work_struct *work)
 
 		credit = current_credit();
 
-		if (credit > 0) {
-			if (balloon_is_inflated())
-				state = increase_reservation(credit);
-			else
-				state = reserve_additional_memory();
-		}
-
-		if (credit < 0)
+		if (credit > 0 && balloon_is_inflated())
+			state = increase_reservation(credit);
+		else if (credit > 0)
+			state = reserve_additional_memory(memhp_auto_online);
+		else if (credit < 0)
 			state = decrease_reservation(-credit, GFP_BALLOON);
 
 		state = update_schedule(state);
@@ -599,7 +607,7 @@ static int add_ballooned_pages(int nr_pages)
 	enum bp_state st;
 
 	if (xen_hotplug_unpopulated) {
-		st = reserve_additional_memory();
+		st = reserve_additional_memory(false);
 		if (st != BP_ECANCELED) {
 			mutex_unlock(&balloon_mutex);
 			wait_event(balloon_wq,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
