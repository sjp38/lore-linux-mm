Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDFB6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 14:57:30 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id o140so11675931lff.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:57:30 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 26si5455089ljh.63.2017.02.17.11.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 11:57:28 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id x1so4585215lff.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:57:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160817100736epcms5p17af57d51c47dc371acc7aacfc82eb346@epcms5p1>
References: <CGME20160817100736epcms5p17af57d51c47dc371acc7aacfc82eb346@epcms5p1>
 <20160817100736epcms5p17af57d51c47dc371acc7aacfc82eb346@epcms5p1>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 17 Feb 2017 14:56:47 -0500
Message-ID: <CALZtONAHVZKMgdkPb=XBFHh-R7=FgYNbH30TAz3c8UG4bbbMsg@mail.gmail.com>
Subject: Re: [PATCH 1/4] zswap: Share zpool memory of duplicate pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, =?UTF-8?B?6rmA7KO87ZuI?= <juhunkim@samsung.com>

On Wed, Aug 17, 2016 at 6:07 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
> From: Srividya Desireddy <srividya.dr@samsung.com>
> Date: Wed, 17 Aug 2016 14:31:01 +0530
> Subject: [PATCH 1/4] zswap: Share zpool memory of duplicate pages
>
> This patch shares the compressed pool memory of duplicate pages and reduces
> compressed pool memory utilized by zswap.
>
> For each page requested for swap-out to zswap, calculate 32-bit checksum of
> the page. Search for duplicate pages by comparing the checksum of the new
> page with existing pages. Compare the contents of the pages if checksum
> matches. If the contents also match, then share the compressed data of the
> existing page with the new page. Increment the reference count to check
> the number of pages sharing the compressed page in zpool.
>
> If a duplicate page is not found then treat the new page as a 'unique' page
> in zswap. Compress the new page and store the compressed data in the zpool.
> Insert the unique page in the Red-Black Tree which is balanced based on
> 32-bit checksum value of the page.

How many duplicate pages really are there?  This has a lot of
downside; it roughly doubles the size of each page's metadata, and
while tree lock is held, it checksums each new page contents,
decompresses the matching page (if found), and then memcmp's the new
and decompressed pages.  I'm very skeptical the benefits would
outweigh the performance (and possibly memory) disadvantages.

>
> Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
> ---
>  mm/zswap.c |  265
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 248 insertions(+), 17 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 275b22c..f7efede 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -41,6 +41,7 @@
>  #include <linux/swapops.h>
>  #include <linux/writeback.h>
>  #include <linux/pagemap.h>
> +#include <linux/jhash.h>
>
>  /*********************************
>  * statistics
> @@ -51,6 +52,13 @@ static u64 zswap_pool_total_size;
>  static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>
>  /*
> + * The number of swapped out pages which are identified as duplicate
> + * to the existing zswap pages. Compression and storing of these pages
> + * is avoided.
> + */
> +static atomic_t zswap_duplicate_pages = ATOMIC_INIT(0);
> +
> +/*
>   * The statistics below are not protected from concurrent access for
>   * performance reasons so they may not be a 100% accurate.  However,
>   * they do provide useful information on roughly how many times a
> @@ -123,6 +131,28 @@ struct zswap_pool {
>  };
>
>  /*
> + * struct zswap_handle
> + * This structure contains the metadata for tracking single zpool handle
> + * allocation.
> + *
> + * rbnode - links the zswap_handle into red-black tree
> + * checksum - 32-bit checksum value of the page swapped to zswap
> + * ref_count - number of pages sharing this handle
> + * length - the length in bytes of the compressed page data.
> + *          Needed during decompression.
> + * handle - zpool allocation handle that stores the compressed page data.
> + * pool - the zswap_pool the entry's data is in.
> + */
> +struct zswap_handle {
> + struct rb_node rbnode;
> + u32 checksum;
> + u16 ref_count;
> + unsigned int length;
> + unsigned long handle;
> + struct zswap_pool *pool;

this is adding quite a bit of overhead for each page stored, roughly
doubling the size of each (unique) entry's metadata.

> +};
> +
> +/*
>   * struct zswap_entry
>   *
>   * This structure contains the metadata for tracking a single compressed
> @@ -136,18 +166,15 @@ struct zswap_pool {
>   *            for the zswap_tree structure that contains the entry must
>   *            be held while changing the refcount.  Since the lock must
>   *            be held, there is no reason to also make refcount atomic.
> - * length - the length in bytes of the compressed page data.  Needed during
> - *          decompression
>   * pool - the zswap_pool the entry's data is in
> - * handle - zpool allocation handle that stores the compressed page data
> + * zhandle - pointer to struct zswap_handle
>   */
>  struct zswap_entry {
>   struct rb_node rbnode;
>   pgoff_t offset;
>   int refcount;
> - unsigned int length;
>   struct zswap_pool *pool;
> - unsigned long handle;
> + struct zswap_handle *zhandle;
>  };
>
>  struct zswap_header {
> @@ -161,6 +188,8 @@ struct zswap_header {
>   */
>  struct zswap_tree {
>   struct rb_root rbroot;
> + struct rb_root zhandleroot;
> + void  *buffer;
>   spinlock_t lock;
>  };
>
> @@ -236,6 +265,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t
> gfp)
>   if (!entry)
>   return NULL;
>   entry->refcount = 1;
> + entry->zhandle = NULL;
>   RB_CLEAR_NODE(&entry->rbnode);
>   return entry;
>  }
> @@ -246,6 +276,39 @@ static void zswap_entry_cache_free(struct zswap_entry
> *entry)
>  }
>
>  /*********************************
> +* zswap handle functions
> +**********************************/
> +static struct kmem_cache *zswap_handle_cache;
> +
> +static int __init zswap_handle_cache_create(void)
> +{
> + zswap_handle_cache = KMEM_CACHE(zswap_handle, 0);
> + return zswap_handle_cache == NULL;
> +}
> +
> +static void __init zswap_handle_cache_destroy(void)
> +{
> + kmem_cache_destroy(zswap_handle_cache);
> +}
> +
> +static struct zswap_handle *zswap_handle_cache_alloc(gfp_t gfp)
> +{
> + struct zswap_handle *zhandle;
> +
> + zhandle = kmem_cache_alloc(zswap_handle_cache, gfp);
> + if (!zhandle)
> + return NULL;
> + zhandle->ref_count = 1;
> + RB_CLEAR_NODE(&zhandle->rbnode);
> + return zhandle;
> +}
> +
> +static void zswap_handle_cache_free(struct zswap_handle *zhandle)
> +{
> + kmem_cache_free(zswap_handle_cache, zhandle);
> +}
> +
> +/*********************************
>  * rbtree functions
>  **********************************/
>  static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t
> offset)
> @@ -300,14 +363,124 @@ static void zswap_rb_erase(struct rb_root *root,
> struct zswap_entry *entry)
>   }
>  }
>
> +static struct zswap_handle *zswap_handle_rb_search(struct rb_root *root,
> + u32 checksum)
> +{
> + struct rb_node *node = root->rb_node;
> + struct zswap_handle *zhandle;
> +
> + while (node) {
> + zhandle = rb_entry(node, struct zswap_handle, rbnode);
> + if (zhandle->checksum > checksum)
> + node = node->rb_left;
> + else if (zhandle->checksum < checksum)
> + node = node->rb_right;
> + else
> + return zhandle;
> + }
> + return NULL;
> +}
> +
> +/*
> + * In the case that zhandle with the same checksum is found, a pointer to
> + * the existing zhandle is stored in duphandle and the function returns
> + * -EEXIST
> + */
> +static int zswap_handle_rb_insert(struct rb_root *root,
> + struct zswap_handle *zhandle,
> + struct zswap_handle **duphandle)
> +{
> + struct rb_node **link = &root->rb_node, *parent = NULL;
> + struct zswap_handle *myhandle;
> +
> + while (*link) {
> + parent = *link;
> + myhandle = rb_entry(parent, struct zswap_handle, rbnode);
> + if (myhandle->checksum > zhandle->checksum)
> + link = &parent->rb_left;
> + else if (myhandle->checksum < zhandle->checksum)
> + link = &parent->rb_right;
> + else {
> + *duphandle = myhandle;
> + return -EEXIST;
> + }
> + }
> + rb_link_node(&zhandle->rbnode, parent, link);
> + rb_insert_color(&zhandle->rbnode, root);
> + return 0;
> +}
> +
> +static void zswap_handle_erase(struct rb_root *root,
> + struct zswap_handle *zhandle)
> +{
> + if (!RB_EMPTY_NODE(&zhandle->rbnode)) {
> + rb_erase(&zhandle->rbnode, root);
> + RB_CLEAR_NODE(&zhandle->rbnode);
> + }
> +}
> +
> +/*
> + * This function searches for the same page in the zhandle RB-Tree based
> + * on the checksum value of the new page. If the same page is found the
> + * zhandle of that page is returned.
> + */
> +static struct zswap_handle *zswap_same_page_search(struct zswap_tree *tree,
> + u8 *uncmem, u32 checksum)
> +{
> + int ret = 0;
> + unsigned int dlen = PAGE_SIZE;
> + u8 *src = NULL, *dst = NULL;
> + struct zswap_handle *zhandle = NULL;
> + struct crypto_comp *tfm;
> +
> + zhandle = zswap_handle_rb_search(&tree->zhandleroot, checksum);
> + if (!zhandle)
> + return NULL;
> + if (!zhandle->pool)
> + return NULL;
> +
> + /* Compare memory contents */
> + dst = (u8 *)tree->buffer;
> + src = (u8 *)zpool_map_handle(zhandle->pool->zpool, zhandle->handle,
> + ZPOOL_MM_RO) + sizeof(struct zswap_header);
> + tfm = *get_cpu_ptr(zhandle->pool->tfm);
> + ret = crypto_comp_decompress(tfm, src, zhandle->length, dst, &dlen);
> + put_cpu_ptr(zhandle->pool->tfm);
> + zpool_unmap_handle(zhandle->pool->zpool, zhandle->handle);
> +
> + if (ret) /* Consider the page as unique if decompression failed;*/
> + return NULL;
> +
> + if (memcmp(dst, uncmem, PAGE_SIZE))
> + return NULL;
> +
> + return zhandle;
> +}
> +
> +/*
> + * This function returns true if the zswap_handle is referenced by only
> + * one page entry.
> + */
> +static bool zswap_handle_is_unique(struct zswap_handle *zhandle)
> +{
> + WARN_ON(zhandle->ref_count < 1);
> + return zhandle->ref_count == 1;
> +}
> +
>  /*
>   * Carries out the common pattern of freeing and entry's zpool allocation,
>   * freeing the entry itself, and decrementing the number of stored pages.
>   */
>  static void zswap_free_entry(struct zswap_entry *entry)
>  {
> - zpool_free(entry->pool->zpool, entry->handle);
> - zswap_pool_put(entry->pool);
> + if (zswap_handle_is_unique(entry->zhandle)) {
> + zpool_free(entry->pool->zpool, entry->zhandle->handle);
> + zswap_handle_cache_free(entry->zhandle);
> + zswap_pool_put(entry->pool);
> + } else {
> + entry->zhandle->ref_count--;
> + atomic_dec(&zswap_duplicate_pages);
> + }
>   zswap_entry_cache_free(entry);
>   atomic_dec(&zswap_stored_pages);
>   zswap_update_total_size();
> @@ -329,6 +502,9 @@ static void zswap_entry_put(struct zswap_tree *tree,
>
>   BUG_ON(refcount < 0);
>   if (refcount == 0) {
> + if (entry->zhandle && zswap_handle_is_unique(entry->zhandle))
> + zswap_handle_erase(&tree->zhandleroot,
> + entry->zhandle);
>   zswap_rb_erase(&tree->rbroot, entry);
>   zswap_free_entry(entry);
>   }
> @@ -886,15 +1062,16 @@ static int zswap_writeback_entry(struct zpool *pool,
> unsigned long handle)
>   case ZSWAP_SWAPCACHE_NEW: /* page is locked */
>   /* decompress */
>   dlen = PAGE_SIZE;
> - src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> - ZPOOL_MM_RO) + sizeof(struct zswap_header);
> + src = (u8 *)zpool_map_handle(entry->pool->zpool,
> + entry->zhandle->handle, ZPOOL_MM_RO)
> + + sizeof(struct zswap_header);
>   dst = kmap_atomic(page);
>   tfm = *get_cpu_ptr(entry->pool->tfm);
> - ret = crypto_comp_decompress(tfm, src, entry->length,
> + ret = crypto_comp_decompress(tfm, src, entry->zhandle->length,
>       dst, &dlen);
>   put_cpu_ptr(entry->pool->tfm);
>   kunmap_atomic(dst);
> - zpool_unmap_handle(entry->pool->zpool, entry->handle);
> + zpool_unmap_handle(entry->pool->zpool, entry->zhandle->handle);
>   BUG_ON(ret);
>   BUG_ON(dlen != PAGE_SIZE);
>
> @@ -975,6 +1152,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t
> offset,
>   char *buf;
>   u8 *src, *dst;
>   struct zswap_header *zhdr;
> + struct zswap_handle *zhandle = NULL, *duphandle = NULL;
> + u32 checksum = 0;
>
>   if (!zswap_enabled || !tree) {
>   ret = -ENODEV;
> @@ -999,6 +1178,23 @@ static int zswap_frontswap_store(unsigned type,
> pgoff_t offset,
>   goto reject;
>   }
>
> + src = kmap_atomic(page);
> +
> + checksum = jhash2((const u32 *)src, PAGE_SIZE / 4, 17);

what's with the magic number 17?

> + spin_lock(&tree->lock);
> + zhandle = zswap_same_page_search(tree, src, checksum);
> + if (zhandle) {
> + entry->offset = offset;
> + entry->zhandle = zhandle;
> + entry->pool = zhandle->pool;
> + entry->zhandle->ref_count++;
> + spin_unlock(&tree->lock);
> + kunmap_atomic(src);
> + atomic_inc(&zswap_duplicate_pages);
> + goto insert_entry;
> + }
> + spin_unlock(&tree->lock);
> +
>   /* if entry is successfully added, it keeps the reference */
>   entry->pool = zswap_pool_current_get();
>   if (!entry->pool) {
> @@ -1009,7 +1205,6 @@ static int zswap_frontswap_store(unsigned type,
> pgoff_t offset,
>   /* compress */
>   dst = get_cpu_var(zswap_dstmem);
>   tfm = *get_cpu_ptr(entry->pool->tfm);
> - src = kmap_atomic(page);
>   ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
>   kunmap_atomic(src);
>   put_cpu_ptr(entry->pool->tfm);
> @@ -1040,9 +1235,24 @@ static int zswap_frontswap_store(unsigned type,
> pgoff_t offset,
>
>   /* populate entry */
>   entry->offset = offset;
> - entry->handle = handle;
> - entry->length = dlen;
> + zhandle = zswap_handle_cache_alloc(GFP_KERNEL);
> + if (!zhandle) {
> + zswap_reject_kmemcache_fail++;
> + ret = -ENOMEM;
> + goto freeentry;
> + }
> +
> + entry->zhandle = zhandle;
> + entry->zhandle->handle = handle;
> + entry->zhandle->length = dlen;
> + entry->zhandle->checksum = checksum;
> + entry->zhandle->pool = entry->pool;
> + spin_lock(&tree->lock);
> + ret = zswap_handle_rb_insert(&tree->zhandleroot, entry->zhandle,
> + &duphandle);

you don't actually check if ret == -EEXIST...

> + spin_unlock(&tree->lock);

why unlock and then immediately relock the tree?

>
> +insert_entry:
>   /* map */
>   spin_lock(&tree->lock);
>   do {
> @@ -1064,6 +1274,7 @@ static int zswap_frontswap_store(unsigned type,
> pgoff_t offset,
>
>  put_dstmem:
>   put_cpu_var(zswap_dstmem);
> +freeentry:
>   zswap_pool_put(entry->pool);
>  freepage:
>   zswap_entry_cache_free(entry);
> @@ -1097,14 +1308,15 @@ static int zswap_frontswap_load(unsigned type,
> pgoff_t offset,
>
>   /* decompress */
>   dlen = PAGE_SIZE;
> - src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> + src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->zhandle->handle,
>   ZPOOL_MM_RO) + sizeof(struct zswap_header);
>   dst = kmap_atomic(page);
>   tfm = *get_cpu_ptr(entry->pool->tfm);
> - ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
> + ret = crypto_comp_decompress(tfm, src, entry->zhandle->length,
> + dst, &dlen);
>   put_cpu_ptr(entry->pool->tfm);
>   kunmap_atomic(dst);
> - zpool_unmap_handle(entry->pool->zpool, entry->handle);
> + zpool_unmap_handle(entry->pool->zpool, entry->zhandle->handle);
>   BUG_ON(ret);
>
>   spin_lock(&tree->lock);
> @@ -1152,7 +1364,9 @@ static void zswap_frontswap_invalidate_area(unsigned
> type)
>   rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode)
>   zswap_free_entry(entry);
>   tree->rbroot = RB_ROOT;
> + tree->zhandleroot = RB_ROOT;
>   spin_unlock(&tree->lock);
> + free_page((unsigned long)tree->buffer);
>   kfree(tree);
>   zswap_trees[type] = NULL;
>  }
> @@ -1167,6 +1381,13 @@ static void zswap_frontswap_init(unsigned type)
>   return;
>   }
>
> + tree->buffer = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
> + if (!tree->buffer) {
> + pr_err("zswap: Error allocating buffer for decompression\n");
> + kfree(tree);
> + return;
> + }
> + tree->zhandleroot = RB_ROOT;
>   tree->rbroot = RB_ROOT;
>   spin_lock_init(&tree->lock);
>   zswap_trees[type] = tree;
> @@ -1215,6 +1436,9 @@ static int __init zswap_debugfs_init(void)
>   zswap_debugfs_root, &zswap_pool_total_size);
>   debugfs_create_atomic_t("stored_pages", S_IRUGO,
>   zswap_debugfs_root, &zswap_stored_pages);
> + debugfs_create_atomic_t("duplicate_pages", S_IRUGO,
> + zswap_debugfs_root, &zswap_duplicate_pages);
> +
>
>   return 0;
>  }
> @@ -1246,6 +1470,11 @@ static int __init init_zswap(void)
>   goto cache_fail;
>   }
>
> + if (zswap_handle_cache_create()) {
> + pr_err("handle cache creation failed\n");
> + goto handlecachefail;
> + }
> +
>   if (zswap_cpu_dstmem_init()) {
>   pr_err("dstmem alloc failed\n");
>   goto dstmem_fail;
> @@ -1269,6 +1498,8 @@ static int __init init_zswap(void)
>  pool_fail:
>   zswap_cpu_dstmem_destroy();
>  dstmem_fail:
> + zswap_handle_cache_destroy();
> +handlecachefail:
>   zswap_entry_cache_destroy();
>  cache_fail:
>   return -ENOMEM;
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
