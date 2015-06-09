Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9B16B0071
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:06:04 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so13801887pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:06:04 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id k9si8671818pbq.62.2015.06.09.05.06.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:06:03 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so12561708pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:06:03 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in zpool_destroy_pool()
Date: Tue,  9 Jun 2015 21:04:52 +0900
Message-Id: <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zpool_destroy_pool() does not tolerate a NULL zpool pointer
argument and performs a NULL-pointer dereference. Although
there is only one zpool_destroy_pool() user (as of 4.1),
still update it to be coherent with the corresponding
destroy() functions of the remainig pool-allocators (slab,
mempool, etc.), which now allow NULL pool-pointers.

For consistency, tweak zpool_destroy_pool() and NULL-check the
pointer there.

Proposed by Andrew Morton.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
LKML-reference: https://lkml.org/lkml/2015/6/8/583
---
 mm/zpool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/zpool.c b/mm/zpool.c
index bacdab6..2f59b90 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -202,6 +202,9 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
  */
 void zpool_destroy_pool(struct zpool *zpool)
 {
+	if (unlikely(!zpool))
+		return;
+
 	pr_info("destroying pool type %s\n", zpool->type);
 
 	spin_lock(&pools_lock);
-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
