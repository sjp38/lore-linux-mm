Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 2D60A6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:07:59 -0500 (EST)
Date: Thu, 21 Feb 2013 17:07:58 -0500 (EST)
From: Aaron Tomlin <atomlin@redhat.com>
Message-ID: <943811281.6485888.1361484478519.JavaMail.root@redhat.com>
In-Reply-To: <1285971995.6305502.1361465165007.JavaMail.root@redhat.com>
Subject: [PATCH] mm: slab: Verify the nodeid passed to ____cache_alloc_node
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Rik <riel@redhat.com>

Hi,

The addition of this BUG_ON should make debugging easier.
While I understand that this code path is "hot", surely
it is better to assert the condition than to wait until
some random NULL pointer dereference or page fault. If the
caller passes an invalid nodeid, at this stage in my opinion
it's already a BUG.

Cheers,
Aaron

---8<---
mm: slab: Verify the nodeid passed to ____cache_alloc_node
    
If the nodeid is > num_online_nodes() this can cause an
Oops and a panic(). The purpose of this patch is to assert
if this condition is true to aid debugging efforts rather
than some random NULL pointer dereference or page fault.
    
Signed-off-by: Aaron Tomlin <atomlin@redhat.com>

 slab.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slab.c b/mm/slab.c
index e7667a3..735e8bd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3412,6 +3412,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	void *obj;
 	int x;
 
+	BUG_ON(nodeid > num_online_nodes());
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
