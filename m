Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB686B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:05:58 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so13775999pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:58 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id nt2si8683216pbc.28.2015.06.09.05.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:05:57 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so13799930pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:57 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 3/5] mm/dmapool: allow NULL `pool' pointer in dma_pool_destroy()
Date: Tue,  9 Jun 2015 21:04:51 +0900
Message-Id: <1433851493-23685-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

dma_pool_destroy() does not tolerate a NULL dma_pool pointer
argument and performs a NULL-pointer dereference. This requires
additional attention and effort from developers/reviewers and
forces all dma_pool_destroy() callers to do a NULL check

	if (pool)
		dma_pool_destroy(pool);

Or, otherwise, be invalid dma_pool_destroy() users.

Tweak dma_pool_destroy() and NULL-check the pointer there.

Proposed by Andrew Morton.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
LKML-reference: https://lkml.org/lkml/2015/6/8/583
---
 mm/dmapool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index fd5fe43..5f2cffc 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -271,6 +271,9 @@ void dma_pool_destroy(struct dma_pool *pool)
 {
 	bool empty = false;
 
+	if (unlikely(!pool))
+		return;
+
 	mutex_lock(&pools_reg_lock);
 	mutex_lock(&pools_lock);
 	list_del(&pool->pools);
-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
