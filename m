Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 186EC6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:23:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l23so5401984pgc.10
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:23:19 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j75si5191937pfj.26.2017.10.27.03.23.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 03:23:18 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
Date: Fri, 27 Oct 2017 18:14:25 +0800
Message-ID: <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

As manpage of migrate_pages, the errno should be set to EINVAL when none
of the specified nodes contain memory. However, when new_nodes is null,
i.e. the specified nodes also do not have memory, as the following case:

	new_nodes = 0;
	old_nodes = 0xf;
	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);

The ret will be 0 and no errno is set.

This patch is to add nodes_empty check to fix above case.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8798ecb..58352cc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1402,6 +1402,11 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 	if (err)
 		goto out;
 
+	if (nodes_empty(*new)) {
+		err = -EINVAL;
+		goto out;
+	}
+
 	/* Find the mm_struct */
 	rcu_read_lock();
 	task = pid ? find_task_by_vpid(pid) : current;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
