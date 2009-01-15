Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 281F06B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:08:34 -0500 (EST)
Message-ID: <496ED2B7.5050902@cn.fujitsu.com>
Date: Thu, 15 Jan 2009 14:07:51 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] [PATCH] memcg: fix infinite loop
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

1. task p1 is in /memcg/0
2. p1 does mmap(4096*2, MAP_LOCKED)
3. echo 4096 > /memcg/0/memory.limit_in_bytes

The above 'echo' will never return, unless p1 exited or freed the memory.
The cause is we can't reclaim memory from p1, so the while loop in
mem_cgroup_resize_limit() won't break.

This patch fixes it by decrementing retry_count regardless the return value
of mem_cgroup_hierarchical_reclaim().

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 mm/memcontrol.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb62b43..1995098 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1524,11 +1524,10 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 {
 
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
-	int progress;
 	u64 memswlimit;
 	int ret = 0;
 
-	while (retry_count) {
+	while (retry_count--) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
@@ -1551,9 +1550,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-							   false);
-  		if (!progress)			retry_count--;
+		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, false);
 	}
 
 	return ret;
@@ -1563,13 +1560,13 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
 {
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
-	u64 memlimit, oldusage, curusage;
+	u64 memlimit;
 	int ret;
 
 	if (!do_swap_account)
 		return -EINVAL;
 
-	while (retry_count) {
+	while (retry_count--) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
@@ -1592,11 +1589,7 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true);
-		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-		if (curusage >= oldusage)
-			retry_count--;
 	}
 	return ret;
 }
-- 
1.5.4.rc3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
