Received: by rv-out-0708.google.com with SMTP id f25so1690642rvb.26
        for <linux-mm@kvack.org>; Mon, 19 May 2008 06:12:14 -0700 (PDT)
Message-ID: <48317CA8.1080700@gmail.com>
Date: Mon, 19 May 2008 22:12:08 +0900
From: MinChan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] Fix to return wrong pointer in slob
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Although slob_alloc return NULL, __kmalloc_node returns NULL + align.
Because align always can be changed, it is very hard for debugging
problem of no page if it don't return NULL.

We have to return NULL in case of no page.

Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
---
 mm/slob.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 6038cba..258d76d 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -469,9 +469,12 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 			return ZERO_SIZE_PTR;
 
 		m = slob_alloc(size + align, gfp, align, node);
-		if (m)
-			*m = size;
-		return (void *)m + align;
+		if (!m)
+			return NULL;
+		else {
+			*m = size; 
+			return (void *)m + align;
+		}
 	} else {
 		void *ret;
 
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
