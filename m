Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 42D786B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:28:24 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB15SLnO016573
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 14:28:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3322545DE69
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 14:28:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18C4A45DE4E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 14:28:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 099E61DB803E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 14:28:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D681DB803B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 14:28:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] mem-hotplug: Introduce {un}lock_memory_hotplug()
In-Reply-To: <20101026163218.B7BF.A69D9226@jp.fujitsu.com>
References: <alpine.LSU.2.00.1010252248210.2939@sister.anvils> <20101026163218.B7BF.A69D9226@jp.fujitsu.com>
Message-Id: <20101201142722.ABCB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 14:28:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Now, hwpoison are using lock_system_sleep() for prevent a race
with memory hotplug. However lock_system_sleep() is no-op if
CONFIG_HIBERNATION=n. Therefore we need new lock.

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/memory_hotplug.h |    6 ++++++
 mm/memory-failure.c            |    8 ++++----
 mm/memory_hotplug.c            |   31 ++++++++++++++++++++++++-------
 3 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4307231..31c237a 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -161,6 +161,9 @@ extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
 extern void put_page_bootmem(struct page *page);
 #endif
 
+void lock_memory_hotplug(void);
+void unlock_memory_hotplug(void);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -192,6 +195,9 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 }
 
+static inline void lock_memory_hotplug(void) {}
+static inline void unlock_memory_hotplug(void) {}
+
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1243241..46ab2c0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -51,6 +51,7 @@
 #include <linux/slab.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/memory_hotplug.h>
 #include "internal.h"
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
@@ -1230,11 +1231,10 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 		return 1;
 
 	/*
-	 * The lock_system_sleep prevents a race with memory hotplug,
-	 * because the isolation assumes there's only a single user.
+	 * The lock_memory_hotplug prevents a race with memory hotplug.
 	 * This is a big hammer, a better would be nicer.
 	 */
-	lock_system_sleep();
+	lock_memory_hotplug();
 
 	/*
 	 * Isolate the page, so that it doesn't get reallocated if it
@@ -1264,7 +1264,7 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 		ret = 1;
 	}
 	unset_migratetype_isolate(p);
-	unlock_system_sleep();
+	unlock_memory_hotplug();
 	return ret;
 }
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 833e286..7549a01 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -34,6 +34,23 @@
 
 #include "internal.h"
 
+DEFINE_MUTEX(mem_hotplug_mutex);
+
+void lock_memory_hotplug(void)
+{
+	mutex_lock(&mem_hotplug_mutex);
+
+	/* for exclusive hibernation if CONFIG_HIBERNATION=y */
+	lock_system_sleep();
+}
+
+void unlock_memory_hotplug(void)
+{
+	unlock_system_sleep();
+	mutex_unlock(&mem_hotplug_mutex);
+}
+
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
@@ -491,7 +508,7 @@ int mem_online_node(int nid)
 	pg_data_t	*pgdat;
 	int	ret;
 
-	lock_system_sleep();
+	lock_memory_hotplug();
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (pgdat) {
 		ret = -ENOMEM;
@@ -502,7 +519,7 @@ int mem_online_node(int nid)
 	BUG_ON(ret);
 
 out:
-	unlock_system_sleep();
+	unlock_memory_hotplug();
 	return ret;
 }
 
@@ -514,7 +531,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	struct resource *res;
 	int ret;
 
-	lock_system_sleep();
+	lock_memory_hotplug();
 
 	res = register_memory_resource(start, size);
 	ret = -EEXIST;
@@ -561,7 +578,7 @@ error:
 		release_memory_resource(res);
 
 out:
-	unlock_system_sleep();
+	unlock_memory_hotplug();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
@@ -789,7 +806,7 @@ static int offline_pages(unsigned long start_pfn,
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
 
-	lock_system_sleep();
+	lock_memory_hotplug();
 
 	zone = page_zone(pfn_to_page(start_pfn));
 	node = zone_to_nid(zone);
@@ -877,7 +894,7 @@ repeat:
 	vm_total_pages = nr_free_pagecache_pages();
 
 	memory_notify(MEM_OFFLINE, &arg);
-	unlock_system_sleep();
+	unlock_memory_hotplug();
 	return 0;
 
 failed_removal:
@@ -888,7 +905,7 @@ failed_removal:
 	undo_isolate_page_range(start_pfn, end_pfn);
 
 out:
-	unlock_system_sleep();
+	unlock_memory_hotplug();
 	return ret;
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
