Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 803426B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:24:52 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id m12so8116218iga.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:24:52 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id ix6si2168773icb.31.2014.01.14.10.24.50
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 10:24:51 -0800 (PST)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC] hotplug, memory: move register_memory_resource out of the lock_memory_hotplug
Date: Tue, 14 Jan 2014 12:24:34 -0600
Message-Id: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Hedi <hedi@sgi.com>, Mike Travis <travis@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We don't need to do register_memory_resource() since it has its own lock and
doesn't make any callbacks.

Also register_memory_resource return NULL on failure so we don't have anything
to cleanup at this point.


The reason for this rfc is I was doing some experiments with hotplugging of
memory on some of our larger systems.  While it seems to work, it can be quite
slow.  With some preliminary digging I found that lock_memory_hotplug is
clearly ripe for breakup.

It could be broken up per nid or something but it also covers the
online_page_callback.  The online_page_callback shouldn't be very hard to break
out.

Also there is the issue of various structures(wmarks come to mind) that are
only updated under the lock_memory_hotplug that would need to be dealt with.


cc: Andrew Morton <akpm@linux-foundation.org>
cc: Tang Chen <tangchen@cn.fujitsu.com>
cc: Wen Congyang <wency@cn.fujitsu.com>
cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
cc: Hedi <hedi@sgi.com>
cc: Mike Travis <travis@sgi.com>
cc: linux-mm@kvack.org
cc: linux-kernel@vger.kernel.org


---
 mm/memory_hotplug.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1ad92b4..62a0cd1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1097,17 +1097,18 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	struct resource *res;
 	int ret;
 
-	lock_memory_hotplug();
-
 	res = register_memory_resource(start, size);
 	ret = -EEXIST;
 	if (!res)
-		goto out;
+		return ret;
 
 	{	/* Stupid hack to suppress address-never-null warning */
 		void *p = NODE_DATA(nid);
 		new_pgdat = !p;
 	}
+
+	lock_memory_hotplug();
+
 	new_node = !node_online(nid);
 	if (new_node) {
 		pgdat = hotadd_new_pgdat(nid, start);
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
