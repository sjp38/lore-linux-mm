Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 651F26B0253
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:49:40 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b5so1720768itc.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:49:40 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id w33si1878629ioe.106.2017.11.16.17.49.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 17:49:39 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v3 3/3] mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
Date: Fri, 17 Nov 2017 09:37:04 +0800
Message-ID: <1510882624-44342-4-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

As manpage of migrate_pages, the errno should be set to EINVAL when
none of the node IDs specified by new_nodes are on-line and allowed
by the process's current cpuset context, or none of the specified
nodes contain memory. However, when test by following case:

	new_nodes = 0;
	old_nodes = 0xf;
	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);

The ret will be 0 and no errno is set. As the new_nodes is empty,
we should expect EINVAL as documented.

To fix the case like above, this patch check whether target nodes
AND current task_nodes is empty, and then check whether AND
node_states[N_MEMORY] is empty.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 65df28d..f604b22 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1433,10 +1433,14 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 		goto out_put;
 	}
 
-	if (!nodes_subset(*new, node_states[N_MEMORY])) {
-		err = -EINVAL;
+	task_nodes = cpuset_mems_allowed(current);
+	nodes_and(*new, *new, task_nodes);
+	if (nodes_empty(*new))
+		goto out_put;
+
+	nodes_and(*new, *new, node_states[N_MEMORY]);
+	if (nodes_empty(*new))
 		goto out_put;
-	}
 
 	err = security_task_movememory(task);
 	if (err)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
