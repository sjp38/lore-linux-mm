Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5D16B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 00:22:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p128so579502pga.19
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 21:22:13 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u145si225046pgb.180.2018.03.08.21.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 21:22:12 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/mempolicy: Avoid use uninitialized preferred_node
References: <CAG_fn=VW5tfzT6cHJd+jF=t3WO6XS3HqSF_TYnKdycX_M_48vw@mail.gmail.com>
Message-ID: <4ebee1c2-57f6-bcb8-0e2d-1833d1ee0bb7@huawei.com>
Date: Fri, 9 Mar 2018 13:21:08 +0800
MIME-Version: 1.0
In-Reply-To: <CAG_fn=VW5tfzT6cHJd+jF=t3WO6XS3HqSF_TYnKdycX_M_48vw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dmitriy Vyukov <dvyukov@google.com>, vbabka@suse.cz, "mhocko@suse.com" <mhocko@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Alexander reported an use of uninitialized memory in __mpol_equal(),
which is caused by incorrect use of preferred_node.

When mempolicy in mode MPOL_PREFERRED with flags MPOL_F_LOCAL, it use
numa_node_id() instead of preferred_node, however, __mpol_equeue() use
preferred_node without check whether it is MPOL_F_LOCAL or not.

Reported-by: Alexander Potapenko <glider@google.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d879f1d..641545e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2124,6 +2124,9 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 	case MPOL_INTERLEAVE:
 		return !!nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
+		/* a's flags is the same as b's */
+		if (a->flags & MPOL_F_LOCAL)
+			return true;
 		return a->v.preferred_node == b->v.preferred_node;
 	default:
 		BUG();
-- 
1.8.3.1
