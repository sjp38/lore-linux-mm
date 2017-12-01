Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1AF6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 05:04:27 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 97so4252636ple.5
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 02:04:27 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l3si4574575pgs.302.2017.12.01.02.04.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 02:04:25 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v4 3/3] mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
Date: Fri, 1 Dec 2017 17:55:28 +0800
Message-ID: <1512122128-6220-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Yisheng Xie <xieyisheng1@huawei.com>, Andi Kleen <ak@linux.intel.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tan Xiaojun <tanxiaojun@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

As in manpage of migrate_pages, the errno should be set to EINVAL when
none of the node IDs specified by new_nodes are on-line and allowed by the
process's current cpuset context, or none of the specified nodes contain
memory.  However, when test by following case:

	new_nodes = 0;
	old_nodes = 0xf;
	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);

The ret will be 0 and no errno is set.  As the new_nodes is empty, we
should expect EINVAL as documented.

To fix the case like above, this patch check whether target nodes AND
current task_nodes is empty, and then check whether AND
node_states[N_MEMORY] is empty.

Meanwhile,this patch also remove the check of EPERM on CAP_SYS_NICE. 
The caller of migrate_pages should be able to migrate the target process
pages anywhere the caller can allocate memory, if the caller can access
the mm_struct.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Chris Salls <salls@cs.ucsb.edu>
Cc: Christopher Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tan Xiaojun <tanxiaojun@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
v3:
 * check whether node is empty after AND current task node, and then nodes
   which have memory
v4:
 * remove the check of EPERM on CAP_SYS_NICE.

Hi Vlastimil and Christopher,

Could you please help to review this version?

Thanks
Yisheng Xie

 mm/mempolicy.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 65df28d..4da74b6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1426,17 +1426,14 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 	}
 	rcu_read_unlock();
 
-	task_nodes = cpuset_mems_allowed(task);
-	/* Is the user allowed to access the target nodes? */
-	if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
-		err = -EPERM;
+	task_nodes = cpuset_mems_allowed(current);
+	nodes_and(*new, *new, task_nodes);
+	if (nodes_empty(*new))
 		goto out_put;
-	}
 
-	if (!nodes_subset(*new, node_states[N_MEMORY])) {
-		err = -EINVAL;
+	nodes_and(*new, *new, node_states[N_MEMORY]);
+	if (nodes_empty(*new))
 		goto out_put;
-	}
 
 	err = security_task_movememory(task);
 	if (err)
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
