Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB24M1MO018501
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 13:22:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 174C945DE55
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:22:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E4D3245DE53
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:22:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CDDAE1DB803A
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:22:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B53F1DB8037
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:21:57 +0900 (JST)
Date: Tue, 2 Dec 2008 13:21:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 4/4]
 replacement-for-memcg-memswap-controller-core-make-resize-limit-hold-mutex.patch
Message-Id: <20081202132108.1a4c54ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

mem_cgroup_resize_memsw_limit() try to hold memsw.lock while holding
res.lock, so below message is showed when trying to write
memory.memsw.limit_in_bytes file.

    [ INFO: possible recursive locking detected ]
    2.6.28-rc4-mm1-mmotm-2008-11-14-20-50-ef4e17ef #1

    bash/4406 is trying to acquire lock:
     (&counter->lock){....}, at: [<c0498408>] mem_cgroup_resize_memsw_limit+0x8d/0x113

    but task is already holding lock:
     (&counter->lock){....}, at: [<c04983d6>] mem_cgroup_resize_memsw_limit+0x5b/0x113

    other info that might help us debug this:
    1 lock held by bash/4406:
     #0:  (&counter->lock){....}, at: [<c04983d6>] mem_cgroup_resize_memsw_limit+0x5b/0x113

    stack backtrace:
    Pid: 4406, comm: bash Not tainted 2.6.28-rc4-mm1-mmotm-2008-11-14-20-50-ef4e17ef #1
    Call Trace:
     [<c066e60f>] ? printk+0xf/0x18
     [<c044d0c0>] __lock_acquire+0xc67/0x1353
     [<c044d793>] ? __lock_acquire+0x133a/0x1353
     [<c044d81c>] lock_acquire+0x70/0x97
     [<c0498408>] ? mem_cgroup_resize_memsw_limit+0x8d/0x113
     [<c0671519>] _spin_lock_irqsave+0x3a/0x6d
     [<c0498408>] ? mem_cgroup_resize_memsw_limit+0x8d/0x113
     [<c0498408>] mem_cgroup_resize_memsw_limit+0x8d/0x113
     [<c0518a6c>] ? memparse+0x14/0x66
     [<c0498594>] mem_cgroup_write+0x4a/0x50
     [<c045e063>] cgroup_file_write+0x181/0x1c6
     [<c0449e43>] ? lock_release_holdtime+0x1a/0x168
     [<c04ec725>] ? security_file_permission+0xf/0x11
     [<c049b5f0>] ? rw_verify_area+0x76/0x97
     [<c045dee2>] ? cgroup_file_write+0x0/0x1c6
     [<c049bce6>] vfs_write+0x8a/0x12e
     [<c049be23>] sys_write+0x3b/0x60
     [<c0403867>] sysenter_do_call+0x12/0x3f

This patch define a new mutex and make both mem_cgroup_resize_limit and
mem_cgroup_memsw_resize_limit hold it to remove spin_lock_irqsave.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Index: mmotm-2.6.28-Dec01/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec01.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec01/mm/memcontrol.c
@@ -27,6 +27,7 @@
 #include <linux/backing-dev.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rcupdate.h>
+#include <linux/mutex.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
@@ -1189,32 +1190,43 @@ int mem_cgroup_shrink_usage(struct mm_st
 	return 0;
 }
 
+static DEFINE_MUTEX(set_limit_mutex);
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
-				   unsigned long long val)
+				unsigned long long val)
 {
 
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
 	int progress;
+	u64 memswlimit;
 	int ret = 0;
 
-	if (do_swap_account) {
-		if (val > memcg->memsw.limit)
-			return -EINVAL;
-	}
-
-	while (res_counter_set_limit(&memcg->res, val)) {
+	while (retry_count) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
-		if (!retry_count) {
-			ret = -EBUSY;
+		/*
+		 * Rather than hide all in some function, I do this in
+		 * open coded manner. You see what this really does.
+		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 */
+		mutex_lock(&set_limit_mutex);
+		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+		if (memswlimit < val) {
+			ret = -EINVAL;
+			mutex_unlock(&set_limit_mutex);
 			break;
 		}
+		ret = res_counter_set_limit(&memcg->res, val);
+		mutex_unlock(&set_limit_mutex);
+
+		if (!ret)
+			break;
+
 		progress = try_to_free_mem_cgroup_pages(memcg,
 				GFP_KERNEL, false);
-		if (!progress)
-			retry_count--;
+  		if (!progress)			retry_count--;
 	}
 	return ret;
 }
@@ -1223,7 +1235,6 @@ int mem_cgroup_resize_memsw_limit(struct
 				  unsigned long long val)
 {
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
-	unsigned long flags;
 	u64 memlimit, oldusage, curusage;
 	int ret;
 
@@ -1240,19 +1251,20 @@ int mem_cgroup_resize_memsw_limit(struct
 		 * open coded manner. You see what this really does.
 		 * We have to guarantee mem->res.limit < mem->memsw.limit.
 		 */
-		spin_lock_irqsave(&memcg->res.lock, flags);
-		memlimit = memcg->res.limit;
+		mutex_lock(&set_limit_mutex);
+		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
 		if (memlimit > val) {
-			spin_unlock_irqrestore(&memcg->res.lock, flags);
 			ret = -EINVAL;
+			mutex_unlock(&set_limit_mutex);
 			break;
 		}
 		ret = res_counter_set_limit(&memcg->memsw, val);
-		oldusage = memcg->memsw.usage;
-		spin_unlock_irqrestore(&memcg->res.lock, flags);
+		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
 			break;
+
+		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL, true);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
@@ -1261,6 +1273,7 @@ int mem_cgroup_resize_memsw_limit(struct
 	return ret;
 }
 
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
