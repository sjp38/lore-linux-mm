Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B977D6B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:52:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m5so17796005pfc.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:52:01 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id r11si17257279pfk.91.2017.05.31.08.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:52:00 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id u26so2974664pfd.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:52:00 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] lib/rhashtable.c: use kvzalloc in bucket_table_alloc when possible
Date: Wed, 31 May 2017 17:51:44 +0200
Message-Id: <20170531155145.17111-3-mhocko@kernel.org>
In-Reply-To: <20170531155145.17111-1-mhocko@kernel.org>
References: <20170531155145.17111-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Herbert Xu <herbert@gondor.apana.org.au>, Thomas Graf <tgraf@suug.ch>

From: Michal Hocko <mhocko@suse.com>

bucket_table_alloc can be currently called with GFP_KERNEL or
GFP_ATOMIC. For the former we basically have an open coded kvzalloc
while the later only uses kzalloc. Let's simplify the code a bit by
the dropping the open coded path and replace it with kvzalloc

Cc: Thomas Graf <tgraf@suug.ch>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 lib/rhashtable.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d9e7274a04cd..42466c167257 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -211,11 +211,10 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 	int i;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
-	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
-	    gfp != GFP_KERNEL)
+	if (gfp != GFP_KERNEL)
 		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
-	if (tbl == NULL && gfp == GFP_KERNEL)
-		tbl = vzalloc(size);
+	else
+		tbl = kvzalloc(size, gfp);
 
 	size = nbuckets;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
