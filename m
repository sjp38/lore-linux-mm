Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 34D4F6B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 02:37:08 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so3941667pab.27
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 23:37:07 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3A8CA3EE0C0
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 15:37:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2782A45DE63
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 15:37:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E68945DE55
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 15:37:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F3B731DB803C
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 15:37:03 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE9311DB804F
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 15:37:03 +0900 (JST)
Message-ID: <52579C69.1080304@jp.fujitsu.com>
Date: Fri, 11 Oct 2013 15:36:25 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] Release device_hotplug_lock when store_mem_state returns
 EINVAL
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: toshi.kani@hp.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org

When inserting a wrong value to /sys/devices/system/memory/memoryX/state file,
following messages are shown. And device_hotplug_lock is never released.

================================================
[ BUG: lock held when returning to user space! ]
3.12.0-rc4-debug+ #3 Tainted: G        W
------------------------------------------------
bash/6442 is leaving the kernel with locks still held!
1 lock held by bash/6442:
 #0:  (device_hotplug_lock){+.+.+.}, at: [<ffffffff8146cbb5>] lock_device_hotplug_sysfs+0x15/0x50

This issue was introdued by commit fa2be40 (drivers: base: use standard
device online/offline for state change).

This patch releases device_hotplug_lcok when store_mem_state returns EINVAL.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Toshi Kani <toshi.kani@hp.com>
CC: Seth Jennings <sjenning@linux.vnet.ibm.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/base/memory.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 9e59f65..bece691 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -333,8 +333,10 @@ store_mem_state(struct device *dev,
 		online_type = ONLINE_KEEP;
 	else if (!strncmp(buf, "offline", min_t(int, count, 7)))
 		online_type = -1;
-	else
-		return -EINVAL;
+	else {
+		ret = -EINVAL;
+		goto err;
+	}

 	switch (online_type) {
 	case ONLINE_KERNEL:
@@ -357,6 +359,7 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}

+err:
 	unlock_device_hotplug();

 	if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
