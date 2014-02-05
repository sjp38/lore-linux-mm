Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 470066B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 11:29:12 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so470908wgh.16
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 08:29:11 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id d8si50790083eeh.137.2014.02.05.08.29.09
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 08:29:10 -0800 (PST)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC] Move the memory_notifier out of the memory_hotplug lock
Date: Wed,  5 Feb 2014 10:29:03 -0600
Message-Id: <1391617743-150518-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nathan Zimmer <nzimmer@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

There are a few spots where we call memory_notifier. This doesn't need to be
done under lock since memory_notify is just a blocking_notifier_call_chain
with it's own locking mechanism.

This RFC is a follow on to the one I submitted earlier.
(move register_memory_resource out of the lock_memory_hotplug, commit ac13c46)
Most of our time is being spend under the memory hotplug lock in particular
online_pages() so it makes sense to move out everything that can be easily
moved out.

However perf pointed me to a spot to work on, setup_zone_migrate_reserve.
In fact most of the time is spent there.  Since that is going to require
more reading and time I will start by whittling out some easy pieces.

cc: Andrew Morton <akpm@linux-foundation.org>
cc: Tang Chen <tangchen@cn.fujitsu.com>
cc: Wen Congyang <wency@cn.fujitsu.com>
cc: Toshi Kani <toshi.kani@hp.com>
cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
cc: Xishi Qiu <qiuxishi@huawei.com>
cc: Cody P Schafer <cody@linux.vnet.ibm.com>
cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
cc: David Rientjes <rientjes@google.com>
cc: Jiang Liu <liuj97@gmail.com>
Cc: Hedi Berriche <hedi@sgi.com>
Cc: Mike Travis <travis@sgi.com>
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)

---
 mm/memory_hotplug.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 62a0cd1..a3cbd14 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -985,12 +985,12 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		if (need_zonelists_rebuild)
 			zone_pcp_reset(zone);
 		mutex_unlock(&zonelists_mutex);
+		unlock_memory_hotplug();
 		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
 		       (unsigned long long) pfn << PAGE_SHIFT,
 		       (((unsigned long long) pfn + nr_pages)
 			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
 		return ret;
 	}
 
@@ -1016,9 +1016,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	writeback_set_ratelimit();
 
+	unlock_memory_hotplug();
+
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
-	unlock_memory_hotplug();
 
 	return 0;
 }
@@ -1601,8 +1602,8 @@ repeat:
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
 
-	memory_notify(MEM_OFFLINE, &arg);
 	unlock_memory_hotplug();
+	memory_notify(MEM_OFFLINE, &arg);
 	return 0;
 
 failed_removal:
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
