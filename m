Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B190A6B0032
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 11:15:43 -0400 (EDT)
From: atomlin@redhat.com
Subject: [PATCH v3] mm: slab: Verify the nodeid passed to ____cache_alloc_node
Date: Fri, 26 Apr 2013 16:15:34 +0100
Message-Id: <1366989334-13293-1-git-send-email-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, riel@redhat.com, aquini@redhat.com, rientjes@google.com, Aaron Tomlin <atomlin@redhat.com>

From: Aaron Tomlin <atomlin@redhat.com>

Hi,

This patch is in response to BZ#42967 [1].
Using VM_BUG_ON so it's used only when CONFIG_DEBUG_VM is set,
given that ____cache_alloc_node() is a hot code path.

Cheers,
Aaron

[1]: https://bugzilla.kernel.org/show_bug.cgi?id=42967

---8<---
mm: slab: Verify the nodeid passed to ____cache_alloc_node

If the nodeid is > num_online_nodes() this can cause an
Oops and a panic(). The purpose of this patch is to assert
if this condition is true to aid debugging efforts rather
than some random NULL pointer dereference or page fault.

Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slab.c b/mm/slab.c
index 856e4a1..09b4e20 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3412,6 +3412,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	void *obj;
 	int x;
 
+	VM_BUG_ON(nodeid > num_online_nodes());
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
