Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A4B3360021B
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 07:38:03 -0500 (EST)
Message-ID: <4B30BDA8.1070904@linux.intel.com>
Date: Tue, 22 Dec 2009 20:38:00 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [PATCH] slab: initialize unused alien cache entry as NULL at alloc_alien_cache().
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Memory hotplug would online new node in runtime, then reap timer will add this new node as 
a reap node. In such case, for each existing kmem_list, we need to ensure that the alien 
cache entry corresponding to this new added node is NULL. Otherwise, it might cause BUG 
when reap_alien() affecting the new added node.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
---
  mm/slab.c |    7 +++----
  1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..a9486a0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -966,18 +966,17 @@ static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
  static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
  {
  	struct array_cache **ac_ptr;
-	int memsize = sizeof(void *) * nr_node_ids;
+	int memsize = sizeof(void *) * MAX_NUMNODES;
  	int i;

  	if (limit > 1)
  		limit = 12;
  	ac_ptr = kmalloc_node(memsize, gfp, node);
  	if (ac_ptr) {
+		memset(ac_ptr, 0, memsize);
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
1.6.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
