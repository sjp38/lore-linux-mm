Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 02B5D6B0035
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 02:44:42 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so3892697iec.29
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 23:44:42 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id x7si719648ice.38.2014.08.29.23.44.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 23:44:42 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so3885722iec.12
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 23:44:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140829143811.90bfab2a46ccade0f586b369@linux-foundation.org>
References: <20140820150435.4194.28003.stgit@buzz>
	<20140820150509.4194.24336.stgit@buzz>
	<20140829143811.90bfab2a46ccade0f586b369@linux-foundation.org>
Date: Sat, 30 Aug 2014 10:44:41 +0400
Message-ID: <CALYGNiN9rHG-b1p-seR9NfDW-FKAxeQq6iUTdmr1PoQYEpr+qA@mail.gmail.com>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rafael Aquini <aquini@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Aug 30, 2014 at 1:38 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 20 Aug 2014 19:05:09 +0400 Konstantin Khlebnikov <k.khlebnikov@samsung.com> wrote:
>
>> * move special branch for balloon migraion into migrate_pages
>> * remove special mapping for balloon and its flag AS_BALLOON_MAP
>> * embed struct balloon_dev_info into struct virtio_balloon
>> * cleanup balloon_page_dequeue, kill balloon_page_free
>
> Another testing failure.  Guys, allnoconfig is really fast.

Heh, mea culpa too. I've missed messages about including my patches except one
with stress-test, probably they are stuck somewhere in my corporate email.
So I thought you've picked only one patch.

Rafael had several suggestions so I postponed them till v2 patchset
which never been sent.

>
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -54,58 +54,27 @@
>>   * balloon driver as a page book-keeper for its registered balloon devices.
>>   */
>>  struct balloon_dev_info {
>> -     void *balloon_device;           /* balloon device descriptor */
>> -     struct address_space *mapping;  /* balloon special page->mapping */
>>       unsigned long isolated_pages;   /* # of isolated pages for migration */
>>       spinlock_t pages_lock;          /* Protection to pages list */
>>       struct list_head pages;         /* Pages enqueued & handled to Host */
>> +     int (* migrate_page)(struct balloon_dev_info *, struct page *newpage,
>> +                     struct page *page, enum migrate_mode mode);
>>  };
>
> If CONFIG_MIGRATION=n this gets turned into "NULL" and chaos ensues.  I
> think I'll just nuke that #define:

Hmm, i think it's better to rename migrate_page() into something less generic.
for example generic_migrate_page() or generic_migratepage().

>
> --- a/include/linux/migrate.h~include-linux-migrateh-remove-migratepage-define
> +++ a/include/linux/migrate.h
> @@ -82,9 +82,6 @@ static inline int migrate_huge_page_move
>         return -ENOSYS;
>  }
>
> -/* Possible settings for the migrate_page() method in address_operations */
> -#define migrate_page NULL
> -
>  #endif /* CONFIG_MIGRATION */
>
>  #ifdef CONFIG_NUMA_BALANCING
> --- a/mm/swap_state.c~include-linux-migrateh-remove-migratepage-define
> +++ a/mm/swap_state.c
> @@ -28,7 +28,9 @@
>  static const struct address_space_operations swap_aops = {
>         .writepage      = swap_writepage,
>         .set_page_dirty = swap_set_page_dirty,
> +#ifdef CONFIG_MIGRATION
>         .migratepage    = migrate_page,
> +#endif
>  };
>
>  static struct backing_dev_info swap_backing_dev_info = {
> --- a/mm/shmem.c~include-linux-migrateh-remove-migratepage-define
> +++ a/mm/shmem.c
> @@ -3075,7 +3075,9 @@ static const struct address_space_operat
>         .write_begin    = shmem_write_begin,
>         .write_end      = shmem_write_end,
>  #endif
> +#ifdef CONFIG_MIGRATION
>         .migratepage    = migrate_page,
> +#endif
>         .error_remove_page = generic_error_remove_page,
>  };
>
>
> Our mixture of "migratepage" and "migrate_page" is maddening.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
