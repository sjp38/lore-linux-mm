Date: Tue, 10 Apr 2007 14:13:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101412390.9522@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> How come slab_lock() isn't needed if CONFIG_SMP=n, CONFIG_PREEMPT=y?  I
> think that bit_spin_lock() does the right thing, and the #ifdef CONFIG_SMP
> in there should be removed.

SLUB: We do not need #ifdef CONFIG_SMP around bit spinlocks.

Remove them.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 14:05:04.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 14:05:31.000000000 -0700
@@ -857,25 +857,19 @@ static void discard_slab(struct kmem_cac
  */
 static __always_inline void slab_lock(struct page *page)
 {
-#ifdef CONFIG_SMP
 	bit_spin_lock(PG_locked, &page->flags);
-#endif
 }
 
 static __always_inline void slab_unlock(struct page *page)
 {
-#ifdef CONFIG_SMP
 	bit_spin_unlock(PG_locked, &page->flags);
-#endif
 }
 
 static __always_inline int slab_trylock(struct page *page)
 {
 	int rc = 1;
 
-#ifdef CONFIG_SMP
 	rc = bit_spin_trylock(PG_locked, &page->flags);
-#endif
 	return rc;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
