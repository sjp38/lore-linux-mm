Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 46DAF6B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 19:23:05 -0500 (EST)
Date: Fri, 29 Jan 2010 19:22:10 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] further cleanups to change anon_vma linking to fix
 multi-process server scalability issue
Message-ID: <20100129192210.44ee10f1@annuminas.surriel.com>
In-Reply-To: <20100129151423.8b71b88e.akpm@linux-foundation.org>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
	<20100129151423.8b71b88e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Fix the locking comments, the missed free in the fork error
path and clean up the anon_vma_chain slab creation as suggested
by Andrew Morton.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_types.h |    3 ++-
 include/linux/rmap.h     |    2 +-
 kernel/fork.c            |    1 +
 mm/rmap.c                |    4 +---
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2a06fe1..db39f5a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -167,7 +167,8 @@ struct vm_area_struct {
 	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
 	 * or brk vma (with NULL file) can only be in an anon_vma list.
 	 */
-	struct list_head anon_vma_chain; /* Serialized by mmap_sem & friends */
+	struct list_head anon_vma_chain; /* Serialized by mmap_sem &
+					  * page_table_lock */
 	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
 
 	/* Function pointers to deal with this struct. */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index a0eb4e2..72be23b 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -56,7 +56,7 @@ struct anon_vma {
 struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
-	struct list_head same_vma;	/* locked by mmap_sem & friends */
+	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
 	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
index e58f905..e2bcf1d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -394,6 +394,7 @@ out:
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_anon_vma_fork:
+	mpol_put(pol);
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
diff --git a/mm/rmap.c b/mm/rmap.c
index 5f1bb6c..aa11f3c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -280,9 +280,7 @@ void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
 			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
-	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
-			sizeof(struct anon_vma_chain), 0,
-			SLAB_PANIC, NULL);
+	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain, SLAB_PANIC);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
