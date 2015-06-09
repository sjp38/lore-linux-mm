Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 70CA86B0072
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:06:10 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so12563613pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:06:10 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id px2si8659178pdb.204.2015.06.09.05.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:06:09 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so13803513pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:06:09 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 5/5] mm/zsmalloc: allow NULL `pool' pointer in zs_destroy_pool()
Date: Tue,  9 Jun 2015 21:04:53 +0900
Message-Id: <1433851493-23685-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zpool_destroy_pool() does not tolerate a NULL zs_pool pointer
argument and performs a NULL-pointer dereference. Although
there are quite a few zs_destroy_pool() users, still update
it to be coherent with the corresponding destroy() functions
of the remainig pool-allocators (slab, mempool, etc.), which
now allow NULL pool-pointers.

For consistency, tweak zpool_destroy_pool() and NULL-check the
pointer there.

Proposed by Andrew Morton.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
LKML-reference: https://lkml.org/lkml/2015/6/8/583
---
 mm/zsmalloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c766240..80964d2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1868,6 +1868,9 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	if (unlikely(!pool))
+		return;
+
 	zs_pool_stat_destroy(pool);
 
 	for (i = 0; i < zs_size_classes; i++) {
-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
