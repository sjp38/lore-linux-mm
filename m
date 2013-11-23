Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f49.google.com (mail-qe0-f49.google.com [209.85.128.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5359B6B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:23:25 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id w7so1604722qeb.8
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:23:25 -0800 (PST)
Received: from mail-qe0-x232.google.com (mail-qe0-x232.google.com [2607:f8b0:400d:c02::232])
        by mx.google.com with ESMTPS id l8si25155162qey.104.2013.11.22.18.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 18:23:24 -0800 (PST)
Received: by mail-qe0-f50.google.com with SMTP id 1so1620428qee.37
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:23:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1385158254-6304-1-git-send-email-ddstreet@ieee.org>
References: <1385158254-6304-1-git-send-email-ddstreet@ieee.org>
Date: Sat, 23 Nov 2013 10:23:24 +0800
Message-ID: <CAL1ERfPExH3igteHko_iVxpG59wM+Xh0F-U1LWwZo0An0eMcGw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: reverse zswap_entry tree/refcount relationship
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hello Dan,

On Sat, Nov 23, 2013 at 6:10 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> Currently, zswap_entry_put removes the entry from its tree if
> the resulting refcount is 0.  Several places in code put an
> entry's initial reference, but they also must remove the entry
> from its tree first, which makes the tree removal in zswap_entry_put
> redundant.
>
> I believe this has the refcount model backwards - the initial
> refcount reference shouldn't be managed by multiple different places
> in code, and the put function shouldn't be removing the entry
> from the tree.  I think the correct model is for the tree to be
> the owner of the initial entry reference.  This way, the only time
> any code needs to put the entry is if it's also done a get previously.
> The various places in code that remove the entry from the tree simply
> do that, and the zswap_rb_erase function does the put of the initial
> reference.
>
> This patch moves the initial referencing completely into the tree
> functions - zswap_rb_insert gets the entry, while zswap_rb_erase
> puts the entry.  The zswap_entry_get/put functions are still available
> for any code that needs to use an entry outside of the tree lock.
> Also, the zswap_entry_find_get function is renamed to zswap_rb_search_get
> since the function behavior and return value is closer to zswap_rb_search
> than zswap_entry_get.  All code that previously removed the entry from
> the tree and put it now only remove the entry from the tree.
>
> The comment headers for most of the tree insert/search/erase functions
> and the get/put functions are updated to clarify if the tree lock
> needs to be held as well as when the caller needs to get/put an
> entry (i.e. iff the caller is using the entry outside the tree lock).

I do not like this patch idea, It breaks the zswap_rb_xxx() purity.
I think zswap_rb_xxx() should only focus on rbtree operations.

The current code might be redundant, but its logic is clear.
So it is not essential need to be changed.

If I miss something, please let me know.

Regards,

> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>
> This patch requires the writethrough patch to have been applied, but
> the patch idea doesn't require the writethrough patch.
>
>  mm/zswap.c | 130 ++++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 72 insertions(+), 58 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index fc35a7a..8c27eb2 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -215,7 +215,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>         entry = kmem_cache_alloc(zswap_entry_cache, gfp);
>         if (!entry)
>                 return NULL;
> -       entry->refcount = 1;
> +       entry->refcount = 0;
>         RB_CLEAR_NODE(&entry->rbnode);
>         return entry;
>  }
> @@ -228,9 +228,51 @@ static void zswap_entry_cache_free(struct zswap_entry *entry)
>  /*********************************
>  * rbtree functions
>  **********************************/
> -static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
> +
> +/*
> + * Carries out the common pattern of freeing and entry's zsmalloc allocation,
> + * freeing the entry itself, and decrementing the number of stored pages.
> + */
> +static void zswap_free_entry(struct zswap_tree *tree,
> +                       struct zswap_entry *entry)
> +{
> +       zbud_free(tree->pool, entry->handle);
> +       zswap_entry_cache_free(entry);
> +       atomic_dec(&zswap_stored_pages);
> +       zswap_pool_pages = zbud_get_pool_size(tree->pool);
> +}
> +
> +/* caller must hold the tree lock
> + * this must be used if the entry will be used outside
> + * the tree lock
> + */
> +static void zswap_entry_get(struct zswap_entry *entry)
> +{
> +       entry->refcount++;
> +}
> +
> +/* caller must hold the tree lock
> +* remove from the tree and free it, if nobody reference the entry
> +*/
> +static void zswap_entry_put(struct zswap_tree *tree,
> +                       struct zswap_entry *entry)
> +{
> +       int refcount = --entry->refcount;
> +
> +       BUG_ON(refcount < 0);
> +       if (refcount == 0)
> +               zswap_free_entry(tree, entry);
> +}
> +
> +/* caller much hold the tree lock
> + * This will find the entry for the offset, and return it
> + * If no entry is found, NULL is returned
> + * If the entry will be used outside the tree lock,
> + * then zswap_rb_search_get should be used instead
> + */
> +static struct zswap_entry *zswap_rb_search(struct zswap_tree *tree, pgoff_t offset)
>  {
> -       struct rb_node *node = root->rb_node;
> +       struct rb_node *node = tree->rbroot.rb_node;
>         struct zswap_entry *entry;
>
>         while (node) {
> @@ -246,13 +288,14 @@ static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
>  }
>
>  /*
> + * caller must hold the tree lock
>   * In the case that a entry with the same offset is found, a pointer to
>   * the existing entry is stored in dupentry and the function returns -EEXIST
>   */
> -static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
> +static int zswap_rb_insert(struct zswap_tree *tree, struct zswap_entry *entry,
>                         struct zswap_entry **dupentry)
>  {
> -       struct rb_node **link = &root->rb_node, *parent = NULL;
> +       struct rb_node **link = &tree->rbroot.rb_node, *parent = NULL;
>         struct zswap_entry *myentry;
>
>         while (*link) {
> @@ -267,60 +310,38 @@ static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
>                         return -EEXIST;
>                 }
>         }
> +       zswap_entry_get(entry);
>         rb_link_node(&entry->rbnode, parent, link);
> -       rb_insert_color(&entry->rbnode, root);
> +       rb_insert_color(&entry->rbnode, &tree->rbroot);
>         return 0;
>  }
>
> -static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
> +
> +/* caller must hold the tree lock
> + * after calling, the entry may have been freed,
> + * and so should no longer be used
> + */
> +static void zswap_rb_erase(struct zswap_tree *tree, struct zswap_entry *entry)
>  {
>         if (!RB_EMPTY_NODE(&entry->rbnode)) {
> -               rb_erase(&entry->rbnode, root);
> +               rb_erase(&entry->rbnode, &tree->rbroot);
>                 RB_CLEAR_NODE(&entry->rbnode);
> +               zswap_entry_put(tree, entry);
>         }
>  }
>
> -/*
> - * Carries out the common pattern of freeing and entry's zsmalloc allocation,
> - * freeing the entry itself, and decrementing the number of stored pages.
> - */
> -static void zswap_free_entry(struct zswap_tree *tree,
> -                       struct zswap_entry *entry)
> -{
> -       zbud_free(tree->pool, entry->handle);
> -       zswap_entry_cache_free(entry);
> -       atomic_dec(&zswap_stored_pages);
> -       zswap_pool_pages = zbud_get_pool_size(tree->pool);
> -}
> -
> -/* caller must hold the tree lock */
> -static void zswap_entry_get(struct zswap_entry *entry)
> -{
> -       entry->refcount++;
> -}
> -
>  /* caller must hold the tree lock
> -* remove from the tree and free it, if nobody reference the entry
> -*/
> -static void zswap_entry_put(struct zswap_tree *tree,
> -                       struct zswap_entry *entry)
> -{
> -       int refcount = --entry->refcount;
> -
> -       BUG_ON(refcount < 0);
> -       if (refcount == 0) {
> -               zswap_rb_erase(&tree->rbroot, entry);
> -               zswap_free_entry(tree, entry);
> -       }
> -}
> -
> -/* caller must hold the tree lock */
> -static struct zswap_entry *zswap_entry_find_get(struct rb_root *root,
> + * this is the same as zswap_rb_search but also gets
> + * the entry before returning it (if found).  This
> + * (or zswap_entry_get) must be used if the entry will be
> + * used outside the tree lock
> + */
> +static struct zswap_entry *zswap_rb_search_get(struct zswap_tree *tree,
>                                 pgoff_t offset)
>  {
>         struct zswap_entry *entry = NULL;
>
> -       entry = zswap_rb_search(root, offset);
> +       entry = zswap_rb_search(tree, offset);
>         if (entry)
>                 zswap_entry_get(entry);
>
> @@ -435,7 +456,7 @@ static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
>
>         /* find zswap entry */
>         spin_lock(&tree->lock);
> -       entry = zswap_rb_search(&tree->rbroot, offset);
> +       entry = zswap_rb_search(tree, offset);
>         if (!entry) {
>                 /* entry was invalidated */
>                 spin_unlock(&tree->lock);
> @@ -444,10 +465,7 @@ static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
>         BUG_ON(offset != entry->offset);
>
>         /* remove from rbtree */
> -       zswap_rb_erase(&tree->rbroot, entry);
> -
> -       /* drop initial reference */
> -       zswap_entry_put(tree, entry);
> +       zswap_rb_erase(tree, entry);
>
>         zswap_evicted_pages++;
>
> @@ -532,12 +550,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         /* map */
>         spin_lock(&tree->lock);
>         do {
> -               ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
> +               ret = zswap_rb_insert(tree, entry, &dupentry);
>                 if (ret == -EEXIST) {
>                         zswap_duplicate_entry++;
>                         /* remove from rbtree */
> -                       zswap_rb_erase(&tree->rbroot, dupentry);
> -                       zswap_entry_put(tree, dupentry);
> +                       zswap_rb_erase(tree, dupentry);
>                 }
>         } while (ret == -EEXIST);
>         spin_unlock(&tree->lock);
> @@ -570,7 +587,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>
>         /* find */
>         spin_lock(&tree->lock);
> -       entry = zswap_entry_find_get(&tree->rbroot, offset);
> +       entry = zswap_rb_search_get(tree, offset);
>         if (!entry) {
>                 /* entry was evicted */
>                 spin_unlock(&tree->lock);
> @@ -604,7 +621,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>
>         /* find */
>         spin_lock(&tree->lock);
> -       entry = zswap_rb_search(&tree->rbroot, offset);
> +       entry = zswap_rb_search(tree, offset);
>         if (!entry) {
>                 /* entry was evicted */
>                 spin_unlock(&tree->lock);
> @@ -612,10 +629,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>         }
>
>         /* remove from rbtree */
> -       zswap_rb_erase(&tree->rbroot, entry);
> -
> -       /* drop the initial reference from entry creation */
> -       zswap_entry_put(tree, entry);
> +       zswap_rb_erase(tree, entry);
>
>         spin_unlock(&tree->lock);
>  }
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
