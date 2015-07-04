Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6D755280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 15:00:29 -0400 (EDT)
Received: by laar3 with SMTP id r3so115690158laa.0
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 12:00:28 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id sj9si10742104lac.145.2015.07.04.12.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Jul 2015 12:00:27 -0700 (PDT)
Received: by lagx9 with SMTP id x9so115525692lag.1
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 12:00:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYGNiPSXP5f9hnYjmHJrg7GQE+fM0RuKQOSu7QpWO5EmbiGoQ@mail.gmail.com>
References: <1435312710-15108-1-git-send-email-gioh.kim@lge.com>
	<1435312710-15108-5-git-send-email-gioh.kim@lge.com>
	<CALYGNiPSXP5f9hnYjmHJrg7GQE+fM0RuKQOSu7QpWO5EmbiGoQ@mail.gmail.com>
Date: Sat, 4 Jul 2015 22:00:26 +0300
Message-ID: <CALYGNiNCAK0HxHmoEtHk9q2n4XKPYPZfDvn5Am72-smitQhk7A@mail.gmail.com>
Subject: Re: [RFCv2 4/5] mm/compaction: compaction calls generic migration
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, Bruce Fields <bfields@fieldses.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, virtualization@lists.linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Jul 4, 2015 at 9:13 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Fri, Jun 26, 2015 at 12:58 PM, Gioh Kim <gioh.kim@lge.com> wrote:
>> Compaction calls interfaces of driver page migration
>> instead of calling balloon migration directly.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> ---
>>  drivers/virtio/virtio_balloon.c |  1 +
>>  mm/compaction.c                 |  9 +++++----
>>  mm/migrate.c                    | 21 ++++++++++++---------
>>  3 files changed, 18 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index c49b553..5e5cbea 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -30,6 +30,7 @@
>>  #include <linux/balloon_compaction.h>
>>  #include <linux/oom.h>
>>  #include <linux/wait.h>
>> +#include <linux/anon_inodes.h>
>>
>>  /*
>>   * Balloon device works in 4K page units.  So each page is pointed to by
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 16e1b57..cc5ec81 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -14,7 +14,7 @@
>>  #include <linux/backing-dev.h>
>>  #include <linux/sysctl.h>
>>  #include <linux/sysfs.h>
>> -#include <linux/balloon_compaction.h>
>> +#include <linux/compaction.h>
>>  #include <linux/page-isolation.h>
>>  #include <linux/kasan.h>
>>  #include "internal.h"
>> @@ -714,12 +714,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>>
>>                 /*
>>                  * Check may be lockless but that's ok as we recheck later.
>> -                * It's possible to migrate LRU pages and balloon pages
>> +                * It's possible to migrate LRU pages and driver pages
>>                  * Skip any other type of page
>>                  */
>>                 if (!PageLRU(page)) {
>> -                       if (unlikely(balloon_page_movable(page))) {
>> -                               if (balloon_page_isolate(page)) {
>> +                       if (unlikely(driver_page_migratable(page))) {
>> +                               if (page->mapping->a_ops->isolatepage(page,
>> +                                                               isolate_mode)) {
>
> Dereferencing page->mapping isn't safe here.
> Page could be "truncated" from mapping at any time.
>
> As you can see  balloon_page_isolate() calls get_page_unless_zero,
> trylock_page and only after that checks balloon_page_movable again.

Page must be getted and locked before calling aops method, somethin like this:

If (!PageLRU(page)) {
   if (PageBalloon(page) || PageMobile(page))
       if (get_page_unless_zero(page))
           if (try_lock(page))
              if (page->mapping && page->mapping->a_ops->isolatepage)
                  page->mapping->a_ops->isolate_page(page, ...)
....

>
> Existing code already does similar unsafe dereference in
> __isolate_lru_page(): page->mapping->a_ops->migratepage

>
>>                                         /* Successfully isolated */
>>                                         goto isolate_success;
>>                                 }
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 236ee25..a0bc1e4 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -35,7 +35,7 @@
>>  #include <linux/hugetlb.h>
>>  #include <linux/hugetlb_cgroup.h>
>>  #include <linux/gfp.h>
>> -#include <linux/balloon_compaction.h>
>> +#include <linux/compaction.h>
>>  #include <linux/mmu_notifier.h>
>>
>>  #include <asm/tlbflush.h>
>> @@ -76,7 +76,7 @@ int migrate_prep_local(void)
>>   * from where they were once taken off for compaction/migration.
>>   *
>>   * This function shall be used whenever the isolated pageset has been
>> - * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
>> + * built from lru, driver, hugetlbfs page. See isolate_migratepages_range()
>>   * and isolate_huge_page().
>>   */
>>  void putback_movable_pages(struct list_head *l)
>> @@ -92,8 +92,8 @@ void putback_movable_pages(struct list_head *l)
>>                 list_del(&page->lru);
>>                 dec_zone_page_state(page, NR_ISOLATED_ANON +
>>                                 page_is_file_cache(page));
>> -               if (unlikely(isolated_balloon_page(page)))
>> -                       balloon_page_putback(page);
>> +               if (unlikely(driver_page_migratable(page)))
>> +                       page->mapping->a_ops->putbackpage(page);
>>                 else
>>                         putback_lru_page(page);
>>         }
>> @@ -844,15 +844,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>                 }
>>         }
>>
>> -       if (unlikely(isolated_balloon_page(page))) {
>> +       if (unlikely(driver_page_migratable(page))) {
>>                 /*
>> -                * A ballooned page does not need any special attention from
>> +                * A driver page does not need any special attention from
>>                  * physical to virtual reverse mapping procedures.
>>                  * Skip any attempt to unmap PTEs or to remap swap cache,
>>                  * in order to avoid burning cycles at rmap level, and perform
>>                  * the page migration right away (proteced by page lock).
>>                  */
>> -               rc = balloon_page_migrate(newpage, page, mode);
>> +               rc = page->mapping->a_ops->migratepage(page->mapping,
>> +                                                      newpage,
>> +                                                      page,
>> +                                                      mode);
>>                 goto out_unlock;
>>         }
>>
>> @@ -962,8 +965,8 @@ out:
>>         if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
>>                 ClearPageSwapBacked(newpage);
>>                 put_new_page(newpage, private);
>> -       } else if (unlikely(__is_movable_balloon_page(newpage))) {
>> -               /* drop our reference, page already in the balloon */
>> +       } else if (unlikely(driver_page_migratable(newpage))) {
>> +               /* drop our reference */
>>                 put_page(newpage);
>>         } else
>>                 putback_lru_page(newpage);
>> --
>> 1.9.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
