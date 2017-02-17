Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E99C26B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:07:20 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id z134so23821274lff.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:07:20 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 81si5456942lfq.370.2017.02.17.12.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:07:19 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id h65so4572465lfi.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:07:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <570065255.35200.1471429099337.JavaMail.weblogic@epwas3e2>
References: <CGME20160817101819epcms5p25ad7d8a53c761ffff62993ca4d4bf129@epcms5p2>
 <570065255.35200.1471429099337.JavaMail.weblogic@epwas3e2>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 17 Feb 2017 15:06:38 -0500
Message-ID: <CALZtONDGxkqRBYDaCvH9rRezxuCvwQTiPn1bRHm_X7aWdbg7Sg@mail.gmail.com>
Subject: Re: [PATCH 3/4] zswap: Zero-filled pages handling
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, =?UTF-8?B?7IOk656A?= <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, =?UTF-8?B?6rmA7KO87ZuI?= <juhunkim@samsung.com>

On Wed, Aug 17, 2016 at 6:18 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
> From: Srividya Desireddy <srividya.dr@samsung.com>
> Date: Wed, 17 Aug 2016 14:34:14 +0530
> Subject: [PATCH 3/4] zswap: Zero-filled pages handling
>
> This patch adds a check in zswap_frontswap_store() to identify zero-filled
> page before compression of the page. If the page is a zero-filled page, set
> zswap_entry.zeroflag and skip the compression of the page and alloction
> of memory in zpool. In zswap_frontswap_load(), check if the zeroflag is
> set for the page in zswap_entry. If the flag is set, memset the page with
> zero. This saves the decompression time during load.
>
> The overall overhead caused due to zero-filled page check is very minimal
> when compared to the time saved by avoiding compression and allocation in
> case of zero-filled pages. The load time of a zero-filled page is reduced
> by 80% when compared to baseline.

this is unrelated to the same-page patches.  send this patch by itself.

>
> Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
> ---
>  mm/zswap.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 50 insertions(+), 8 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index ae39c77..d0c3f96 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -58,6 +58,9 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>   */
>  static atomic_t zswap_duplicate_pages = ATOMIC_INIT(0);
>
> +/* The number of zero filled pages swapped out to zswap */
> +static atomic_t zswap_zero_pages = ATOMIC_INIT(0);
> +
>  /*
>   * The statistics below are not protected from concurrent access for
>   * performance reasons so they may not be a 100% accurate.  However,
> @@ -172,6 +175,8 @@ struct zswap_handle {
>   *            be held, there is no reason to also make refcount atomic.
>   * pool - the zswap_pool the entry's data is in
>   * zhandle - pointer to struct zswap_handle
> + * zeroflag - the flag is set if the content of the page is filled with
> + *            zeros
>   */
>  struct zswap_entry {
>         struct rb_node rbnode;
> @@ -179,6 +184,7 @@ struct zswap_entry {
>         int refcount;
>         struct zswap_pool *pool;
>         struct zswap_handle *zhandle;
> +       unsigned char zeroflag;
>  };
>
>  struct zswap_header {
> @@ -269,6 +275,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>         if (!entry)
>                 return NULL;
>         entry->refcount = 1;
> +       entry->zeroflag = 0;
>         entry->zhandle = NULL;
>         RB_CLEAR_NODE(&entry->rbnode);
>         return entry;
> @@ -477,13 +484,17 @@ static bool zswap_handle_is_unique(struct zswap_handle *zhandle)
>   */
>  static void zswap_free_entry(struct zswap_entry *entry)
>  {
> -       if (zswap_handle_is_unique(entry->zhandle)) {
> -               zpool_free(entry->pool->zpool, entry->zhandle->handle);
> -               zswap_handle_cache_free(entry->zhandle);
> -               zswap_pool_put(entry->pool);
> -       } else {
> -               entry->zhandle->ref_count--;
> -               atomic_dec(&zswap_duplicate_pages);
> +       if (entry->zeroflag)
> +               atomic_dec(&zswap_zero_pages);
> +       else {
> +               if (zswap_handle_is_unique(entry->zhandle)) {
> +                       zpool_free(entry->pool->zpool, entry->zhandle->handle);
> +                       zswap_handle_cache_free(entry->zhandle);
> +                       zswap_pool_put(entry->pool);
> +               } else {
> +                       entry->zhandle->ref_count--;
> +                       atomic_dec(&zswap_duplicate_pages);
> +               }
>         }
>         zswap_entry_cache_free(entry);
>         atomic_dec(&zswap_stored_pages);
> @@ -1140,6 +1151,21 @@ static int zswap_shrink(void)
>         return ret;
>  }
>
> +static int zswap_is_page_zero_filled(void *ptr)
> +{
> +       unsigned int pos;
> +       unsigned long *page;
> +
> +       page = (unsigned long *)ptr;
> +
> +       for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
> +               if (page[pos])
> +                       return 0;
> +       }
> +
> +       return 1;
> +}
> +
>  /*********************************
>  * frontswap hooks
>  **********************************/
> @@ -1183,6 +1209,13 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         }
>
>         src = kmap_atomic(page);
> +       if (zswap_is_page_zero_filled(src)) {
> +               kunmap_atomic(src);
> +               entry->offset = offset;
> +               entry->zeroflag = 1;
> +               atomic_inc(&zswap_zero_pages);
> +               goto insert_entry;
> +       }
>
>         if (zswap_same_page_sharing) {
>                 checksum = jhash2((const u32 *)src, PAGE_SIZE / 4, 17);
> @@ -1314,6 +1347,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>         }
>         spin_unlock(&tree->lock);
>
> +       if (entry->zeroflag) {
> +               dst = kmap_atomic(page);
> +               memset(dst, 0, PAGE_SIZE);
> +               kunmap_atomic(dst);
> +               goto freeentry;
> +       }
> +
>         /* decompress */
>         dlen = PAGE_SIZE;
>         src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->zhandle->handle,
> @@ -1327,6 +1367,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>         zpool_unmap_handle(entry->pool->zpool, entry->zhandle->handle);
>         BUG_ON(ret);
>
> +freeentry:
>         spin_lock(&tree->lock);
>         zswap_entry_put(tree, entry);
>         spin_unlock(&tree->lock);
> @@ -1446,7 +1487,8 @@ static int __init zswap_debugfs_init(void)
>                         zswap_debugfs_root, &zswap_stored_pages);
>         debugfs_create_atomic_t("duplicate_pages", S_IRUGO,
>                         zswap_debugfs_root, &zswap_duplicate_pages);
> -
> +       debugfs_create_atomic_t("zero_pages", S_IRUGO,
> +                       zswap_debugfs_root, &zswap_zero_pages);
>
>         return 0;
>  }
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
