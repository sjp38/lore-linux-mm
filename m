Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48F356B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:39:59 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id h189so15614771ywf.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:39:59 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id d67si413556ybi.823.2017.07.19.23.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 23:39:58 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id v193so785739ywg.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:39:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170717053941.GA29581@bbox>
References: <1500018667-30175-1-git-send-email-zhuhui@xiaomi.com> <20170717053941.GA29581@bbox>
From: Hui Zhu <teawater@gmail.com>
Date: Thu, 20 Jul 2017 14:39:17 +0800
Message-ID: <CANFwon3uY_G1RshS2-3ZQu5wCre5oK6kbBNxskKVNvB3NVPTBQ@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: not check inuse if
 migrate_mode is not MIGRATE_ASYNC
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Minchan,

I am sorry for answer late.
I spent some time on ubuntu 16.04 with mmtests in an old laptop.

2017-07-17 13:39 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hello Hui,
>
> On Fri, Jul 14, 2017 at 03:51:07PM +0800, Hui Zhu wrote:
>> Got some -EBUSY from zs_page_migrate that will make migration
>> slow (retry) or fail (zs_page_putback will schedule_work free_work,
>> but it cannot ensure the success).
>
> I think EAGAIN(migration retrial) is better than EBUSY(bailout) because
> expectation is that zsmalloc will release the empty zs_page soon so
> at next retrial, it will be succeeded.


I am not sure.

This is the call trace of zs_page_migrate:
zs_page_migrate
mapping->a_ops->migratepage
move_to_new_page
__unmap_and_move
unmap_and_move
migrate_pages

In unmap_and_move will remove page from migration page list
and call putback_movable_page(will call mapping->a_ops->putback_page) if
return value of zs_page_migrate is not -EAGAIN.
The comments of this part:
After called mapping->a_ops->putback_page, zsmalloc can free the page
from ZS_EMPTY list.

If retrun -EAGAIN, the page will be not be put back.  EAGAIN page will
be try again in migrate_pages without re-isolate.

> About schedule_work, as you said, we don't make sure when it happens but
> I believe it will happen in a migration iteration most of case.
> How often do you see that case?

I noticed this issue because my Kernel patch https://lkml.org/lkml/2014/5/28/113
that will remove retry in __alloc_contig_migrate_range.
This retry willhandle the -EBUSY because it will re-isolate the page
and re-call migrate_pages.
Without it will make cma_alloc fail at once with -EBUSY.

>
>>
>> And I didn't find anything that make zs_page_migrate cannot work with
>> a ZS_EMPTY zspage.
>> So make the patch to not check inuse if migrate_mode is not
>> MIGRATE_ASYNC.
>
> At a first glance, I think it work but the question is that it a same problem
> ith schedule_work of zs_page_putback. IOW, Until the work is done, compaction
> cannot succeed. Do you have any number before and after?
>


Following is what I got with highalloc-performance in a vbox with 2
cpu 1G memory 512 zram as swap:
                                   ori        afte
                                  orig       after
Minor Faults                  50805113    50801261
Major Faults                     43918       46692
Swap Ins                         42087       46299
Swap Outs                        89718      105495
Allocation stalls                    0           0
DMA allocs                       57787       69787
DMA32 allocs                  47964599    47983772
Normal allocs                        0           0
Movable allocs                       0           0
Direct pages scanned             45493       28837
Kswapd pages scanned           1565222     1512947
Kswapd pages reclaimed         1342222     1334030
Direct pages reclaimed           45615       30174
Kswapd efficiency                  85%         88%
Kswapd velocity               1897.101    1708.309
Direct efficiency                 100%        104%
Direct velocity                 55.139      32.561
Percentage direct scans             2%          1%
Zone normal velocity          1952.240    1740.870
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim       89764.000  106043.000
Page writes file                    46         548
Page writes anon                 89718      105495
Page reclaim immediate           21457        7269
Sector Reads                   3259688     3144160
Sector Writes                  3667252     3675528
Page rescued immediate               0           0
Slabs scanned                  1042872     1035438
Direct inode steals               8042        7772
Kswapd inode steals              54295       55075
Kswapd skipped wait                  0           0
THP fault alloc                    175         200
THP collapse alloc                 226         363
THP splits                           0           0
THP fault fallback                  11           1
THP collapse fail                    3           1
Compaction stalls                  536         647
Compaction success                 322         384
Compaction failures                214         263
Page migrate success            119608      127002
Page migrate failure              2723        2309
Compaction pages isolated       250179      265318
Compaction migrate scanned     9131832     9351314
Compaction free scanned        2093272     3059014
Compaction cost                    192         202
NUMA alloc hit                47124555    47086375
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local              47124555    47086375
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

It looks Page migrate success is increased.

Thanks,
Hui


> Thanks.
>
>>
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>> ---
>>  mm/zsmalloc.c | 66 +++++++++++++++++++++++++++++++++--------------------------
>>  1 file changed, 37 insertions(+), 29 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index d41edd2..c298e5c 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -1982,6 +1982,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>       unsigned long old_obj, new_obj;
>>       unsigned int obj_idx;
>>       int ret = -EAGAIN;
>> +     int inuse;
>>
>>       VM_BUG_ON_PAGE(!PageMovable(page), page);
>>       VM_BUG_ON_PAGE(!PageIsolated(page), page);
>> @@ -1996,21 +1997,24 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>       offset = get_first_obj_offset(page);
>>
>>       spin_lock(&class->lock);
>> -     if (!get_zspage_inuse(zspage)) {
>> +     inuse = get_zspage_inuse(zspage);
>> +     if (mode == MIGRATE_ASYNC && !inuse) {
>>               ret = -EBUSY;
>>               goto unlock_class;
>>       }
>>
>>       pos = offset;
>>       s_addr = kmap_atomic(page);
>> -     while (pos < PAGE_SIZE) {
>> -             head = obj_to_head(page, s_addr + pos);
>> -             if (head & OBJ_ALLOCATED_TAG) {
>> -                     handle = head & ~OBJ_ALLOCATED_TAG;
>> -                     if (!trypin_tag(handle))
>> -                             goto unpin_objects;
>> +     if (inuse) {
>> +             while (pos < PAGE_SIZE) {
>> +                     head = obj_to_head(page, s_addr + pos);
>> +                     if (head & OBJ_ALLOCATED_TAG) {
>> +                             handle = head & ~OBJ_ALLOCATED_TAG;
>> +                             if (!trypin_tag(handle))
>> +                                     goto unpin_objects;
>> +                     }
>> +                     pos += class->size;
>>               }
>> -             pos += class->size;
>>       }
>>
>>       /*
>> @@ -2020,20 +2024,22 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>       memcpy(d_addr, s_addr, PAGE_SIZE);
>>       kunmap_atomic(d_addr);
>>
>> -     for (addr = s_addr + offset; addr < s_addr + pos;
>> -                                     addr += class->size) {
>> -             head = obj_to_head(page, addr);
>> -             if (head & OBJ_ALLOCATED_TAG) {
>> -                     handle = head & ~OBJ_ALLOCATED_TAG;
>> -                     if (!testpin_tag(handle))
>> -                             BUG();
>> -
>> -                     old_obj = handle_to_obj(handle);
>> -                     obj_to_location(old_obj, &dummy, &obj_idx);
>> -                     new_obj = (unsigned long)location_to_obj(newpage,
>> -                                                             obj_idx);
>> -                     new_obj |= BIT(HANDLE_PIN_BIT);
>> -                     record_obj(handle, new_obj);
>> +     if (inuse) {
>> +             for (addr = s_addr + offset; addr < s_addr + pos;
>> +                                             addr += class->size) {
>> +                     head = obj_to_head(page, addr);
>> +                     if (head & OBJ_ALLOCATED_TAG) {
>> +                             handle = head & ~OBJ_ALLOCATED_TAG;
>> +                             if (!testpin_tag(handle))
>> +                                     BUG();
>> +
>> +                             old_obj = handle_to_obj(handle);
>> +                             obj_to_location(old_obj, &dummy, &obj_idx);
>> +                             new_obj = (unsigned long)
>> +                                     location_to_obj(newpage, obj_idx);
>> +                             new_obj |= BIT(HANDLE_PIN_BIT);
>> +                             record_obj(handle, new_obj);
>> +                     }
>>               }
>>       }
>>
>> @@ -2055,14 +2061,16 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>
>>       ret = MIGRATEPAGE_SUCCESS;
>>  unpin_objects:
>> -     for (addr = s_addr + offset; addr < s_addr + pos;
>> +     if (inuse) {
>> +             for (addr = s_addr + offset; addr < s_addr + pos;
>>                                               addr += class->size) {
>> -             head = obj_to_head(page, addr);
>> -             if (head & OBJ_ALLOCATED_TAG) {
>> -                     handle = head & ~OBJ_ALLOCATED_TAG;
>> -                     if (!testpin_tag(handle))
>> -                             BUG();
>> -                     unpin_tag(handle);
>> +                     head = obj_to_head(page, addr);
>> +                     if (head & OBJ_ALLOCATED_TAG) {
>> +                             handle = head & ~OBJ_ALLOCATED_TAG;
>> +                             if (!testpin_tag(handle))
>> +                                     BUG();
>> +                             unpin_tag(handle);
>> +                     }
>>               }
>>       }
>>       kunmap_atomic(s_addr);
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
