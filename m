Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A836B6B02AC
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:37:33 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id x1so21129229lff.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:37:33 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id f198si2585913lfe.192.2017.01.19.07.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 07:37:32 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id h65so5810722lfi.3
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:37:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170119051503.GB2046@jagdpanzerIV.localdomain>
References: <20170119030004.GA2046@jagdpanzerIV.localdomain>
 <20170119042029.31476-1-ddstreet@ieee.org> <20170119051503.GB2046@jagdpanzerIV.localdomain>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 19 Jan 2017 10:36:51 -0500
Message-ID: <CALZtONA9k6UOYzCr=SxXz8Dfu+nzdx0N8GTc92fmmpSVhxezvA@mail.gmail.com>
Subject: Re: [PATCH] zswap: change BUG to WARN in zswap_writeback_entry
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexandr <sss123next@list.ru>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

On Thu, Jan 19, 2017 at 12:15 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (01/18/17 23:20), Dan Streetman wrote:
>> Change the BUG calls to WARN, and return error.
>>
>> There's no need to call BUG from this function, as it can safely return
>> the error.  The only caller of this function is the zpool that zswap is
>> using, when zswap is trying to reduce the zpool size.  While the error
>> does indicate a bug, as none of the WARN conditions should ever happen,
>> the zpool implementation can recover by trying to evict another page
>> or zswap will recover by sending the new page to the swap disk.
>>
>> This was reported in kernel bug 192571:
>> https://bugzilla.kernel.org/show_bug.cgi?id=192571

Andrew, please ignore this patch (for now at least)...it won't address this bug.

>>
>> Reported-by: Gluzskiy Alexandr <sss123next@list.ru>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  mm/zswap.c | 14 +++++++++++---
>>  1 file changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 067a0d6..60c4e6f 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -787,7 +787,10 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>>               return 0;
>>       }
>>       spin_unlock(&tree->lock);
>> -     BUG_ON(offset != entry->offset);
>> +     if (WARN_ON(offset != entry->offset)) {
>> +             ret = -EINVAL;
>> +             goto fail;
>> +     }
>>
>>       /* try to allocate swap cache page */
>>       switch (zswap_get_swap_cache_page(swpentry, &page)) {
>> @@ -813,8 +816,13 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>>               put_cpu_ptr(entry->pool->tfm);
>>               kunmap_atomic(dst);
>>               zpool_unmap_handle(entry->pool->zpool, entry->handle);
>> -             BUG_ON(ret);
>> -             BUG_ON(dlen != PAGE_SIZE);
>> +             if (WARN(ret, "error decompressing page: %d\n", ret))
>> +                     goto fail;
>> +             if (WARN(dlen != PAGE_SIZE,
>> +                      "decompressed page only %x bytes\n", dlen)) {
>> +                     ret = -EINVAL;
>> +                     goto fail;
>> +             }
>>
>>               /* page is up to date */
>>               SetPageUptodate(page);
>
>
> + zswap_frontswap_load() I suppose.

So my initial comment before that it was safe to switch to WARN was
right for zswap_writeback_entry(), but not right for
zswap_frontswap_load() - it was late and I didn't read the trace
correctly :(

At the BUG point in zswap_frontswap_load(), we have found the page in
the rb tree (via zswap_entry_find_get) so we know that we did accept
the page for storage, so we're the only place who has a copy of it
(assuming frontswap_writethrough isn't enabled).  If we can't
decompress it, then we only have 2 choices - BUG or return error.  If
we return error, frontswap will try any other frontswap backends it
has registered (none, I assume, or if so they should not have this
swap offset's entry, since we found a match).  After frontswap can't
recover the page from any of its backends, it will return error, and
swap_readpage() will then assume the page is actually stored on the
swap disk, and read it back.  However, the page wasn't written to the
swap disk (since we stored it in zswap), and whatever is read back
from the disk is not what was originally in the page - leading to
memory corruption.  So it's better to BUG at this point.

As to why it can't decompress the page, we should at least add info
about the error value.  Maybe the zpool storage encountered a bug and
provided the wrong compressed data to us...

>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 067a0d62f318..e2743687a202 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1023,13 +1023,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>         put_cpu_ptr(entry->pool->tfm);
>         kunmap_atomic(dst);
>         zpool_unmap_handle(entry->pool->zpool, entry->handle);
> -       BUG_ON(ret);
> +       WARN(ret, "error decompressing page: %d\n", ret);
>
>         spin_lock(&tree->lock);
>         zswap_entry_put(tree, entry);
>         spin_unlock(&tree->lock);
>
> -       return 0;
> +       return ret;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
