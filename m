Message-Id: <20080321061727.491610308@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:17 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [14/14] vcompound: Avoid vmalloc for ehash_locks
Content-Disposition: inline; filename=tcpinit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Avoid the use of vmalloc for the ehash locks.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/net/inet_hashtables.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.25-rc5-mm1/include/net/inet_hashtables.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/net/inet_hashtables.h	2008-03-20 22:21:02.680501729 -0700
+++ linux-2.6.25-rc5-mm1/include/net/inet_hashtables.h	2008-03-20 22:22:15.416565317 -0700
@@ -164,7 +164,8 @@ static inline int inet_ehash_locks_alloc
 	if (sizeof(rwlock_t) != 0) {
 #ifdef CONFIG_NUMA
 		if (size * sizeof(rwlock_t) > PAGE_SIZE)
-			hashinfo->ehash_locks = vmalloc(size * sizeof(rwlock_t));
+			hashinfo->ehash_locks = __alloc_vcompound(GFP_KERNEL,
+				get_order(size * sizeof(rwlock_t)));
 		else
 #endif
 		hashinfo->ehash_locks =	kmalloc(size * sizeof(rwlock_t),
@@ -185,7 +186,7 @@ static inline void inet_ehash_locks_free
 		unsigned int size = (hashinfo->ehash_locks_mask + 1) *
 							sizeof(rwlock_t);
 		if (size > PAGE_SIZE)
-			vfree(hashinfo->ehash_locks);
+			__free_vcompound(hashinfo->ehash_locks);
 		else
 #endif
 		kfree(hashinfo->ehash_locks);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
