Date: Tue, 24 Jul 2007 17:35:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
In-Reply-To: <20070724165914.a5945763.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
 <20070724165914.a5945763.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007, Andrew Morton wrote:

> arch/i386/mm/pgtable.c:197: error: conflicting types for 'pmd_ctor'
> include/asm/pgtable.h:43: error: previous declaration of 'pmd_ctor' was here

Ahh. External declaration of pmd_ctor missed in .h. Patch follows. 
Checked  remainder of .h files for additional ctor/init_once declarations

> make[1]: *** [arch/i386/mm/pgtable.o] Error 1
> make: *** [arch/i386/mm/pgtable.o] Error 2
> make: *** Waiting for unfinished jobs....
> fs/locks.c: In function 'filelock_init':
> fs/locks.c:2276: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
> mm/rmap.c: In function 'anon_vma_init':
> mm/rmap.c:151: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
> fs/inode.c: In function 'inode_init':
> fs/inode.c:1391: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
> mm/shmem.c: In function 'init_inodecache':
> mm/shmem.c:2344: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
> fs/block_dev.c: In function 'bdev_cache_init':
> fs/block_dev.c:532: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
> make: *** wait: No child processes.  Stop.

slab.h changes missing. Sigh. I need a more scripted setup.... Rechecked 
if I got everything.

> I might let these patches cook a little longer.
> 
> Now is the 100% worst time to merge this sort of thing btw: I get to carry
> it for two months while the world churns.  Around the -rc7 timeframe would 
> be better.

We just got rid of the destructor parameter of kmem_cache_create. It would 
be consistent to  also get rid of the useless flag in the ctor at the 
same time.

Did a build on i386 and it worked fine.


---
 include/asm-i386/pgtable.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-i386/pgtable.h	2007-07-23 13:02:16.000000000 -0700
+++ linux-2.6/include/asm-i386/pgtable.h	2007-07-24 17:09:38.000000000 -0700
@@ -40,7 +40,7 @@ extern spinlock_t pgd_lock;
 extern struct page *pgd_list;
 void check_pgt_cache(void);
 
-void pmd_ctor(void *, struct kmem_cache *, unsigned long);
+void pmd_ctor(struct kmem_cache *, void *);
 void pgtable_cache_init(void);
 void paging_init(void);
 
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-07-24 17:10:39.000000000 -0700
+++ linux-2.6/include/linux/slab.h	2007-07-24 17:10:49.000000000 -0700
@@ -51,7 +51,7 @@ int slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
-			void (*)(void *, struct kmem_cache *, unsigned long));
+			void (*)(struct kmem_cache *, void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
