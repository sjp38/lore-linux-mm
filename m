From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] mm/slab_common: Use kmem_cache_free
Date: Mon, 9 Feb 2015 10:58:35 +0530
Message-ID: <20150209052835.GA3559@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Here, free memory is allocated using kmem_cache_zalloc.
So, use kmem_cache_free instead of kfree.

This is done using Coccinelle and semantic patch used
is as follows:

@@
expression x,E,c;
@@

 x = \(kmem_cache_alloc\|kmem_cache_zalloc\|kmem_cache_alloc_node\)(c,...)
 ... when != x = E
     when != &x
?-kfree(x)
+kmem_cache_free(c,x)

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index e03dd6f..67f182c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -331,7 +331,7 @@ out:
 
 out_free_cache:
 	memcg_free_cache_params(s);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 	goto out;
 }
 
-- 
1.9.1
