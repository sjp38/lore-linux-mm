Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B23A06B0261
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:23:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u27so4600677pfg.12
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:23:20 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v30si4767776pgn.569.2017.10.27.03.23.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 03:23:19 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH RFC v2 1/4] mm/mempolicy: Fix get_nodes() mask miscalculation
Date: Fri, 27 Oct 2017 18:14:22 +0800
Message-ID: <1509099265-30868-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

It appears there is a nodemask miscalculation in the get_nodes()
function in mm/mempolicy.c.  This bug has two effects:

1. It is impossible to specify a length 1 nodemask.
2. It is impossible to specify a nodemask containing the last node.

Brent have submmit a patch before v2.6.12, however, Andi revert his
changed for ABI problem. I just resent this patch as RFC, for do not
clear about what's the problem Andi have met.

As manpage of set_mempolicy, If the value of maxnode is zero, the
nodemask argument is ignored. but we should not ignore the nodemask
when maxnode is 1.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a2af6d5..613e9d0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1265,7 +1265,6 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 	unsigned long nlongs;
 	unsigned long endmask;
 
-	--maxnode;
 	nodes_clear(*nodes);
 	if (maxnode == 0 || !nmask)
 		return 0;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
