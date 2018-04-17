Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 569626B0062
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:53:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t2so3907156pgb.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:53:40 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0115.outbound.protection.outlook.com. [104.47.2.115])
        by mx.google.com with ESMTPS id b5si12556258pfi.324.2018.04.17.08.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:53:39 -0700 (PDT)
Subject: [PATCH v2 03/12] memcg: Refactoring in
 alloc_mem_cgroup_per_node_info()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:53:21 +0300
Message-ID: <152399120185.3456.1990374174129524641.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Organize the function in "if () goto err" style,
since next patch will add more "if" branches.

Also assign and clear memcg->nodeinfo[node]
earlier for the same reason.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/memcontrol.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d99ea5680ffe..2959a454a072 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4327,20 +4327,22 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
 	if (!pn)
 		return 1;
+	memcg->nodeinfo[node] = pn;
 
 	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
-	if (!pn->lruvec_stat_cpu) {
-		kfree(pn);
-		return 1;
-	}
+	if (!pn->lruvec_stat_cpu)
+		goto err_pcpu;
 
 	lruvec_init(&pn->lruvec);
 	pn->usage_in_excess = 0;
 	pn->on_tree = false;
 	pn->memcg = memcg;
-
-	memcg->nodeinfo[node] = pn;
 	return 0;
+
+err_pcpu:
+	memcg->nodeinfo[node] = NULL;
+	kfree(pn);
+	return 1;
 }
 
 static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
