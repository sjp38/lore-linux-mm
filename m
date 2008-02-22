Date: Fri, 22 Feb 2008 21:59:05 +0200
From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] mm/slub.c: remove unneeded NULL check
Message-ID: <20080222195905.GM1409@cs181133002.pp.htv.fi>
References: <20080219224922.GO31955@cs181133002.pp.htv.fi> <6f8gTuy3.1203515564.2078250.penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6f8gTuy3.1203515564.2078250.penberg@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: clameter@sgi.com, mpm@selenic.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 03:52:44PM +0200, Pekka Enberg wrote:
> 
> Hi Adrian,
> 
> On 2/20/2008, "Adrian Bunk" <bunk@kernel.org> wrote:
> > The Coverity checker spotted the following inconsequent NULL checking
> > introduced by commit 8ff12cfc009a2a38d87fa7058226fe197bb2696f:
> > 
> > <--  snip  -->
> > 
> > ...
> > static inline int is_end(void *addr)
> > {
> >         return (unsigned long)addr & PAGE_MAPPING_ANON;
> > }
> > ...
> > static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
> > {
> > ...
> >         if (c->freelist)    <----------------------------------------
> >                 stat(c, DEACTIVATE_REMOTE_FREES);
> 
> I spotted this too.

I missed that.

> c->freelist should never be NULL so why not send a
> patch to Christoph?

Patch below.

cu
Adrian


<--  snip  -->


There's no reason for checking c->freelist for being NULL here (and we'd 
anyway Oops below if it was).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
dae2a3c60f258f3ad2522b85d79b735a89d702f0 diff --git a/mm/slub.c b/mm/slub.c
index 74c65af..072e0a6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1404,8 +1404,7 @@ static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	struct page *page = c->page;
 	int tail = 1;
 
-	if (c->freelist)
-		stat(c, DEACTIVATE_REMOTE_FREES);
+	stat(c, DEACTIVATE_REMOTE_FREES);
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
