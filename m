Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED29B6B0387
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 16:25:56 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id p85so61341475lfg.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 13:25:56 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g141si6579593lfg.86.2017.03.03.13.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 13:25:55 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id g70so7891416lfh.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 13:25:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAP2rAF-C1Fti4qZRFgQxnzUucpm+KvrbPY3kEPi9zgyqC_y0DQ@mail.gmail.com>
References: <CGME20170225144222epcms5p15930f37372ec628420474e4d43ccfa16@epcms5p1>
 <20170225144222epcms5p15930f37372ec628420474e4d43ccfa16@epcms5p1> <CAP2rAF-C1Fti4qZRFgQxnzUucpm+KvrbPY3kEPi9zgyqC_y0DQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 3 Mar 2017 16:25:14 -0500
Message-ID: <CALZtONCqMmOqaO-UWM5tVs4MauXx-eHH=GkYzw6CQ07mOwhcTQ@mail.gmail.com>
Subject: Re: [PATCH] zswap: Zero-filled pages handling
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarbojit Ganguly <unixman.linuxboy@gmail.com>
Cc: srividya.dr@samsung.com, "sjenning@redhat.com" <sjenning@redhat.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>, Sarbojit Ganguly <ganguly.s@samsung.com>

On Sat, Feb 25, 2017 at 12:18 PM, Sarbojit Ganguly
<unixman.linuxboy@gmail.com> wrote:
> On 25 February 2017 at 20:12, Srividya Desireddy
> <srividya.dr@samsung.com> wrote:
>> From: Srividya Desireddy <srividya.dr@samsung.com>
>> Date: Thu, 23 Feb 2017 15:04:06 +0530
>> Subject: [PATCH] zswap: Zero-filled pages handling

your email is base64-encoded; please send plain text emails.

>>
>> Zswap is a cache which compresses the pages that are being swapped out
>> and stores them into a dynamically allocated RAM-based memory pool.
>> Experiments have shown that around 10-20% of pages stored in zswap
>> are zero-filled pages (i.e. contents of the page are all zeros), but

20%?  that's a LOT of zero pages...which seems like applications are
wasting a lot of memory.  what kind of workload are you testing with?

>> these pages are handled as normal pages by compressing and allocating
>> memory in the pool.
>>
>> This patch adds a check in zswap_frontswap_store() to identify zero-filled
>> page before compression of the page. If the page is a zero-filled page, set
>> zswap_entry.zeroflag and skip the compression of the page and alloction
>> of memory in zpool. In zswap_frontswap_load(), check if the zeroflag is
>> set for the page in zswap_entry. If the flag is set, memset the page with
>> zero. This saves the decompression time during load.
>>
>> The overall overhead caused to check for a zero-filled page is very minimal
>> when compared to the time saved by avoiding compression and allocation in
>> case of zero-filled pages. Although, compressed size of a zero-filled page
>> is very less, with this patch load time of a zero-filled page is reduced by
>> 80% when compared to baseline.
>
> Is it possible to share the benchmark details?

Was there an answer to this?

>
>
>>
>> Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
>> ---
>>  mm/zswap.c |   48 +++++++++++++++++++++++++++++++++++++++++++++---
>>  1 file changed, 45 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 067a0d6..a574008 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -49,6 +49,8 @@
>>  static u64 zswap_pool_total_size;
>>  /* The number of compressed pages currently stored in zswap */
>>  static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>> +/* The number of zero filled pages swapped out to zswap */
>> +static atomic_t zswap_zero_pages = ATOMIC_INIT(0);
>>
>>  /*
>>   * The statistics below are not protected from concurrent access for
>> @@ -140,6 +142,8 @@ struct zswap_pool {
>>   *          decompression
>>   * pool - the zswap_pool the entry's data is in
>>   * handle - zpool allocation handle that stores the compressed page data
>> + * zeroflag - the flag is set if the content of the page is filled with
>> + *            zeros
>>   */
>>  struct zswap_entry {
>>         struct rb_node rbnode;
>> @@ -148,6 +152,7 @@ struct zswap_entry {
>>         unsigned int length;
>>         struct zswap_pool *pool;
>>         unsigned long handle;
>> +       unsigned char zeroflag;

instead of a flag, we can use length == 0; the length will never be 0
for any actually compressed page.

>>  };
>>
>>  struct zswap_header {
>> @@ -236,6 +241,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>>         if (!entry)
>>                 return NULL;
>>         entry->refcount = 1;
>> +       entry->zeroflag = 0;
>>         RB_CLEAR_NODE(&entry->rbnode);
>>         return entry;
>>  }
>> @@ -306,8 +312,12 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
>>   */
>>  static void zswap_free_entry(struct zswap_entry *entry)
>>  {
>> -       zpool_free(entry->pool->zpool, entry->handle);
>> -       zswap_pool_put(entry->pool);
>> +       if (entry->zeroflag)
>> +               atomic_dec(&zswap_zero_pages);
>> +       else {
>> +               zpool_free(entry->pool->zpool, entry->handle);
>> +               zswap_pool_put(entry->pool);
>> +       }
>>         zswap_entry_cache_free(entry);
>>         atomic_dec(&zswap_stored_pages);
>>         zswap_update_total_size();
>> @@ -877,6 +887,19 @@ static int zswap_shrink(void)
>>         return ret;
>>  }
>>
>> +static int zswap_is_page_zero_filled(void *ptr)
>> +{
>> +       unsigned int pos;
>> +       unsigned long *page;
>> +
>> +       page = (unsigned long *)ptr;
>> +       for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
>> +               if (page[pos])
>> +                       return 0;
>> +       }
>> +       return 1;
>> +}
>> +
>>  /*********************************
>>  * frontswap hooks
>>  **********************************/
>> @@ -917,6 +940,15 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>                 goto reject;
>>         }
>>
>> +       src = kmap_atomic(page);
>> +       if (zswap_is_page_zero_filled(src)) {
>> +               kunmap_atomic(src);
>> +               entry->offset = offset;
>> +               entry->zeroflag = 1;
>> +               atomic_inc(&zswap_zero_pages);
>> +               goto insert_entry;
>> +       }
>> +
>>         /* if entry is successfully added, it keeps the reference */
>>         entry->pool = zswap_pool_current_get();
>>         if (!entry->pool) {
>> @@ -927,7 +959,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>         /* compress */
>>         dst = get_cpu_var(zswap_dstmem);
>>         tfm = *get_cpu_ptr(entry->pool->tfm);
>> -       src = kmap_atomic(page);
>>         ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
>>         kunmap_atomic(src);
>>         put_cpu_ptr(entry->pool->tfm);
>> @@ -961,6 +992,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>         entry->handle = handle;
>>         entry->length = dlen;
>>
>> +insert_entry:
>>         /* map */
>>         spin_lock(&tree->lock);
>>         do {
>> @@ -1013,6 +1045,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>>         }
>>         spin_unlock(&tree->lock);
>>
>> +       if (entry->zeroflag) {
>> +               dst = kmap_atomic(page);
>> +               memset(dst, 0, PAGE_SIZE);
>> +               kunmap_atomic(dst);
>> +               goto freeentry;
>> +       }
>> +
>>         /* decompress */
>>         dlen = PAGE_SIZE;
>>         src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
>> @@ -1025,6 +1064,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>>         zpool_unmap_handle(entry->pool->zpool, entry->handle);
>>         BUG_ON(ret);
>>
>> +freeentry:
>>         spin_lock(&tree->lock);
>>         zswap_entry_put(tree, entry);
>>         spin_unlock(&tree->lock);
>> @@ -1133,6 +1173,8 @@ static int __init zswap_debugfs_init(void)
>>                         zswap_debugfs_root, &zswap_pool_total_size);
>>         debugfs_create_atomic_t("stored_pages", S_IRUGO,
>>                         zswap_debugfs_root, &zswap_stored_pages);
>> +       debugfs_create_atomic_t("zero_pages", 0444,
>> +                       zswap_debugfs_root, &zswap_zero_pages);
>>
>>         return 0;
>>  }
>> --
>> 1.7.9.5
>
>
>
> --
> Regards,
> Sarbojit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
