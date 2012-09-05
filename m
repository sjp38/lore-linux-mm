Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C96456B0088
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:51:02 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so245748ghr.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:51:02 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 4/5] mm, slob: Use only 'ret' variable for both slob object and returned pointer
Date: Wed,  5 Sep 2012 19:48:42 -0300
Message-Id: <1346885323-15689-4-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

There's no need to use two variables, 'ret' and 'm'.
This is a minor cleanup patch, but it will allow next patch to clean
the way tracing is done.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 083959a..3f4dc9a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -427,7 +427,6 @@ out:
 static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 {
-	unsigned int *m;
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
 
@@ -439,12 +438,12 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-		m = slob_alloc(size + align, gfp, align, node);
+		ret = slob_alloc(size + align, gfp, align, node);
 
-		if (!m)
+		if (!ret)
 			return NULL;
-		*m = size;
-		ret = (void *)m + align;
+		*(unsigned int *)ret = size;
+		ret += align;
 
 		trace_kmalloc_node(caller, ret,
 				   size, size + align, gfp, node);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
