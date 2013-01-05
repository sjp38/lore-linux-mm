Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 003DE6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:27:57 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id wz7so9529325pbc.23
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:27:57 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v7 4/6] net/core: apply pm_runtime_set_memalloc_noio on network devices
Date: Sat,  5 Jan 2013 10:25:42 +0800
Message-Id: <1357352744-8138-5-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Ming Lei <ming.lei@canonical.com>, Eric Dumazet <eric.dumazet@gmail.com>, David Decotigny <david.decotigny@google.com>, Tom Herbert <therbert@google.com>, Ingo Molnar <mingo@elte.hu>

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
--
v7:
	- rebase on v3.8-rc2-next-20130104

v4:
	- call pm_runtime_set_memalloc_noio(ddev, true) after
	device_add
---
 net/core/net-sysfs.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 29c884a..67e00b2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -21,6 +21,7 @@
 #include <linux/vmalloc.h>
 #include <linux/export.h>
 #include <linux/jiffies.h>
+#include <linux/pm_runtime.h>
 
 #include "net-sysfs.h"
 
@@ -1409,6 +1410,8 @@ void netdev_unregister_kobject(struct net_device * net)
 
 	remove_queue_kobjects(net);
 
+	pm_runtime_set_memalloc_noio(dev, false);
+
 	device_del(dev);
 }
 
@@ -1453,6 +1456,8 @@ int netdev_register_kobject(struct net_device *net)
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
