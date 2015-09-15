Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id EAA396B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:04:38 -0400 (EDT)
Received: by ioii196 with SMTP id i196so191016060ioi.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:04:38 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id gz8si6647930igb.48.2015.09.14.23.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:04:38 -0700 (PDT)
Received: by igcpb10 with SMTP id pb10so8514531igc.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:04:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915011249.GD1860@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150914155521.8b5ccc16b09e09d885a9ce5a@gmail.com> <20150915011249.GD1860@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 15 Sep 2015 02:03:58 -0400
Message-ID: <CALZtONABXfiRA00FyzN-9m3QSJ8hHpn0wMBhTZEVW+1PxbdCvw@mail.gmail.com>
Subject: Re: [PATCH 3/3] zram: use common zpool interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 14, 2015 at 9:12 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (09/14/15 15:55), Vitaly Wool wrote:
>> Update zram driver to use common zpool API instead of calling
>> zsmalloc functions directly. This patch also adds a parameter
>> that allows for changing underlying compressor storage to zbud.
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  drivers/block/zram/Kconfig    |  3 ++-
>>  drivers/block/zram/zram_drv.c | 44 ++++++++++++++++++++++++-------------------
>>  drivers/block/zram/zram_drv.h |  4 ++--
>>  3 files changed, 29 insertions(+), 22 deletions(-)
>>
>> diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
>> index 386ba3d..4831d0a 100644
>> --- a/drivers/block/zram/Kconfig
>> +++ b/drivers/block/zram/Kconfig
>> @@ -1,6 +1,7 @@
>>  config ZRAM
>>       tristate "Compressed RAM block device support"
>> -     depends on BLOCK && SYSFS && ZSMALLOC
>> +     depends on BLOCK && SYSFS
>> +     select ZPOOL
>
> well, in that case, all `#ifdef CONFIG_ZPOOL' in zsmalloc can be dropped,
> because now it's a must have.

yeah, it could be dropped from zbud as well.

>
>
>>       select LZO_COMPRESS
>>       select LZO_DECOMPRESS
>>       default n
>> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
>> index 49d5a65..2829c3d 100644
>> --- a/drivers/block/zram/zram_drv.c
>> +++ b/drivers/block/zram/zram_drv.c
>> @@ -44,6 +44,9 @@ static const char *default_compressor = "lzo";
>>  static unsigned int num_devices = 1;
>>  static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>>
>> +#define ZRAM_ZPOOL_DEFAULT "zsmalloc"
>> +static char *pool_type = ZRAM_ZPOOL_DEFAULT;
>> +
>>  static inline void deprecated_attr_warn(const char *name)
>>  {
>>       pr_warn_once("%d (%s) Attribute %s (and others) will be removed. %s\n",
>> @@ -229,11 +232,11 @@ static ssize_t mem_used_total_show(struct device *dev,
>>       down_read(&zram->init_lock);
>>       if (init_done(zram)) {
>>               struct zram_meta *meta = zram->meta;
>> -             val = zs_get_total_pages(meta->mem_pool);
>> +             val = zpool_get_total_size(meta->mem_pool);
>>       }
>>       up_read(&zram->init_lock);
>>
>> -     return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
>> +     return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
>>  }
>>
>>  static ssize_t mem_limit_show(struct device *dev,
>> @@ -298,7 +301,7 @@ static ssize_t mem_used_max_store(struct device *dev,
>>       if (init_done(zram)) {
>>               struct zram_meta *meta = zram->meta;
>>               atomic_long_set(&zram->stats.max_used_pages,
>> -                             zs_get_total_pages(meta->mem_pool));
>> +                     zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT);
>>       }
>>       up_read(&zram->init_lock);
>>
>> @@ -399,7 +402,7 @@ static ssize_t compact_store(struct device *dev,
>>       }
>>
>>       meta = zram->meta;
>> -     zs_compact(meta->mem_pool);
>> +     zpool_compact(meta->mem_pool, NULL);
>
> so you don't use that 'compacted' param.
>
>
>>       up_read(&zram->init_lock);
>>
>>       return len;
>> @@ -436,8 +439,8 @@ static ssize_t mm_stat_show(struct device *dev,
>>
>>       down_read(&zram->init_lock);
>>       if (init_done(zram)) {
>> -             mem_used = zs_get_total_pages(zram->meta->mem_pool);
>> -             zs_pool_stats(zram->meta->mem_pool, &pool_stats);
>> +             mem_used = zpool_get_total_size(zram->meta->mem_pool);
>> +             zpool_stats(zram->meta->mem_pool, &pool_stats);
>>       }
>>
>>       orig_size = atomic64_read(&zram->stats.pages_stored);
>> @@ -447,7 +450,7 @@ static ssize_t mm_stat_show(struct device *dev,
>>                       "%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
>>                       orig_size << PAGE_SHIFT,
>>                       (u64)atomic64_read(&zram->stats.compr_data_size),
>> -                     mem_used << PAGE_SHIFT,
>> +                     mem_used,
>>                       zram->limit_pages << PAGE_SHIFT,
>>                       max_used << PAGE_SHIFT,
>>                       (u64)atomic64_read(&zram->stats.zero_pages),
>> @@ -492,10 +495,10 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
>>               if (!handle)
>>                       continue;
>>
>> -             zs_free(meta->mem_pool, handle);
>> +             zpool_free(meta->mem_pool, handle);
>>       }
>>
>> -     zs_destroy_pool(meta->mem_pool);
>> +     zpool_destroy_pool(meta->mem_pool);
>>       vfree(meta->table);
>>       kfree(meta);
>>  }
>> @@ -515,7 +518,8 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
>>               goto out_error;
>>       }
>>
>> -     meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO | __GFP_HIGHMEM);
>> +     meta->mem_pool = zpool_create_pool(pool_type, pool_name,
>> +                     GFP_NOIO | __GFP_HIGHMEM, NULL);
>>       if (!meta->mem_pool) {
>>               pr_err("Error creating memory pool\n");
>>               goto out_error;
>> @@ -551,7 +555,7 @@ static void zram_free_page(struct zram *zram, size_t index)
>>               return;
>>       }
>>
>> -     zs_free(meta->mem_pool, handle);
>> +     zpool_free(meta->mem_pool, handle);
>>
>>       atomic64_sub(zram_get_obj_size(meta, index),
>>                       &zram->stats.compr_data_size);
>> @@ -579,12 +583,12 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>>               return 0;
>>       }
>>
>> -     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
>> +     cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_RO);
>>       if (size == PAGE_SIZE)
>>               copy_page(mem, cmem);
>>       else
>>               ret = zcomp_decompress(zram->comp, cmem, size, mem);
>> -     zs_unmap_object(meta->mem_pool, handle);
>> +     zpool_unmap_handle(meta->mem_pool, handle);
>>       bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>>
>>       /* Should NEVER happen. Return bio error if it does. */
>> @@ -718,24 +722,24 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>>                       src = uncmem;
>>       }
>>
>> -     handle = zs_malloc(meta->mem_pool, clen);
>> -     if (!handle) {
>> +     if (zpool_malloc(meta->mem_pool, clen, __GFP_IO | __GFP_NOWARN,
>
> hm, GFP_NOIO and __GFP_IO...

NOWARN isn't needed; zswap uses it but zram doesn't need to, in fact
zram probably does want a nomem warning printed since it does return
the error to the caller who is writing to zram.

with zsmalloc, the gfp flags are what was passed at pool creation
time, so this should be __GFP_NOIO | __GFP_HIGHMEM.  However, zbud
doesn't allow alloc with highmem.  What probably is best here is to
use NOIO and HIGHMEM from zram, and change zbud to just strip out
HIGHMEM if it's set, instead of returning error.  Although if zram
actually requires using highmem, that would be a problem.

>
>> +                     &handle) != 0) {
>>               pr_err("Error allocating memory for compressed page: %u, size=%zu\n",
>>                       index, clen);
>>               ret = -ENOMEM;
>>               goto out;
>>       }
>>
>> -     alloced_pages = zs_get_total_pages(meta->mem_pool);
>> +     alloced_pages = zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT;
>>       if (zram->limit_pages && alloced_pages > zram->limit_pages) {
>> -             zs_free(meta->mem_pool, handle);
>> +             zpool_free(meta->mem_pool, handle);
>>               ret = -ENOMEM;
>>               goto out;
>>       }
>>
>>       update_used_max(zram, alloced_pages);
>>
>> -     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
>> +     cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_WO);
>>
>>       if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
>>               src = kmap_atomic(page);
>> @@ -747,7 +751,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>>
>>       zcomp_strm_release(zram->comp, zstrm);
>>       zstrm = NULL;
>> -     zs_unmap_object(meta->mem_pool, handle);
>> +     zpool_unmap_handle(meta->mem_pool, handle);
>>
>>       /*
>>        * Free memory associated with this sector
>> @@ -1457,6 +1461,8 @@ module_param(num_devices, uint, 0);
>>  MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
>>  module_param(max_zpage_size, ulong, 0);
>>  MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed pages");
>> +module_param_named(zpool_type, pool_type, charp, 0444);
>> +MODULE_PARM_DESC(zpool_type, "zpool implementation selection (zsmalloc vs zbud)");
>>
>>  MODULE_LICENSE("Dual BSD/GPL");
>>  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
>> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
>> index 3a29c33..9a64b94 100644
>> --- a/drivers/block/zram/zram_drv.h
>> +++ b/drivers/block/zram/zram_drv.h
>> @@ -16,7 +16,7 @@
>>  #define _ZRAM_DRV_H_
>>
>>  #include <linux/spinlock.h>
>> -#include <linux/zsmalloc.h>
>> +#include <linux/zpool.h>
>>
>>  #include "zcomp.h"
>>
>> @@ -73,7 +73,7 @@ struct zram_stats {
>>
>>  struct zram_meta {
>>       struct zram_table_entry *table;
>> -     struct zs_pool *mem_pool;
>> +     struct zpool *mem_pool;
>>  };
>>
>>  struct zram {
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
