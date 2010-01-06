Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 90A966B0047
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 02:25:26 -0500 (EST)
Message-ID: <4B443AE3.2080800@linux.intel.com>
Date: Wed, 06 Jan 2010 15:25:23 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [PATCH v3] slab: initialize unused alien cache entry as NULL at alloc_alien_cache().
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Comparing with existing code, it's a simpler way to use kzalloc_node()
to ensure that each unused alien cache entry is NULL.

CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
---
  mm/slab.c |    6 ++----
  1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..5d1a782 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -971,13 +971,11 @@ static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)

  	if (limit > 1)
  		limit = 12;
-	ac_ptr = kmalloc_node(memsize, gfp, node);
+	ac_ptr = kzalloc_node(memsize, gfp, node);
  	if (ac_ptr) {
  		for_each_node(i) {
-			if (i == node || !node_online(i)) {
-				ac_ptr[i] = NULL;
+			if (i == node || !node_online(i))
  				continue;
-			}
  			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d, gfp);
  			if (!ac_ptr[i]) {
  				for (i--; i >= 0; i--)
-- 
1.5.3.8


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
