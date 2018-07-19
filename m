Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 534956B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:07:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u16-v6so3835313pfm.15
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:07:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19-v6sor1531390pgl.427.2018.07.19.03.07.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 03:07:07 -0700 (PDT)
From: Jing Xia <jing.xia.mail@gmail.com>
Subject: [PATCH] mm: memcg: fix use after free in mem_cgroup_iter()
Date: Thu, 19 Jul 2018 18:06:47 +0800
Message-Id: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: chunyan.zhang@unisoc.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It was reported that a kernel crash happened in mem_cgroup_iter(),
which can be triggered if the legacy cgroup-v1 non-hierarchical
mode is used.

Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b8f
......
Call trace:
  mem_cgroup_iter+0x2e0/0x6d4
  shrink_zone+0x8c/0x324
  balance_pgdat+0x450/0x640
  kswapd+0x130/0x4b8
  kthread+0xe8/0xfc
  ret_from_fork+0x10/0x20

  mem_cgroup_iter():
      ......
      if (css_tryget(css))    <-- crash here
	    break;
      ......

The crashing reason is that mem_cgroup_iter() uses the memcg object
whose pointer is stored in iter->position, which has been freed before
and filled with POISON_FREE(0x6b).

And the root cause of the use-after-free issue is that
invalidate_reclaim_iterators() fails to reset the value of
iter->position to NULL when the css of the memcg is released in non-
hierarchical mode.

Signed-off-by: Jing Xia <jing.xia.mail@gmail.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5e..8c0280b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -850,7 +850,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	int nid;
 	int i;
 
-	while ((memcg = parent_mem_cgroup(memcg))) {
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
 		for_each_node(nid) {
 			mz = mem_cgroup_nodeinfo(memcg, nid);
 			for (i = 0; i <= DEF_PRIORITY; i++) {
-- 
1.9.1
