Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7B86F828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:31:02 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id x1so38191619qkc.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 05:31:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si13343594qgd.110.2016.01.15.05.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 05:31:01 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v6 2/2] xen_balloon: support memory auto onlining policy
Date: Fri, 15 Jan 2016 14:30:45 +0100
Message-Id: <1452864645-27778-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1452864645-27778-1-git-send-email-vkuznets@redhat.com>
References: <1452864645-27778-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

Add support for the newly added kernel memory auto onlining policy to Xen
ballon driver.

Suggested-by: Daniel Kiper <daniel.kiper@oracle.com>
Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
Acked-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
Changes since v5:
- Change the last 'domU' -> 'target domain' in Kconfig [Daniel Kiper]
---
 drivers/xen/Kconfig   | 23 +++++++++++++++--------
 drivers/xen/balloon.c | 11 ++++++++++-
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 73708ac..979a8317 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -37,23 +37,30 @@ config XEN_BALLOON_MEMORY_HOTPLUG
 
 	  Memory could be hotplugged in following steps:
 
-	    1) dom0: xl mem-max <domU> <maxmem>
+	    1) target domain: ensure that memory auto online policy is in
+	       effect by checking /sys/devices/system/memory/auto_online_blocks
+	       file (should be 'online').
+
+	    2) control domain: xl mem-max <target-domain> <maxmem>
 	       where <maxmem> is >= requested memory size,
 
-	    2) dom0: xl mem-set <domU> <memory>
+	    3) control domain: xl mem-set <target-domain> <memory>
 	       where <memory> is requested memory size; alternatively memory
 	       could be added by writing proper value to
 	       /sys/devices/system/xen_memory/xen_memory0/target or
-	       /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,
+	       /sys/devices/system/xen_memory/xen_memory0/target_kb on the
+	       target domain.
 
-	    3) domU: for i in /sys/devices/system/memory/memory*/state; do \
-	               [ "`cat "$i"`" = offline ] && echo online > "$i"; done
+	  Alternatively, if memory auto onlining was not requested at step 1
+	  the newly added memory can be manually onlined in the target domain
+	  by doing the following:
 
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
index 890c3b5..f8cca0c 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -338,7 +338,16 @@ static enum bp_state reserve_additional_memory(void)
 	}
 #endif
 
-	rc = add_memory_resource(nid, resource, false);
+	/*
+	 * add_memory_resource() will call online_pages() which in its turn
+	 * will call xen_online_page() callback causing deadlock if we don't
+	 * release balloon_mutex here. Unlocking here is safe because the
+	 * callers drop the mutex before trying again.
+	 */
+	mutex_unlock(&balloon_mutex);
+	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	mutex_lock(&balloon_mutex);
+
 	if (rc) {
 		pr_warn("Cannot add additional memory (%i)\n", rc);
 		goto err;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
