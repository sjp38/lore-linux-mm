Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 73BC06B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:31:40 -0400 (EDT)
Date: Tue, 23 Apr 2013 10:31:36 -0400 (EDT)
From: Aaron Tomlin <atomlin@redhat.com>
Message-ID: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
In-Reply-To: <1081382531.982691.1366726661820.JavaMail.root@redhat.com>
Subject: [Patch v2] mm: slab: Verify the nodeid passed to
 ____cache_alloc_node
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, Rik <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

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


 slab.c |    1 +
 1 file changed, 1 insertion(+)
 
diff --git a/mm/slab.c b/mm/slab.c
index e7667a3..735e8bd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
 -3412,6 +3412,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	void *obj;
 	int x;
 
+	VM_BUG_ON(nodeid > num_online_nodes());
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
