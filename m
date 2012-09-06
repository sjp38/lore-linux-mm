Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8BA936B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 13:57:40 -0400 (EDT)
Received: by obhx4 with SMTP id x4so3743710obh.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 10:57:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1346779479-1097-2-git-send-email-mgorman@suse.de>
References: <1346779479-1097-1-git-send-email-mgorman@suse.de>
	<1346779479-1097-2-git-send-email-mgorman@suse.de>
Date: Fri, 7 Sep 2012 02:57:39 +0900
Message-ID: <CAAmzW4M_3hVBfjqFLG=7iydkXeQPdCXRbRmkqUJD4vwo0eWVWQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] slab: do ClearSlabPfmemalloc() for all pages of slab
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Chuck Lever <chuck.lever@oracle.com>, Pekka@suse.de, "Enberg <penberg"@kernel.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>

Add "Cc" to "Christoph Lameter" <cl@linux.com>

2012/9/5 Mel Gorman <mgorman@suse.de>:
> Right now, we call ClearSlabPfmemalloc() for first page of slab when we
> clear SlabPfmemalloc flag. This is fine for most swap-over-network use
> cases as it is expected that order-0 pages are in use. Unfortunately it
> is possible that that __ac_put_obj() checks SlabPfmemalloc on a tail page
> and while this is harmless, it is sloppy. This patch ensures that the head
> page is always used.
>
> This problem was originally identified by Joonsoo Kim.
>
> [js1304@gmail.com: Original implementation and problem identification]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/slab.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 811af03..d34a903 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1000,7 +1000,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
>                 l3 = cachep->nodelists[numa_mem_id()];
>                 if (!list_empty(&l3->slabs_free) && force_refill) {
>                         struct slab *slabp = virt_to_slab(objp);
> -                       ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
> +                       ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
>                         clear_obj_pfmemalloc(&objp);
>                         recheck_pfmemalloc_active(cachep, ac);
>                         return objp;

We assume that slabp->s_mem's address is always in head page, so
"virt_to_head_page" is not needed.

> @@ -1032,7 +1032,7 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
>  {
>         if (unlikely(pfmemalloc_active)) {
>                 /* Some pfmemalloc slabs exist, check if this is one */
> -               struct page *page = virt_to_page(objp);
> +               struct page *page = virt_to_head_page(objp);
>                 if (PageSlabPfmemalloc(page))
>                         set_obj_pfmemalloc(&objp);
>         }
> --
> 1.7.9.2
>

If we always use head page, following suggestion is more good to me.
How about you?

diff --git a/mm/slab.c b/mm/slab.c
index f8b0d53..ce70989 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1032,7 +1032,7 @@ static void *__ac_put_obj(struct kmem_cache
*cachep, struct array_cache *ac,
 {
        if (unlikely(pfmemalloc_active)) {
                /* Some pfmemalloc slabs exist, check if this is one */
-               struct page *page = virt_to_page(objp);
+               struct page *page = virt_to_head_page(objp);
                if (PageSlabPfmemalloc(page))
                        set_obj_pfmemalloc(&objp);
        }
@@ -1921,10 +1921,9 @@ static void *kmem_getpages(struct kmem_cache
*cachep, gfp_t flags, int nodeid)
                        NR_SLAB_UNRECLAIMABLE, nr_pages);
        for (i = 0; i < nr_pages; i++) {
                __SetPageSlab(page + i);
-
-               if (page->pfmemalloc)
-                       SetPageSlabPfmemalloc(page + i);
        }
+       if (page->pfmemalloc)
+               SetPageSlabPfmemalloc(page);

        if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
                kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
@@ -1943,26 +1942,26 @@ static void *kmem_getpages(struct kmem_cache
*cachep, gfp_t flags, int nodeid)
  */
 static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 {
-       unsigned long i = (1 << cachep->gfporder);
+       int nr_pages = (1 << cachep->gfporder);
+       int i;
        struct page *page = virt_to_page(addr);
-       const unsigned long nr_freed = i;

        kmemcheck_free_shadow(page, cachep->gfporder);

        if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
                sub_zone_page_state(page_zone(page),
-                               NR_SLAB_RECLAIMABLE, nr_freed);
+                               NR_SLAB_RECLAIMABLE, nr_pages);
        else
                sub_zone_page_state(page_zone(page),
-                               NR_SLAB_UNRECLAIMABLE, nr_freed);
-       while (i--) {
-               BUG_ON(!PageSlab(page));
-               __ClearPageSlabPfmemalloc(page);
-               __ClearPageSlab(page);
-               page++;
+                               NR_SLAB_UNRECLAIMABLE, nr_pages);
+       for (i = 0; i < nr_pages; i++) {
+               BUG_ON(!PageSlab(page + i));
+               __ClearPageSlab(page + i);
        }
+       __ClearPageSlabPfmemalloc(page);
+
        if (current->reclaim_state)
-               current->reclaim_state->reclaimed_slab += nr_freed;
+               current->reclaim_state->reclaimed_slab += nr_pages;
        free_pages((unsigned long)addr, cachep->gfporder);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
