Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: slablru for 2.5.32-mm1
Date: Mon, 2 Sep 2002 11:00:47 -0400
References: <200208261809.45568.tomlins@cam.org> <200208281306.58776.tomlins@cam.org> <3D72F675.920DC976@zip.com.au>
In-Reply-To: <3D72F675.920DC976@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209021100.47508.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 2, 2002 01:26 am, Andrew Morton wrote:
> Ed, this code can be sped up a bit, I think.  We can make
> kmem_count_page() return a boolean back to shrink_cache(), telling it
> whether it needs to call kmem_do_prunes() at all.  Often, there won't
> be any work to do in there, and taking that semaphore can be quite
> costly.
>
> The code as-is will even run kmem_do_prunes() when we're examining
> ZONE_HIGHMEM, which certainly won't have any slab pages.  This boolean
> will fix that too.

How about this?  I have modified things so we only try for the sem if there
is work to do.  It also always uses a down_trylock - if we cannot do the prune
now later is ok too...

Lightly tested.

Comments
Ed

-----------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.531   -> 1.533  
#	           mm/slab.c	1.28    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.532
# optimization.  lets only take the sem if we have work to do.
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.533
# more optimizations and a correction
# --------------------------------------------
#
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Mon Sep  2 10:54:33 2002
+++ b/mm/slab.c	Mon Sep  2 10:54:33 2002
@@ -403,6 +403,9 @@
 /* Place maintainer for reaping. */
 static kmem_cache_t *clock_searchp = &cache_cache;
 
+static int pruner_flag;
+#define	PRUNE_GATE	0
+
 #define cache_chain (cache_cache.next)
 
 #ifdef CONFIG_SMP
@@ -427,6 +430,8 @@
 	spin_lock_irq(&cachep->spinlock);
 	if (cachep->pruner != NULL) {
 		cachep->count += slabp->inuse;
+		if (cachep->count)
+			set_bit(PRUNE_GATE, &pruner_flag);
 		ret = !slabp->inuse;
 	} else 
 		ret = !ref && !slabp->inuse;
@@ -441,11 +446,13 @@
 	struct list_head *p;
 	int nr;
 
-        if (gfp_mask & __GFP_WAIT)
-                down(&cache_chain_sem);
-        else
-                if (down_trylock(&cache_chain_sem))
-                        return 0;
+	if (!test_and_clear_bit(PRUNE_GATE, &pruner_flag))
+		return 0;
+
+	if (down_trylock(&cache_chain_sem)) {
+		set_bit(PRUNE_GATE, &pruner_flag);
+		return 0;
+	}
 
         list_for_each(p,&cache_chain) {
                 kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);

-----------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
