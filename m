Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4206B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:05:52 -0400 (EDT)
Received: by padev16 with SMTP id ev16so12684442pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:52 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id s2si8653904pds.203.2015.06.09.05.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:05:51 -0700 (PDT)
Received: by payr10 with SMTP id r10so12663843pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:51 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 2/5] mm/mempool: allow NULL `pool' pointer in mempool_destroy()
Date: Tue,  9 Jun 2015 21:04:50 +0900
Message-Id: <1433851493-23685-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

mempool_destroy() does not tolerate a NULL mempool_t pointer
argument and performs a NULL-pointer dereference. This requires
additional attention and effort from developers/reviewers and
forces all mempool_destroy() callers to do a NULL check

	if (pool)
		mempool_destroy(pool);

Or, otherwise, be invalid mempool_destroy() users.

Tweak mempool_destroy() and NULL-check the pointer there.

Proposed by Andrew Morton.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
LKML-reference: https://lkml.org/lkml/2015/6/8/583
---
 mm/mempool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mempool.c b/mm/mempool.c
index 2cc08de..4c533bc 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -150,6 +150,9 @@ static void *remove_element(mempool_t *pool)
  */
 void mempool_destroy(mempool_t *pool)
 {
+	if (unlikely(!pool))
+		return;
+
 	while (pool->curr_nr) {
 		void *element = remove_element(pool);
 		pool->free(element, pool->pool_data);
-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
