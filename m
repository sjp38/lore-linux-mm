Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B00FC6B0032
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 21:39:44 -0400 (EDT)
Received: by pdea3 with SMTP id a3so89957217pde.3
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 18:39:44 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id e4si13421846pdp.245.2015.04.12.18.39.41
        for <linux-mm@kvack.org>;
        Sun, 12 Apr 2015 18:39:42 -0700 (PDT)
Message-ID: <552B1E5C.3030501@lge.com>
Date: Mon, 13 Apr 2015 10:39:40 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add generic callbacks into compaction
References: <1427843490-27084-1-git-send-email-gioh.kim@lge.com> <20150407005344.GA27788@blaptop>
In-Reply-To: <20150407005344.GA27788@blaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: rusty@rustcorp.com.au, mst@redhat.com, mgorman@suse.de, jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, koct9i@gmail.com, iamjoonsoo.kim@lge.com, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org



2015-04-07 i??i ? 9:59i?? Minchan Kim i?'(e??) i?' e,?:
> Hello Gioh,
>
> I wanted to have such feature for zsmalloc.
> Thanks for the work.
>
> On Wed, Apr 01, 2015 at 08:11:30AM +0900, Gioh Kim wrote:
>> I sent a patch about page allocation for less fragmentation.
>> http://permalink.gmane.org/gmane.linux.kernel.mm/130599
>>
>> It proposes a page allocator allocates pages in the same pageblock
>> for the drivers to move their unmovable pages. Some drivers which comsumes many pages
>> and increases system fragmentation use the allocator to move their pages to
>> decrease fragmentation.
>>
>> I think I can try another approach.
>> There is a compaction code for balloon pages.
>> But the compaction code cannot migrate pages of other drivers.
>> If there is a generic migration framework applicable to any drivers,
>> drivers can register their migration functions.
>> And the compaction can migrate movable pages and also driver's pages.
>>
>> I'm not familiar with virtualization so I couldn't test this patch yet.
>> But if mm developers agree with this approach, I will complete this patch.
>>
>> I would do appreciate any feedback.
>
> Could you separate introducing migrate core patchset and balloon patchset for
> using the feature?

Sure.

>
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> ---
>>   drivers/virtio/virtio_balloon.c    |    2 ++
>>   include/linux/balloon_compaction.h |   23 +++++++++---
>>   include/linux/fs.h                 |    3 ++
>>   include/linux/pagemap.h            |   26 ++++++++++++++
>>   mm/balloon_compaction.c            |   68 ++++++++++++++++++++++++++++++++++--
>>   mm/compaction.c                    |    7 ++--
>>   mm/migrate.c                       |   24 ++++++-------
>>   7 files changed, 129 insertions(+), 24 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 0413157..cd9b8e4 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -486,6 +486,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>>
>>   	balloon_devinfo_init(&vb->vb_dev_info);
>>   #ifdef CONFIG_BALLOON_COMPACTION
>> +	vb->vb_dev_info.mapping = balloon_mapping_alloc(&vb->vb_dev_info,
>> +							&balloon_aops);
>>   	vb->vb_dev_info.migratepage = virtballoon_migratepage;
>>   #endif
>>
>> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
>> index 9b0a15d..0af32b3 100644
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -62,6 +62,7 @@ struct balloon_dev_info {
>>   	struct list_head pages;		/* Pages enqueued & handled to Host */
>>   	int (*migratepage)(struct balloon_dev_info *, struct page *newpage,
>>   			struct page *page, enum migrate_mode mode);
>> +	struct address_space *mapping;
>>   };
>>
>>   extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
>> @@ -76,10 +77,22 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
>>   }
>>
>>   #ifdef CONFIG_BALLOON_COMPACTION
>> -extern bool balloon_page_isolate(struct page *page);
>> -extern void balloon_page_putback(struct page *page);
>> -extern int balloon_page_migrate(struct page *newpage,
>> -				struct page *page, enum migrate_mode mode);
>> +extern const struct address_space_operations balloon_aops;
>> +extern int balloon_page_isolate(struct page *page);
>> +extern int balloon_page_putback(struct page *page);
>> +extern int balloon_page_migrate(struct address_space *mapping,
>> +				struct page *newpage,
>> +				struct page *page,
>> +				enum migrate_mode mode);
>> +
>> +extern struct address_space
>> +*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
>> +		       const struct address_space_operations *a_ops);
>> +
>> +static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>> +{
>> +	kfree(balloon_mapping);
>> +}
>>
>>   /*
>>    * __is_movable_balloon_page - helper to perform @page PageBalloon tests
>> @@ -123,6 +136,7 @@ static inline bool isolated_balloon_page(struct page *page)
>>   static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>   				       struct page *page)
>>   {
>> +	page->mapping = balloon->mapping;
>>   	__SetPageBalloon(page);
>>   	SetPagePrivate(page);
>>   	set_page_private(page, (unsigned long)balloon);
>> @@ -139,6 +153,7 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>    */
>>   static inline void balloon_page_delete(struct page *page)
>>   {
>> +	page->mapping = NULL;
>>   	__ClearPageBalloon(page);
>>   	set_page_private(page, 0);
>>   	if (PagePrivate(page)) {
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index b4d71b5..de463b9 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -368,6 +368,9 @@ struct address_space_operations {
>>   	 */
>>   	int (*migratepage) (struct address_space *,
>>   			struct page *, struct page *, enum migrate_mode);
>> +	int (*isolatepage)(struct page *);
>
> It would be useful if isolatepage is aware of migrate_mode and address_space
> For exmaple, if it is MIGRATE_SYNC, driver could wait  some of work to finish.
>>From address_space, driver can get private data registered when isolate/putback
> happens.
>
>
>> +	int (*putbackpage)(struct page *);
>
> Ditto.

OK. v2 will be:
int (*isolatepage)(struct address_space *, struct page *, enum migrate_mode);
int (*putbackpage)(struct address_space *, struct page *, enum migrate_mode);

>
>> +
>>   	int (*launder_page) (struct page *);
>>   	int (*is_partially_uptodate) (struct page *, unsigned long,
>>   					unsigned long);
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 4b3736f..715b5b2 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -25,6 +25,7 @@ enum mapping_flags {
>>   	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>>   	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>>   	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
>> +	AS_MIGRATABLE   = __GFP_BITS_SHIFT + 5,
>>   };
>>
>>   static inline void mapping_set_error(struct address_space *mapping, int error)
>> @@ -54,6 +55,31 @@ static inline int mapping_unevictable(struct address_space *mapping)
>>   	return !!mapping;
>>   }
>>
>> +static inline void mapping_set_migratable(struct address_space *mapping)
>> +{
>> +	set_bit(AS_MIGRATABLE, &mapping->flags);
>> +}
>
> It means every address_space which want to migrate pages mapped the address space
> should call this function?

Yes, it does. It is the common function to check the page migratable.

>
>> +
>> +static inline void mapping_clear_migratable(struct address_space *mapping)
>> +{
>> +	clear_bit(AS_MIGRATABLE, &mapping->flags);
>> +}
>> +
>> +static inline int __mapping_ops(struct address_space *mapping)
>
> The naming of __mapping_ops is awkward. How about "bool is_migratable(...)"?

OK. What about __check_migrate_ops?

> Another question:
> Why should they support all fucntions of migrate(ie, migratepage, isolatepage, putbackpage).
> I mean currently inode of regular file supports only migratepage.
> By your rule, they are not migratable?

I want to make a common framework to be able to support migrate/isolate/putback.
If you doesn't need any of it, you can make it empty function.
Is it irrational?

>
>> +{
>> +	return mapping->a_ops &&
>> +		mapping->a_ops->migratepage &&
>> +		mapping->a_ops->isolatepage &&
>> +		mapping->a_ops->putbackpage;
>> +}
>> +
>> +static inline int mapping_migratable(struct address_space *mapping)
>> +{
>> +	if (mapping && __mapping_ops(mapping))
>
> Why do we need mapping NULL check in here?
> It's role of caller?

This is some depense code to check error.

>
>> +		return test_bit(AS_MIGRATABLE, &mapping->flags);
>
> It means some of address_space has migratepage, isolatepage, putbackpage but
> it doesn't set AS_MIGRATABLE? Why do we need it?

This also depense code.
I think depense code should check every case, doesn't it?

>
>> +	return !!mapping;
>> +}
>> +
>>   static inline void mapping_set_exiting(struct address_space *mapping)
>>   {
>>   	set_bit(AS_EXITING, &mapping->flags);
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index fcad832..2e9d635 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -131,8 +131,11 @@ static inline void __putback_balloon_page(struct page *page)
>>   }
>>
>>   /* __isolate_lru_page() counterpart for a ballooned page */
>> -bool balloon_page_isolate(struct page *page)
>> +int balloon_page_isolate(struct page *page)
>>   {
>> +	if (!balloon_page_movable(page))
>> +		return false;
>> +
>>   	/*
>>   	 * Avoid burning cycles with pages that are yet under __free_pages(),
>>   	 * or just got freed under us.
>> @@ -173,8 +176,11 @@ bool balloon_page_isolate(struct page *page)
>>   }
>>
>>   /* putback_lru_page() counterpart for a ballooned page */
>> -void balloon_page_putback(struct page *page)
>> +int balloon_page_putback(struct page *page)
>>   {
>> +	if (!isolated_balloon_page(page))
>> +		return 0;
>> +
>>   	/*
>>   	 * 'lock_page()' stabilizes the page and prevents races against
>>   	 * concurrent isolation threads attempting to re-isolate it.
>> @@ -190,15 +196,20 @@ void balloon_page_putback(struct page *page)
>>   		dump_page(page, "not movable balloon page");
>>   	}
>>   	unlock_page(page);
>> +	return 0;
>>   }
>>
>>   /* move_to_new_page() counterpart for a ballooned page */
>> -int balloon_page_migrate(struct page *newpage,
>> +int balloon_page_migrate(struct address_space *mapping,
>> +			 struct page *newpage,
>>   			 struct page *page, enum migrate_mode mode)
>>   {
>>   	struct balloon_dev_info *balloon = balloon_page_device(page);
>>   	int rc = -EAGAIN;
>>
>> +	if (!isolated_balloon_page(page))
>> +		return 0;
>> +
>>   	/*
>>   	 * Block others from accessing the 'newpage' when we get around to
>>   	 * establishing additional references. We should be the only one
>> @@ -218,4 +229,55 @@ int balloon_page_migrate(struct page *newpage,
>>   	unlock_page(newpage);
>>   	return rc;
>>   }
>> +
>> +/* define the balloon_mapping->a_ops callback to allow balloon page migration */
>> +const struct address_space_operations balloon_aops = {
>> +	.migratepage = balloon_page_migrate,
>> +	.isolatepage = balloon_page_isolate,
>> +	.putbackpage = balloon_page_putback,
>> +};
>> +EXPORT_SYMBOL_GPL(balloon_aops);
>> +
>> +struct address_space *balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
>> +				const struct address_space_operations *a_ops)
>> +{
>> +	struct address_space *mapping;
>> +
>> +	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
>> +	if (!mapping)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	/*
>> +	 * Give a clean 'zeroed' status to all elements of this special
>> +	 * balloon page->mapping struct address_space instance.
>> +	 */
>> +	address_space_init_once(mapping);
>> +
>> +	/*
>> +	 * Set mapping->flags appropriately, to allow balloon pages
>> +	 * ->mapping identification.
>> +	 */
>> +	mapping_set_migratable(mapping);
>> +	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
>> +
>> +	/* balloon's page->mapping->a_ops callback descriptor */
>> +	mapping->a_ops = a_ops;
>> +
>> +	/*
>> +	 * Establish a pointer reference back to the balloon device descriptor
>> +	 * this particular page->mapping will be servicing.
>> +	 * This is used by compaction / migration procedures to identify and
>> +	 * access the balloon device pageset while isolating / migrating pages.
>> +	 *
>> +	 * As some balloon drivers can register multiple balloon devices
>> +	 * for a single guest, this also helps compaction / migration to
>> +	 * properly deal with multiple balloon pagesets, when required.
>> +	 */
>> +	mapping->private_data = b_dev_info;
>> +	b_dev_info->mapping = mapping;
>> +
>> +	return mapping;
>> +}
>> +EXPORT_SYMBOL_GPL(balloon_mapping_alloc);
>> +
>>   #endif /* CONFIG_BALLOON_COMPACTION */
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 8c0d945..9fbcb7b 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -740,12 +740,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>>   		 * Skip any other type of page
>>   		 */
>>   		if (!PageLRU(page)) {
>> -			if (unlikely(balloon_page_movable(page))) {
>> -				if (balloon_page_isolate(page)) {
>> -					/* Successfully isolated */
>> +			if (mapping_migratable(page->mapping))
>
> I see. Do you want to support this feature for only "non-LRU pages"?
> Hmm, your term for functions was too generic so I got confused.
> At least, it needs prefix like "special_xxx" so that we could classify
> regular inode migrate and special driver migrate.

OK. What about "mapping_driver_migratable"?
I will change other names like mapping_set_driver_migratable/mapping_clear_driver_migratable.

>
> Otherwise, we could make logic more general so every address_space
> want to migrate their page has all of migrate functions(ie, migrate,isolate,putback)
> and we support default functions so addresss_space of regular inode will
> have default functions while special driver overrides it by own functions.
> With it, compact/migrate just calls registered function of each subsystem and
> pass many role to them.
>
>

I consider it as the second step.

>> +				if (page->mapping->a_ops->isolatepage(page))
>>   					goto isolate_success;
>> -				}
>> -			}
>>   			continue;
>>   		}
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 85e0426..37cb366 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -71,6 +71,12 @@ int migrate_prep_local(void)
>>   	return 0;
>>   }
>>
>> +static bool isolated_migratable_page(struct page *page)
>> +{
>> +	return page_mapped(page) == 0 &&
>> +		mapping_migratable(page->mapping);
>> +}
>
> Why does we need to check like this?
> Whether isolate was successful or not depends on the driver.
> We cannot expect it with only page_mapped.

I assume that pages of driver without CPU mapping can be migratable.
So I add checking page_mapped zero.

>
>> +
>>   /*
>>    * Put previously isolated pages back onto the appropriate lists
>>    * from where they were once taken off for compaction/migration.
>> @@ -91,9 +97,9 @@ void putback_movable_pages(struct list_head *l)
>>   		}
>>   		list_del(&page->lru);
>>   		dec_zone_page_state(page, NR_ISOLATED_ANON +
>> -				page_is_file_cache(page));
>> -		if (unlikely(isolated_balloon_page(page)))
>> -			balloon_page_putback(page);
>> +				    page_is_file_cache(page));
>> +		if (unlikely(isolated_migratable_page(page)))
>> +			page->mapping->a_ops->putbackpage(page);
>>   		else
>>   			putback_lru_page(page);
>
> As I said, how about having putback_lru_page for page->mapping->a_ops->putbackpage
> for regular inode? With it, we may remove some of branch in migrate/compact.c to
> separate special driver and regular address_space.
> Hope to enhance readability and make more flexible.

I agree.
I'll test this patch enough and then proceed to it.

I do appreciate your feedback.

>
>>   	}
>> @@ -843,15 +849,9 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>   		}
>>   	}
>>
>> -	if (unlikely(isolated_balloon_page(page))) {
>> -		/*
>> -		 * A ballooned page does not need any special attention from
>> -		 * physical to virtual reverse mapping procedures.
>> -		 * Skip any attempt to unmap PTEs or to remap swap cache,
>> -		 * in order to avoid burning cycles at rmap level, and perform
>> -		 * the page migration right away (proteced by page lock).
>> -		 */
>> -		rc = balloon_page_migrate(newpage, page, mode);
>> +	if (unlikely(isolated_migratable_page(page))) {
>> +		rc = page->mapping->a_ops->migratepage(page->mapping,
>> +						       newpage, page, mode);
>>   		goto out_unlock;
>>   	}
>>
>> --
>> 1.7.9.5
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
