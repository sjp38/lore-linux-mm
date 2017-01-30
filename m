Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF3C6B0261
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:49:58 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so60104087wjc.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:49:58 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id e63si12717022wmi.104.2017.01.30.01.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:49:57 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id v77so15086256wmv.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:49:57 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/9] rhashtable: simplify a strange allocation pattern
Date: Mon, 30 Jan 2017 10:49:34 +0100
Message-Id: <20170130094940.13546-4-mhocko@kernel.org>
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
References: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Michal Hocko <mhocko@suse.com>

alloc_bucket_locks allocation pattern is quite unusual. We are
preferring vmalloc when CONFIG_NUMA is enabled. The rationale is that
vmalloc will respect the memory policy of the current process and so the
backing memory will get distributed over multiple nodes if the requester
is configured properly. At least that is the intention, in reality
rhastable is shrunk and expanded from a kernel worker so no mempolicy
can be assumed.

Let's just simplify the code and use kvmalloc helper, which is a
transparent way to use kmalloc with vmalloc fallback, if the caller
is allowed to block and use the flag otherwise.

Cc: Tom Herbert <tom@herbertland.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 lib/rhashtable.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 32d0ad058380..1a487ea70829 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -77,16 +77,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	size = min_t(unsigned int, size, tbl->size >> 1);
 
 	if (sizeof(spinlock_t) != 0) {
-		tbl->locks = NULL;
-#ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
-		    gfp == GFP_KERNEL)
-			tbl->locks = vmalloc(size * sizeof(spinlock_t));
-#endif
-		if (gfp != GFP_KERNEL)
-			gfp |= __GFP_NOWARN | __GFP_NORETRY;
-
-		if (!tbl->locks)
+		if (gfpflags_allow_blocking(gfp))
+			tbl->locks = kvmalloc(size * sizeof(spinlock_t), gfp);
+		else
 			tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
 						   gfp);
 		if (!tbl->locks)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
