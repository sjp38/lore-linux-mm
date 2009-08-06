Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 80D6F6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 01:31:56 -0400 (EDT)
Date: Thu, 6 Aug 2009 13:31:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] slab: remove duplicate kmem_cache_init_late() declarations
Message-ID: <20090806053153.GA13960@localhost>
References: <20090806022704.GA17337@localhost> <20090805211727.cd4ccedd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805211727.cd4ccedd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 12:17:27PM +0800, Andrew Morton wrote:
> On Thu, 6 Aug 2009 10:27:04 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/slqb_def.h |    2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > --- linux-mm.orig/include/linux/slqb_def.h	2009-07-20 20:10:20.000000000 +0800
> > +++ linux-mm/include/linux/slqb_def.h	2009-08-06 10:17:05.000000000 +0800
> > @@ -298,4 +298,6 @@ static __always_inline void *kmalloc_nod
> >  }
> >  #endif
> >  
> > +void __init kmem_cache_init_late(void);
> > +
> >  #endif /* _LINUX_SLQB_DEF_H */
> 
> spose so.
> 
> As all sl[a-zA-Z_]b.c must implement this, why not put the declaration
> into slab.h?
> 
> That would require uninlining the slob one, but it's tiny and __init.

Right. It seems someone recently moved the declaration from slab_def.h
to slab.h, so the replacement patch is a bit smaller:

---
slab: remove duplicate kmem_cache_init_late() declarations

kmem_cache_init_late() has been declared in slab.h

CC: Nick Piggin <npiggin@suse.de>
CC: Matt Mackall <mpm@selenic.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/slob_def.h |    5 -----
 include/linux/slub_def.h |    2 --
 mm/slob.c                |    5 +++++
 3 files changed, 5 insertions(+), 7 deletions(-)

--- linux-mm.orig/include/linux/slub_def.h	2009-08-06 13:15:24.000000000 +0800
+++ linux-mm/include/linux/slub_def.h	2009-08-06 13:15:52.000000000 +0800
@@ -304,6 +304,4 @@ static __always_inline void *kmalloc_nod
 }
 #endif
 
-void __init kmem_cache_init_late(void);
-
 #endif /* _LINUX_SLUB_DEF_H */
--- linux-mm.orig/include/linux/slob_def.h	2009-08-06 13:15:24.000000000 +0800
+++ linux-mm/include/linux/slob_def.h	2009-08-06 13:15:52.000000000 +0800
@@ -34,9 +34,4 @@ static __always_inline void *__kmalloc(s
 	return kmalloc(size, flags);
 }
 
-static inline void kmem_cache_init_late(void)
-{
-	/* Nothing to do */
-}
-
 #endif /* __LINUX_SLOB_DEF_H */
--- linux-mm.orig/mm/slob.c	2009-08-06 13:15:24.000000000 +0800
+++ linux-mm/mm/slob.c	2009-08-06 13:23:50.000000000 +0800
@@ -692,3 +692,8 @@ void __init kmem_cache_init(void)
 {
 	slob_ready = 1;
 }
+
+void __init kmem_cache_init_late(void)
+{
+	/* Nothing to do */
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
