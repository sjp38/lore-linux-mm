Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id AADEE6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 02:33:40 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] slub: do not put a slab to cpu partial list when cpu_partial is 0
Date: Wed, 19 Jun 2013 15:33:55 +0900
Message-Id: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In free path, we don't check number of cpu_partial, so one slab can
be linked in cpu partial list even if cpu_partial is 0. To prevent this,
we should check number of cpu_partial in put_cpu_partial().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 57707f0..7033b4f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1955,6 +1955,9 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 	int pages;
 	int pobjects;
 
+	if (!s->cpu_partial)
+		return;
+
 	do {
 		pages = 0;
 		pobjects = 0;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
