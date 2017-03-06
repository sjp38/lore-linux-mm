Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 098766B038B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:30:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u48so63948609wrc.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:44 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v186si14014906wma.161.2017.03.06.02.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:30:43 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id n11so12944920wma.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:43 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/9] rhashtable: simplify a strange allocation pattern
Date: Mon,  6 Mar 2017 11:30:26 +0100
Message-Id: <20170306103032.2540-4-mhocko@kernel.org>
In-Reply-To: <20170306103032.2540-1-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 lib/rhashtable.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f8635fd57442..2c2c8afcde15 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -86,16 +86,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 		size = min(size, 1U << tbl->nest);
 
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
