Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB97D6B0069
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 21:48:36 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h200so3283915oib.18
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 18:48:36 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id c140si3028088oib.291.2017.10.17.18.48.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 18:48:36 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/mempolicy: add node_empty check in SYSC_migrate_pages
Date: Wed, 18 Oct 2017 09:37:40 +0800
Message-ID: <1508290660-60619-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, tanxiaojun@huawei.com

As Xiaojun reported the ltp of migrate_pages01 will failed on ARCH arm64
system whoes has 4 nodes[0...3], all have memory and CONFIG_NODES_SHIFT=2:

migrate_pages01    0  TINFO  :  test_invalid_nodes
migrate_pages01   14  TFAIL  :  migrate_pages_common.c:45: unexpected failure - returned value = 0, expected: -1
migrate_pages01   15  TFAIL  :  migrate_pages_common.c:55: call succeeded unexpectedly

In this case the test_invalid_nodes of migrate_pages01 will call:
SYSC_migrate_pages as:

migrate_pages(0, , {0x0000000000000001}, 64, , {0x0000000000000010}, 64) = 0

For MAX_NUMNODES is 4, so 0x10 nodemask will tread as empty set which makes
	nodes_subset(*new, node_states[N_MEMORY])

return true, as empty set is subset of any set.

So this is a common issue which also can happens in X86_64 system eg. 8 nodes[0..7],
all with memory and CONFIG_NODES_SHIFT=3. Fix it by adding node_empty check in
SYSC_migrate_pages.

Reported-by: Tan Xiaojun <tanxiaojun@huawei.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a2af6d5..1dfd3cc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1388,6 +1388,11 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
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
