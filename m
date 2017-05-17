Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7CB6B02FA
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:11:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q91so634060wrb.8
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:11:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k48si1398099wrk.201.2017.05.17.01.11.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 01:11:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 5/6] mm, cpuset: always use seqlock when changing task's nodemask
Date: Wed, 17 May 2017 10:11:39 +0200
Message-Id: <20170517081140.30654-6-vbabka@suse.cz>
In-Reply-To: <20170517081140.30654-1-vbabka@suse.cz>
References: <20170517081140.30654-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

When updating task's mems_allowed and rebinding its mempolicy due to cpuset's
mems being changed, we currently only take the seqlock for writing when either
the task has a mempolicy, or the new mems has no intersection with the old
mems. This should be enough to prevent a parallel allocation seeing no
available nodes, but the optimization is IMHO unnecessary (cpuset updates
should not be frequent), and we still potentially risk issues if the
intersection of new and old nodes has limited amount of free/reclaimable
memory. Let's just use the seqlock for all tasks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 kernel/cgroup/cpuset.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index dfd5b420452d..26a1c360a481 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -1038,38 +1038,25 @@ static void cpuset_post_attach(void)
  * @tsk: the task to change
  * @newmems: new nodes that the task will be set
  *
- * In order to avoid seeing no nodes if the old and new nodes are disjoint,
- * we structure updates as setting all new allowed nodes, then clearing newly
- * disallowed ones.
+ * We use the mems_allowed_seq seqlock to safely update both tsk->mems_allowed
+ * and rebind an eventual tasks' mempolicy. If the task is allocating in
+ * parallel, it might temporarily see an empty intersection, which results in
+ * a seqlock check and retry before OOM or allocation failure.
  */
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
-	bool need_loop;
-
 	task_lock(tsk);
-	/*
-	 * Determine if a loop is necessary if another thread is doing
-	 * read_mems_allowed_begin().  If at least one node remains unchanged and
-	 * tsk does not have a mempolicy, then an empty nodemask will not be
-	 * possible when mems_allowed is larger than a word.
-	 */
-	need_loop = task_has_mempolicy(tsk) ||
-			!nodes_intersects(*newmems, tsk->mems_allowed);
 
-	if (need_loop) {
-		local_irq_disable();
-		write_seqcount_begin(&tsk->mems_allowed_seq);
-	}
+	local_irq_disable();
+	write_seqcount_begin(&tsk->mems_allowed_seq);
 
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems);
 	tsk->mems_allowed = *newmems;
 
-	if (need_loop) {
-		write_seqcount_end(&tsk->mems_allowed_seq);
-		local_irq_enable();
-	}
+	write_seqcount_end(&tsk->mems_allowed_seq);
+	local_irq_enable();
 
 	task_unlock(tsk);
 }
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
