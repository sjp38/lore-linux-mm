Date: Wed, 7 Nov 2007 10:28:22 +0100
From: Johannes Weiner <hannes-kernel@saeurebad.de>
Subject: Re: [patch 12/23] SLUB: Trigger defragmentation from memory reclaim
Message-ID: <20071107092822.GC6243@cataract>
References: <20071107011130.382244340@sgi.com> <20071107011229.423714790@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107011229.423714790@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, Nov 06, 2007 at 05:11:42PM -0800, Christoph Lameter wrote:
> Index: linux-2.6/include/linux/slab.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab.h	2007-11-06 12:37:51.000000000 -0800
> +++ linux-2.6/include/linux/slab.h	2007-11-06 12:53:40.000000000 -0800
> @@ -63,6 +63,7 @@ void kmem_cache_free(struct kmem_cache *
>  unsigned int kmem_cache_size(struct kmem_cache *);
>  const char *kmem_cache_name(struct kmem_cache *);
>  int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
> +int kmem_cache_defrag(int node);

The definition in slab.c always returns 0.  Wouldn't a static inline
function in the header be better?


>   * Returns the number of slab objects which we shrunk.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>   */
>  unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -                       unsigned long lru_pages)
> +                       unsigned long lru_pages, struct zone *zone)
>  {
>         struct shrinker *shrinker;
>         unsigned long ret = 0;
> @@ -210,6 +218,8 @@ unsigned long shrink_slab(unsigned long
>                 shrinker->nr += total_scan;
>         }
>         up_read(&shrinker_rwsem);
> +       if (gfp_mask & __GFP_FS)
> +               kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
>         return ret;
>  }

What about the objects that kmem_cache_defrag() releases?  Shouldn't
they be counted too?

     ret += kmem_cache_defrag(...)

Or am I overseeing something here?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
