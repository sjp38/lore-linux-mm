Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F23266B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:12:18 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r129-v6so11228080itc.3
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:12:18 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0122.outbound.protection.outlook.com. [104.47.1.122])
        by mx.google.com with ESMTPS id k124-v6si8836919ith.131.2018.04.24.05.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:12:17 -0700 (PDT)
Subject: [PATCH v3 02/14] memcg: Refactoring in mem_cgroup_alloc()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:12:12 +0300
Message-ID: <152457193202.22533.3646608371253505321.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Call alloc_mem_cgroup_per_node_info() and IDR allocation later.
This is preparation for next patches, which will require this
two actions are made nearby (they will be done under read lock,
and here we place them together to minimize the time, it's held).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/memcontrol.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25b148c2d222..acabea274cc3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4382,20 +4382,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
-	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
-				 1, MEM_CGROUP_ID_MAX,
-				 GFP_KERNEL);
-	if (memcg->id.id < 0)
-		goto fail;
-
 	memcg->stat_cpu = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat_cpu)
 		goto fail;
 
-	for_each_node(node)
-		if (alloc_mem_cgroup_per_node_info(memcg, node))
-			goto fail;
-
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
 		goto fail;
 
@@ -4414,7 +4404,16 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
-	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
+	for_each_node(node)
+		if (alloc_mem_cgroup_per_node_info(memcg, node))
+			goto fail;
+
+	memcg->id.id = idr_alloc(&mem_cgroup_idr, memcg,
+				 1, MEM_CGROUP_ID_MAX,
+				 GFP_KERNEL);
+	if (memcg->id.id < 0)
+		goto fail;
+
 	return memcg;
 fail:
 	mem_cgroup_id_remove(memcg);
