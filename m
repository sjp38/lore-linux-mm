Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id A81F66B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:24:23 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id i13so6863680qae.10
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:24:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k20si4458965qaa.78.2015.02.12.02.24.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 02:24:22 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH RESEND 3/3] Drivers: hv: balloon: fix deadlock between memory adding and onlining
Date: Thu, 12 Feb 2015 11:23:54 +0100
Message-Id: <1423736634-338-4-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
References: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, devel@linuxdriverproject.org, linux-mm@kvack.org

If newly added memory is brought online with e.g. udev rule:
SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"
the following deadlock is observed (and easily reproducable):

First participant, worker thread doing add_memory():
...
[  725.491469] 6 locks held by kworker/0:1/27:
[  725.505037]  #0:  ("events"){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
[  725.533370]  #1:  ((&dm_device.ha_wrk.wrk)){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
[  725.565580]  #2:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
[  725.594369]  #3:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
[  725.628554]  #4:  (mem_sysfs_mutex){......}, at: [<ffffffff81601873>] register_new_memory+0x33/0xd0
[  725.658519]  #5:  (&dev->mutex){......}, at: [<ffffffff815ed773>] device_attach+0x23/0xb0

Second participant, udev:
...
[  726.150691] 7 locks held by systemd-udevd/888:
[  726.165044]  #0:  (sb_writers#3){......}, at: [<ffffffff811fa063>] vfs_write+0x1b3/0x1f0
[  726.192422]  #1:  (&of->mutex){......}, at: [<ffffffff81279c46>] kernfs_fop_write+0x66/0x1a0
[  726.220289]  #2:  (s_active#60){......}, at: [<ffffffff81279c4e>] kernfs_fop_write+0x6e/0x1a0
[  726.249382]  #3:  (device_hotplug_lock){......}, at: [<ffffffff815e9c15>] lock_device_hotplug_sysfs+0x15/0x50
[  726.281901]  #4:  (&dev->mutex){......}, at: [<ffffffff815eb0b3>] device_online+0x23/0xa0
[  726.308619]  #5:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
[  726.337994]  #6:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80

Solve the issue bu grabbing device_hotplug_lock before doing add_memory(). If
we do that, lock_device_hotplug_sysfs() will cause syscall retry which will
eventually succeed.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/hv/hv_balloon.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b958ded..0af1aa2 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -592,9 +592,19 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 		dm_device.ha_waiting = true;
 
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
+
+		/*
+		 * Grab hotplug lock as we'll be doing device_register() and we
+		 * need to protect against someone (e.g. udev doing memory
+		 * onlining) locking it before we're done.
+		 */
+		lock_device_hotplug();
+
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
 				(HA_CHUNK << PAGE_SHIFT));
 
+		unlock_device_hotplug();
+
 		if (ret) {
 			pr_info("hot_add memory failed error is %d\n", ret);
 			if (ret == -EEXIST) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
