Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF4806B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 16:28:36 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 79so8946126ioi.10
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:28:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor2359357iof.37.2017.11.17.13.28.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 13:28:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 17 Nov 2017 16:27:54 -0500
Message-ID: <CALZtONAHyQ=pAQj23kE62dvb0DDGdEAX2sbo=0CBtxVUwtmVXw@mail.gmail.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com, Andrew Morton <akpm@linux-foundation.org>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Oct 18, 2017 at 6:48 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
>
> From: Srividya Desireddy <srividya.dr@samsung.com>
> Date: Wed, 18 Oct 2017 15:39:02 +0530
> Subject: [PATCH] zswap: Same-filled pages handling
>
> Zswap is a cache which compresses the pages that are being swapped out
> and stores them into a dynamically allocated RAM-based memory pool.
> Experiments have shown that around 10-20% of pages stored in zswap
> are same-filled pages (i.e. contents of the page are all same), but
> these pages are handled as normal pages by compressing and allocating
> memory in the pool.
>
> This patch adds a check in zswap_frontswap_store() to identify same-filled
> page before compression of the page. If the page is a same-filled page, set
> zswap_entry.length to zero, save the same-filled value and skip the
> compression of the page and alloction of memory in zpool.
> In zswap_frontswap_load(), check if value of zswap_entry.length is zero
> corresponding to the page to be loaded. If zswap_entry.length is zero,
> fill the page with same-filled value. This saves the decompression time
> during load.
>
> On a ARM Quad Core 32-bit device with 1.5GB RAM by launching and
> relaunching different applications, out of ~64000 pages stored in
> zswap, ~11000 pages were same-value filled pages (including zero-filled
> pages) and ~9000 pages were zero-filled pages.
>
> An average of 17% of pages(including zero-filled pages) in zswap are
> same-value filled pages and 14% pages are zero-filled pages.
> An average of 3% of pages are same-filled non-zero pages.
>
> The below table shows the execution time profiling with the patch.
>
>                           Baseline    With patch  % Improvement
> -----------------------------------------------------------------
> *Zswap Store Time           26.5ms       18ms          32%
>  (of same value pages)
> *Zswap Load Time
>  (of same value pages)      25.5ms       13ms          49%
> -----------------------------------------------------------------
>
> On Ubuntu PC with 2GB RAM, while executing kernel build and other test
> scripts and running multimedia applications, out of 360000 pages
> stored in zswap 78000(~22%) of pages were found to be same-value filled
> pages (including zero-filled pages) and 64000(~17%) are zero-filled
> pages. So an average of %5 of pages are same-filled non-zero pages.
>
> The below table shows the execution time profiling with the patch.
>
>                           Baseline    With patch  % Improvement
> -----------------------------------------------------------------
> *Zswap Store Time           91ms        74ms           19%
>  (of same value pages)
> *Zswap Load Time            50ms        7.5ms          85%
>  (of same value pages)
> -----------------------------------------------------------------
>
> *The execution times may vary with test device used.

First, I'm really sorry for such a long delay in looking at this.

I did test this patch out this week, and I added some instrumentation
to check the performance impact, and tested with a small program to
try to check the best and worst cases.

When doing a lot of swap where all (or almost all) pages are
same-value, I found this patch does save both time and space,
significantly.  The exact improvement in time and space depends on
which compressor is being used, but roughly agrees with the numbers
you listed.

In the worst case situation, where all (or almost all) pages have the
same-value *except* the final long (meaning, zswap will check each
long on the entire page but then still have to pass the page to the
compressor), the same-value check is around 10-15% of the total time
spent in zswap_frontswap_store().  That's a not-insignificant amount
of time, but it's not huge.  Considering that most systems will
probably be swapping pages that aren't similar to the worst case
(although I don't have any data to know that), I'd say the improvement
is worth the possible worst-case performance impact.

>
> Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 72 insertions(+), 5 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index d39581a..4dd8b89 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -49,6 +49,8 @@
>  static u64 zswap_pool_total_size;
>  /* The number of compressed pages currently stored in zswap */
>  static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> +/* The number of same-value filled pages currently stored in zswap */
> +static atomic_t zswap_same_filled_pages = ATOMIC_INIT(0);
>
>  /*
>   * The statistics below are not protected from concurrent access for
> @@ -116,6 +118,11 @@ static int zswap_compressor_param_set(const char *,
>  static unsigned int zswap_max_pool_percent = 20;
>  module_param_named(max_pool_percent, zswap_max_pool_percent, uint, 0644);
>
> +/* Enable/disable handling same-value filled pages (enabled by default) */
> +static bool zswap_same_filled_pages_enabled = true;
> +module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
> +                  bool, 0644);
> +
>  /*********************************
>  * data structures
>  **********************************/
> @@ -145,9 +152,10 @@ struct zswap_pool {
>   *            be held while changing the refcount.  Since the lock must
>   *            be held, there is no reason to also make refcount atomic.
>   * length - the length in bytes of the compressed page data.  Needed during
> - *          decompression
> + *          decompression. For a same value filled page length is 0.
>   * pool - the zswap_pool the entry's data is in
>   * handle - zpool allocation handle that stores the compressed page data
> + * value - value of the same-value filled pages which have same content
>   */
>  struct zswap_entry {
>         struct rb_node rbnode;
> @@ -155,7 +163,10 @@ struct zswap_entry {
>         int refcount;
>         unsigned int length;
>         struct zswap_pool *pool;
> -       unsigned long handle;
> +       union {
> +               unsigned long handle;
> +               unsigned long value;
> +       };
>  };
>
>  struct zswap_header {
> @@ -320,8 +331,12 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
>   */
>  static void zswap_free_entry(struct zswap_entry *entry)
>  {
> -       zpool_free(entry->pool->zpool, entry->handle);
> -       zswap_pool_put(entry->pool);
> +       if (!entry->length)
> +               atomic_dec(&zswap_same_filled_pages);
> +       else {
> +               zpool_free(entry->pool->zpool, entry->handle);
> +               zswap_pool_put(entry->pool);
> +       }
>         zswap_entry_cache_free(entry);
>         atomic_dec(&zswap_stored_pages);
>         zswap_update_total_size();
> @@ -953,6 +968,34 @@ static int zswap_shrink(void)
>         return ret;
>  }
>
> +static int zswap_is_page_same_filled(void *ptr, unsigned long *value)
> +{
> +       unsigned int pos;
> +       unsigned long *page;
> +
> +       page = (unsigned long *)ptr;
> +       for (pos = 1; pos < PAGE_SIZE / sizeof(*page); pos++) {
> +               if (page[pos] != page[0])
> +                       return 0;
> +       }
> +       *value = page[0];
> +       return 1;
> +}
> +
> +static void zswap_fill_page(void *ptr, unsigned long value)
> +{
> +       unsigned int pos;
> +       unsigned long *page;
> +
> +       page = (unsigned long *)ptr;
> +       if (value == 0)
> +               memset(page, 0, PAGE_SIZE);
> +       else {
> +               for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
> +                       page[pos] = value;
> +       }
> +}
> +
>  /*********************************
>  * frontswap hooks
>  **********************************/
> @@ -965,7 +1008,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         struct crypto_comp *tfm;
>         int ret;
>         unsigned int dlen = PAGE_SIZE, len;
> -       unsigned long handle;
> +       unsigned long handle, value;
>         char *buf;
>         u8 *src, *dst;
>         struct zswap_header *zhdr;
> @@ -993,6 +1036,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>                 goto reject;
>         }
>
> +       if (zswap_same_filled_pages_enabled) {
> +               src = kmap_atomic(page);
> +               if (zswap_is_page_same_filled(src, &value)) {
> +                       kunmap_atomic(src);
> +                       entry->offset = offset;
> +                       entry->length = 0;
> +                       entry->value = value;
> +                       atomic_inc(&zswap_same_filled_pages);
> +                       goto insert_entry;
> +               }
> +               kunmap_atomic(src);
> +       }
> +
>         /* if entry is successfully added, it keeps the reference */
>         entry->pool = zswap_pool_current_get();
>         if (!entry->pool) {
> @@ -1037,6 +1093,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         entry->handle = handle;
>         entry->length = dlen;
>
> +insert_entry:
>         /* map */
>         spin_lock(&tree->lock);
>         do {
> @@ -1089,6 +1146,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>         }
>         spin_unlock(&tree->lock);
>
> +       if (!entry->length) {
> +               dst = kmap_atomic(page);
> +               zswap_fill_page(dst, entry->value);
> +               kunmap_atomic(dst);
> +               goto freeentry;
> +       }
> +
>         /* decompress */
>         dlen = PAGE_SIZE;
>         src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> @@ -1101,6 +1165,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>         zpool_unmap_handle(entry->pool->zpool, entry->handle);
>         BUG_ON(ret);
>
> +freeentry:
>         spin_lock(&tree->lock);
>         zswap_entry_put(tree, entry);
>         spin_unlock(&tree->lock);
> @@ -1209,6 +1274,8 @@ static int __init zswap_debugfs_init(void)
>                         zswap_debugfs_root, &zswap_pool_total_size);
>         debugfs_create_atomic_t("stored_pages", S_IRUGO,
>                         zswap_debugfs_root, &zswap_stored_pages);
> +       debugfs_create_atomic_t("same_filled_pages", 0444,
> +                       zswap_debugfs_root, &zswap_same_filled_pages);
>
>         return 0;
>  }
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
