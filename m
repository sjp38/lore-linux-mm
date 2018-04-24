Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D83796B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:12:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c4so7402611pfg.22
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:12:31 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0122.outbound.protection.outlook.com. [104.47.2.122])
        by mx.google.com with ESMTPS id g12-v6si14328285pll.184.2018.04.24.05.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:12:29 -0700 (PDT)
Subject: [PATCH v3 03/14] memcg: Refactoring in
 alloc_mem_cgroup_per_node_info()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:12:20 +0300
Message-ID: <152457194082.22533.13153436126073546795.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Organize the function in "if () goto err" style,
since next patch will add more "if" branches.

Also assign and clear memcg->nodeinfo[node]
earlier for the same reason.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/memcontrol.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acabea274cc3..38523c8ea7c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4326,20 +4326,22 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
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
