Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 21E2B6B0044
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 07:35:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4074622pad.14
        for <linux-mm@kvack.org>; Sun, 11 Nov 2012 04:35:52 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v5 4/6] net/core: apply pm_runtime_set_memalloc_noio on network devices
Date: Sun, 11 Nov 2012 20:34:36 +0800
Message-Id: <1352637278-19968-5-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1352637278-19968-1-git-send-email-ming.lei@canonical.com>
References: <1352637278-19968-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>, Eric Dumazet <eric.dumazet@gmail.com>, David Decotigny <david.decotigny@google.com>, Tom Herbert <therbert@google.com>, Ingo Molnar <mingo@elte.hu>

Deadlock might be caused by allocating memory with GFP_KERNEL in
runtime_resume and runtime_suspend callback of network devices in
iSCSI situation, so mark network devices and its ancestor as
'memalloc_noio' with the introduced pm_runtime_set_memalloc_noio().

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Decotigny <david.decotigny@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
v4:
	 - call pm_runtime_set_memalloc_noio(ddev, true) after
	   device_add
---
 net/core/net-sysfs.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bcf02f6..a55d255 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -22,6 +22,7 @@
 #include <linux/vmalloc.h>
 #include <linux/export.h>
 #include <linux/jiffies.h>
+#include <linux/pm_runtime.h>
 #include <net/wext.h>
 
 #include "net-sysfs.h"
@@ -1386,6 +1387,8 @@ void netdev_unregister_kobject(struct net_device * net)
 
 	remove_queue_kobjects(net);
 
+	pm_runtime_set_memalloc_noio(dev, false);
+
 	device_del(dev);
 }
 
@@ -1421,6 +1424,8 @@ int netdev_register_kobject(struct net_device *net)
 		return error;
 	}
 
+	pm_runtime_set_memalloc_noio(dev, true);
+
 	return error;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
