Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CD6E3900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 00:54:57 -0400 (EDT)
Received: by padj3 with SMTP id j3so82322053pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 21:54:57 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id k1si13356616pdr.179.2015.06.02.21.54.55
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 21:54:56 -0700 (PDT)
Message-ID: <556E889D.9040400@lge.com>
Date: Wed, 03 Jun 2015 13:54:53 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/4] mm/balloon: apply driver page migratable into balloon
 driver
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>	<1433230065-3573-3-git-send-email-gioh.kim@lge.com> <CALYGNiNaYYPN-hckoxWTNgFd-piKwDakWk0yeuDG3wpaMA3Qpg@mail.gmail.com>
In-Reply-To: <CALYGNiNaYYPN-hckoxWTNgFd-piKwDakWk0yeuDG3wpaMA3Qpg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Michael S. Tsirkin" <mst@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, virtualization@lists.linux-foundation.org, gunho.lee@lge.com



> On Tue, Jun 2, 2015 at 10:27 AM, Gioh Kim <gioh.kim@lge.com> wrote:
>> Apply driver page migration into balloon driver.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> ---
>>   drivers/virtio/virtio_balloon.c        |  2 ++
>>   fs/proc/page.c                         |  4 +--
>>   include/linux/balloon_compaction.h     | 42 ++++++++++++++++-------
>>   include/linux/mm.h                     | 19 -----------
>>   include/uapi/linux/kernel-page-flags.h |  2 +-
>>   mm/balloon_compaction.c                | 61 ++++++++++++++++++++++++++++++++--
>>   6 files changed, 94 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 6a356e3..cdd0038 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -496,6 +496,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>>          balloon_devinfo_init(&vb->vb_dev_info);
>>   #ifdef CONFIG_BALLOON_COMPACTION
>>          vb->vb_dev_info.migratepage = virtballoon_migratepage;
>> +       vb->vb_dev_info.mapping = balloon_mapping_alloc(&vb->vb_dev_info,
>> +                                                       &balloon_aops);
>>   #endif
>>
>>          err = init_vqs(vb);
>> diff --git a/fs/proc/page.c b/fs/proc/page.c
>> index 7eee2d8..e741307 100644
>> --- a/fs/proc/page.c
>> +++ b/fs/proc/page.c
>> @@ -143,8 +143,8 @@ u64 stable_page_flags(struct page *page)
>>          if (PageBuddy(page))
>>                  u |= 1 << KPF_BUDDY;
>>
>> -       if (PageBalloon(page))
>> -               u |= 1 << KPF_BALLOON;
>> +       if (PageMigratable(page))
>> +               u |= 1 << KPF_MIGRATABLE;
>>
>>          u |= kpf_copy_bit(k, KPF_LOCKED,        PG_locked);
>>
>> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
>> index 9b0a15d..0989e96 100644
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -48,6 +48,7 @@
>>   #include <linux/migrate.h>
>>   #include <linux/gfp.h>
>>   #include <linux/err.h>
>> +#include <linux/fs.h>
>>
>>   /*
>>    * Balloon device information descriptor.
>> @@ -62,6 +63,7 @@ struct balloon_dev_info {
>>          struct list_head pages;         /* Pages enqueued & handled to Host */
>>          int (*migratepage)(struct balloon_dev_info *, struct page *newpage,
>>                          struct page *page, enum migrate_mode mode);
>> +       struct address_space *mapping;
>>   };
>>
>>   extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
>> @@ -73,24 +75,37 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
>>          spin_lock_init(&balloon->pages_lock);
>>          INIT_LIST_HEAD(&balloon->pages);
>>          balloon->migratepage = NULL;
>> +       balloon->mapping = NULL;
>>   }
>>
>>   #ifdef CONFIG_BALLOON_COMPACTION
>> -extern bool balloon_page_isolate(struct page *page);
>> +extern const struct address_space_operations balloon_aops;
>> +extern bool balloon_page_isolate(struct page *page,
>> +                                isolate_mode_t mode);
>>   extern void balloon_page_putback(struct page *page);
>> -extern int balloon_page_migrate(struct page *newpage,
>> +extern int balloon_page_migrate(struct address_space *mapping,
>> +                               struct page *newpage,
>>                                  struct page *page, enum migrate_mode mode);
>>
>> +extern struct address_space
>> +*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
>> +                      const struct address_space_operations *a_ops);
>> +
>> +static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>> +{
>> +       kfree(balloon_mapping);
>> +}
>> +
>>   /*
>> - * __is_movable_balloon_page - helper to perform @page PageBalloon tests
>> + * __is_movable_balloon_page - helper to perform @page PageMigratable tests
>>    */
>>   static inline bool __is_movable_balloon_page(struct page *page)
>>   {
>> -       return PageBalloon(page);
>> +       return PageMigratable(page);
>>   }
>>
>>   /*
>> - * balloon_page_movable - test PageBalloon to identify balloon pages
>> + * balloon_page_movable - test PageMigratable to identify balloon pages
>>    *                       and PagePrivate to check that the page is not
>>    *                       isolated and can be moved by compaction/migration.
>>    *
>> @@ -99,7 +114,7 @@ static inline bool __is_movable_balloon_page(struct page *page)
>>    */
>>   static inline bool balloon_page_movable(struct page *page)
>>   {
>> -       return PageBalloon(page) && PagePrivate(page);
>> +       return PageMigratable(page) && PagePrivate(page);
>>   }
>>
>>   /*
>> @@ -108,7 +123,7 @@ static inline bool balloon_page_movable(struct page *page)
>>    */
>>   static inline bool isolated_balloon_page(struct page *page)
>>   {
>> -       return PageBalloon(page);
>> +       return PageMigratable(page);
>>   }
>>
>>   /*
>> @@ -123,7 +138,8 @@ static inline bool isolated_balloon_page(struct page *page)
>>   static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>                                         struct page *page)
>>   {
>> -       __SetPageBalloon(page);
>> +       page->mapping = balloon->mapping;
>> +       __SetPageMigratable(page);
>>          SetPagePrivate(page);
>>          set_page_private(page, (unsigned long)balloon);
>>          list_add(&page->lru, &balloon->pages);
>> @@ -139,7 +155,8 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>    */
>>   static inline void balloon_page_delete(struct page *page)
>>   {
>> -       __ClearPageBalloon(page);
>> +       page->mapping = NULL;
>> +       __ClearPageMigratable(page);
>>          set_page_private(page, 0);
>>          if (PagePrivate(page)) {
>>                  ClearPagePrivate(page);
>> @@ -166,13 +183,13 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
>>   static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>                                         struct page *page)
>>   {
>> -       __SetPageBalloon(page);
>> +       __SetPageMigratable(page);
>>          list_add(&page->lru, &balloon->pages);
>>   }
>>
>>   static inline void balloon_page_delete(struct page *page)
>>   {
>> -       __ClearPageBalloon(page);
>> +       __ClearPageMigratable(page);
>>          list_del(&page->lru);
>>   }
>>
>> @@ -191,7 +208,8 @@ static inline bool isolated_balloon_page(struct page *page)
>>          return false;
>>   }
>>
>> -static inline bool balloon_page_isolate(struct page *page)
>> +static inline bool balloon_page_isolate(struct page *page,
>> +                                       isolate_mode_t mode)
>>   {
>>          return false;
>>   }
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 422c484..2d991a0 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -599,25 +599,6 @@ static inline void __ClearPageBuddy(struct page *page)
>>          atomic_set(&page->_mapcount, -1);
>>   }
>>
>> -#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
>> -
>> -static inline int PageBalloon(struct page *page)
>> -{
>> -       return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
>> -}
>> -
>> -static inline void __SetPageBalloon(struct page *page)
>> -{
>> -       VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
>> -       atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
>> -}
>> -
>> -static inline void __ClearPageBalloon(struct page *page)
>> -{
>> -       VM_BUG_ON_PAGE(!PageBalloon(page), page);
>> -       atomic_set(&page->_mapcount, -1);
>> -}
>> -
>
> Why you're killing this? This mark is exported into userspace.
>
>>   #define PAGE_MIGRATABLE_MAPCOUNT_VALUE (-256)
>>
>>   static inline int PageMigratable(struct page *page)
>> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
>> index a6c4962..a6a3c4b 100644
>> --- a/include/uapi/linux/kernel-page-flags.h
>> +++ b/include/uapi/linux/kernel-page-flags.h
>> @@ -31,7 +31,7 @@
>>
>>   #define KPF_KSM                        21
>>   #define KPF_THP                        22
>> -#define KPF_BALLOON            23
>> +#define KPF_MIGRATABLE         23
>>   #define KPF_ZERO_PAGE          24
>>
>>
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index fcad832..f98a500 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -131,7 +131,7 @@ static inline void __putback_balloon_page(struct page *page)
>>   }
>>
>>   /* __isolate_lru_page() counterpart for a ballooned page */
>> -bool balloon_page_isolate(struct page *page)
>> +bool balloon_page_isolate(struct page *page, isolate_mode_t mode)
>>   {
>>          /*
>>           * Avoid burning cycles with pages that are yet under __free_pages(),
>> @@ -175,6 +175,9 @@ bool balloon_page_isolate(struct page *page)
>>   /* putback_lru_page() counterpart for a ballooned page */
>>   void balloon_page_putback(struct page *page)
>>   {
>> +       if (!isolated_balloon_page(page))
>> +               return;
>> +
>>          /*
>>           * 'lock_page()' stabilizes the page and prevents races against
>>           * concurrent isolation threads attempting to re-isolate it.
>> @@ -193,12 +196,16 @@ void balloon_page_putback(struct page *page)
>>   }
>>
>>   /* move_to_new_page() counterpart for a ballooned page */
>> -int balloon_page_migrate(struct page *newpage,
>> +int balloon_page_migrate(struct address_space *mapping,
>> +                        struct page *newpage,
>>                           struct page *page, enum migrate_mode mode)
>>   {
>>          struct balloon_dev_info *balloon = balloon_page_device(page);
>>          int rc = -EAGAIN;
>>
>> +       if (!isolated_balloon_page(page))
>> +               return rc;
>> +
>>          /*
>>           * Block others from accessing the 'newpage' when we get around to
>>           * establishing additional references. We should be the only one
>> @@ -218,4 +225,54 @@ int balloon_page_migrate(struct page *newpage,
>>          unlock_page(newpage);
>>          return rc;
>>   }
>> +
>> +/* define the balloon_mapping->a_ops callback to allow balloon page migration */
>> +const struct address_space_operations balloon_aops = {
>> +       .migratepage = balloon_page_migrate,
>> +       .isolatepage = balloon_page_isolate,
>> +       .putbackpage = balloon_page_putback,
>> +};
>> +EXPORT_SYMBOL_GPL(balloon_aops);
>> +
>> +struct address_space *balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
>> +                               const struct address_space_operations *a_ops)
>> +{
>> +       struct address_space *mapping;
>> +
>> +       mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
>> +       if (!mapping)
>> +               return ERR_PTR(-ENOMEM);
>> +
>> +       /*
>> +        * Give a clean 'zeroed' status to all elements of this special
>> +        * balloon page->mapping struct address_space instance.
>> +        */
>> +       address_space_init_once(mapping);
>> +
>> +       /*
>> +        * Set mapping->flags appropriately, to allow balloon pages
>> +        * ->mapping identification.
>> +        */
>> +       mapping_set_migratable(mapping);
>> +       mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
>> +
>> +       /* balloon's page->mapping->a_ops callback descriptor */
>> +       mapping->a_ops = a_ops;
>> +
>> +       /*
>> +        * Establish a pointer reference back to the balloon device descriptor
>> +        * this particular page->mapping will be servicing.
>> +        * This is used by compaction / migration procedures to identify and
>> +        * access the balloon device pageset while isolating / migrating pages.
>> +        *
>> +        * As some balloon drivers can register multiple balloon devices
>> +        * for a single guest, this also helps compaction / migration to
>> +        * properly deal with multiple balloon pagesets, when required.
>> +        */
>> +       mapping->private_data = b_dev_info;
>> +       b_dev_info->mapping = mapping;
>> +
>> +       return mapping;
>> +}
>> +EXPORT_SYMBOL_GPL(balloon_mapping_alloc);
>
> So, you're reverting my changes and return this mess.
> I don't mind -- zram/balloon might have special mapping but at least please
> create it in appropriate way: together with valid inode and superblock.

I think it's not bad.
Anyway my point is that the generic callbacks are need to migrate non-LRU pages
as described in patch 1/4.
The patch 2~4 are an example to show howto use the generic callbacks.

>
> I think it's ok to use anon-inodes (fs/anon_inodes.c) for that.
> For now anon_inodefs has only one inode and I see no reason why it
> cannot keep more.
> Probably aio/drm could use it too instead of mounting it's own presudo
> filesystem.

Thank you for your feedback.


>
>>   #endif /* CONFIG_BALLOON_COMPACTION */
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
