Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E09346B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 15:18:16 -0400 (EDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] slab: prevent warnings when allocating with __GFP_NOWARN
Date: Mon, 10 Jun 2013 15:18:00 -0400
Message-Id: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, cl@linux.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

slab would still spew a warning when a big allocation happens with the
__GFP_NOWARN fleg is set. Prevent that to conform to __GFP_NOWARN.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/slab_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index ff3218a..2d41450 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -373,8 +373,10 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
 	int index;
 
-	if (WARN_ON_ONCE(size > KMALLOC_MAX_SIZE))
+	if (size > KMALLOC_MAX_SIZE) {
+		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
 		return NULL;
+	}
 
 	if (size <= 192) {
 		if (!size)
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
