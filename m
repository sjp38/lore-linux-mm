Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 60BCB6B005D
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:53:28 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id ay8-v6so3472420plb.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:53:28 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30097.outbound.protection.outlook.com. [40.107.3.97])
        by mx.google.com with ESMTPS id x7si237738pge.559.2018.04.17.08.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:53:27 -0700 (PDT)
Subject: [PATCH v2 02/12] memcg: Refactoring in mem_cgroup_alloc()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:53:11 +0300
Message-ID: <152399119121.3456.11227643824792399905.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Call alloc_mem_cgroup_per_node_info() and IDR allocation later.
This is preparation for next patches, which will require this
two actions are made nearby (they will be done under read lock,
and here we place them together to minimize the time, it's held).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/memcontrol.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 448db08d97a0..d99ea5680ffe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4383,20 +4383,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
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
 
@@ -4415,7 +4405,16 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
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
