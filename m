Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F038E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 13:02:20 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so24305178plp.14
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 10:02:20 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t18sor21692527pfi.23.2019.01.02.10.02.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 10:02:18 -0800 (PST)
Date: Wed,  2 Jan 2019 10:01:45 -0800
Message-Id: <20190102180145.57406-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] fork, memcg: fix cached_stacks case
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, stable@vger.kernel.org

Commit 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on
memcg charge fail") fixes a crash caused due to failed memcg charge of
the kernel stack. However the fix misses the cached_stacks case which
this patch fixes. So, the same crash can happen if the memcg charge of
a cached stack is failed.

Fixes: 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on memcg charge fail")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: <stable@vger.kernel.org>
---
 kernel/fork.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index e4a51124661a..593cd1577dff 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -216,6 +216,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		memset(s->addr, 0, THREAD_SIZE);
 
 		tsk->stack_vm_area = s;
+		tsk->stack = s->addr;
 		return s->addr;
 	}
 
-- 
2.20.1.415.g653613c723-goog
