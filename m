Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH] mm/memcontrol.c: speed up to force empty a memory cgroup
Date: Mon, 19 Mar 2018 16:29:30 +0800
Message-Id: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@kernel.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_force_empty() tries to free only 32 (SWAP_CLUSTER_MAX) pages
on each iteration, if a memory cgroup has lots of page cache, it will
take many iterations to empty all page cache, so increase the reclaimed
number per iteration to speed it up. same as in mem_cgroup_resize_limit()

a simple test show:

  $dd if=aaa  of=bbb  bs=1k count=3886080
  $rm -f bbb
  $time echo 100000000 >/cgroup/memory/test/memory.limit_in_bytes

Before: 0m0.252s ===> after: 0m0.178s

Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 670e99b68aa6..8910d9e8e908 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2480,7 +2480,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		if (!try_to_free_mem_cgroup_pages(memcg, 1,
+		if (!try_to_free_mem_cgroup_pages(memcg, 1024,
 					GFP_KERNEL, !memsw)) {
 			ret = -EBUSY;
 			break;
@@ -2610,7 +2610,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 		if (signal_pending(current))
 			return -EINTR;
 
-		progress = try_to_free_mem_cgroup_pages(memcg, 1,
+		progress = try_to_free_mem_cgroup_pages(memcg, 1024,
 							GFP_KERNEL, true);
 		if (!progress) {
 			nr_retries--;
-- 
2.11.0
