Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E72A36B0260
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:16:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d134so48773318pfd.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:16:11 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id 91si2820974ply.312.2017.01.19.00.16.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 00:16:09 -0800 (PST)
Received: from epcas1p3.samsung.com (unknown [182.195.41.47])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OK002XCMPMUQL70@mailout1.samsung.com> for linux-mm@kvack.org;
 Thu, 19 Jan 2017 17:16:06 +0900 (KST)
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
Date: Thu, 19 Jan 2017 03:16:11 -0500
MIME-version: 1.0
In-reply-to: <20170119062158.GB9367@bbox>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com> <20170119062158.GB9367@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 01/19/2017 01:21 AM, Minchan Kim wrote:
> On Wed, Jan 18, 2017 at 10:39:15PM -0500, Chulmin Kim wrote:
>> On 01/18/2017 09:44 PM, Minchan Kim wrote:
>>> Hello Chulmin,
>>>
>>> On Wed, Jan 18, 2017 at 07:13:21PM -0500, Chulmin Kim wrote:
>>>> Hello. Minchan, and all zsmalloc guys.
>>>>
>>>> I have a quick question.
>>>> Is zsmalloc considering memory barrier things correctly?
>>>>
>>>> AFAIK, in ARM64,
>>>> zsmalloc relies on dmb operation in bit_spin_unlock only.
>>>> (It seems that dmb operations in spinlock functions are being prepared,
>>>> but let is be aside as it is not merged yet.)
>>>>
>>>> If I am correct,
>>>> migrating a page in a zspage filled with free objs
>>>> may cause the corruption cause bit_spin_unlock will not be executed at all.
>>>>
>>>> I am not sure this is enough memory barrier for zsmalloc operations.
>>>>
>>>> Can you enlighten me?
>>>
>>> Do you mean bit_spin_unlock is broken or zsmalloc locking scheme broken?
>>> Could you please describe what you are concerning in detail?
>>> It would be very helpful if you say it with a example!
>>
>> Sorry for ambiguous expressions. :)
>>
>> Recently,
>> I found multiple zsmalloc corruption cases which have garbage idx values in
>> in zspage->freeobj. (not ffffffff (-1) value.)
>>
>> Honestly, I have no clue yet.
>>
>> I suspect the case when zspage migrate a zs sub page filled with free
>> objects (so that never calls unpin_tag() which has memory barrier).
>>
>>
>> Assume the page (zs subpage) being migrated has no allocated zs object.
>>
>> S : zs subpage
>> D : free page
>>
>>
>> CPU A : zs_page_migrate()		CPU B : zs_malloc()
>> ---------------------			-----------------------------
>>
>>
>> migrate_write_lock()
>> spin_lock()
>>
>> memcpy(D, S, PAGE_SIZE)   -> (1)
>> replace_sub_page()
>>
>> putback_zspage()
>> spin_unlock()
>> migrate_write_unlock()
>> 					
>> 					spin_lock()
>> 					obj_malloc()
>> 					--> (2-a) allocate obj in D
>> 					--> (2-b) set freeobj using
>>      						the first 8 bytes of
>>  						the allocated obj
>> 					record_obj()
>> 					spin_unlock
>>
>>
>>
>> I think the locking has no problem, but memory ordering.
>> I doubt whether (2-b) in CPU B really loads the data stored by (1).
>>
>> If it doesn't, set_freeobj in (2-b) will corrupt zspage->freeobj.
>> After then, we will see corrupted object sooner or later.
>
> Thanks for the example.
> When I cannot understand what you are pointing out.
>
> In above example, two CPU use same spin_lock of a class so store op
> by memcpy in the critical section should be visible by CPU B.
>
> Am I missing your point?


No, you are right.
I just pointed it prematurely after only checking that arm64's spinlock 
seems not issue "dmb" operation explicitly.
I am the one missed the basics.

Anyway, I will let you know the situation when it gets more clear.

THanks!






>
>>
>>
>> According to the below link,
>> (https://patchwork.kernel.org/patch/9313493/)
>> spin lock in a specific arch (arm64 maybe) seems not guaranteeing memory
>> ordering.
>
> IMHO, it's not related the this issue.
> It should be matter in when data is updated without formal locking scheme.
>
> Thanks.
>
>>
>> ===
>> +/*
>> + * Accesses appearing in program order before a spin_lock() operation
>> + * can be reordered with accesses inside the critical section, by virtue
>> + * of arch_spin_lock being constructed using acquire semantics.
>> + *
>> + * In cases where this is problematic (e.g. try_to_wake_up), an
>> + * smp_mb__before_spinlock() can restore the required ordering.
>> + */
>> +#define smp_mb__before_spinlock()	smp_mb()
>> ===
>>
>>
>>
>> THanks.
>> CHulmin Kim
>>
>>
>>
>>
>>
>>>
>>> Thanks.
>>>
>>>>
>>>>
>>>> THanks!
>>>> CHulmin KIm
>>>>
>>>>
>>>>
>>>> On 05/31/2016 07:21 PM, Minchan Kim wrote:
>>>>> This patch introduces run-time migration feature for zspage.
>>>>>
>>>>> For migration, VM uses page.lru field so it would be better to not use
>>>>> page.next field which is unified with page.lru for own purpose.
>>>>> For that, firstly, we can get first object offset of the page via
>>>>> runtime calculation instead of using page.index so we can use
>>>>> page.index as link for page chaining instead of page.next.
>>>>> 	
>>>>> In case of huge object, it stores handle to page.index instead of
>>>>> next link of page chaining because huge object doesn't need to next
>>>>> link for page chaining. So get_next_page need to identify huge
>>>>> object to return NULL. For it, this patch uses PG_owner_priv_1 flag
>>>>> of the page flag.
>>>>>
>>>>> For migration, it supports three functions
>>>>>
>>>>> * zs_page_isolate
>>>>>
>>>>> It isolates a zspage which includes a subpage VM want to migrate
>>>> >from class so anyone cannot allocate new object from the zspage.
>>>>>
>>>>> We could try to isolate a zspage by the number of subpage so
>>>>> subsequent isolation trial of other subpage of the zpsage shouldn't
>>>>> fail. For that, we introduce zspage.isolated count. With that,
>>>>> zs_page_isolate can know whether zspage is already isolated or not
>>>>> for migration so if it is isolated for migration, subsequent
>>>>> isolation trial can be successful without trying further isolation.
>>>>>
>>>>> * zs_page_migrate
>>>>>
>>>>> First of all, it holds write-side zspage->lock to prevent migrate other
>>>>> subpage in zspage. Then, lock all objects in the page VM want to migrate.
>>>>> The reason we should lock all objects in the page is due to race between
>>>>> zs_map_object and zs_page_migrate.
>>>>>
>>>>> zs_map_object				zs_page_migrate
>>>>>
>>>>> pin_tag(handle)
>>>>> obj = handle_to_obj(handle)
>>>>> obj_to_location(obj, &page, &obj_idx);
>>>>>
>>>>> 					write_lock(&zspage->lock)
>>>>> 					if (!trypin_tag(handle))
>>>>> 						goto unpin_object
>>>>>
>>>>> zspage = get_zspage(page);
>>>>> read_lock(&zspage->lock);
>>>>>
>>>>> If zs_page_migrate doesn't do trypin_tag, zs_map_object's page can
>>>>> be stale by migration so it goes crash.
>>>>>
>>>>> If it locks all of objects successfully, it copies content from
>>>>> old page to new one, finally, create new zspage chain with new page.
>>>>> And if it's last isolated subpage in the zspage, put the zspage back
>>>>> to class.
>>>>>
>>>>> * zs_page_putback
>>>>>
>>>>> It returns isolated zspage to right fullness_group list if it fails to
>>>>> migrate a page. If it find a zspage is ZS_EMPTY, it queues zspage
>>>>> freeing to workqueue. See below about async zspage freeing.
>>>>>
>>>>> This patch introduces asynchronous zspage free. The reason to need it
>>>>> is we need page_lock to clear PG_movable but unfortunately,
>>>>> zs_free path should be atomic so the apporach is try to grab page_lock.
>>>>> If it got page_lock of all of pages successfully, it can free zspage
>>>>> immediately. Otherwise, it queues free request and free zspage via
>>>>> workqueue in process context.
>>>>>
>>>>> If zs_free finds the zspage is isolated when it try to free zspage,
>>>>> it delays the freeing until zs_page_putback finds it so it will free
>>>>> free the zspage finally.
>>>>>
>>>>> In this patch, we expand fullness_list from ZS_EMPTY to ZS_FULL.
>>>>> First of all, it will use ZS_EMPTY list for delay freeing.
>>>>> And with adding ZS_FULL list, it makes to identify whether zspage is
>>>>> isolated or not via list_empty(&zspage->list) test.
>>>>>
>>>>> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>>>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>>>> ---
>>>>> include/uapi/linux/magic.h |   1 +
>>>>> mm/zsmalloc.c              | 793 ++++++++++++++++++++++++++++++++++++++-------
>>>>> 2 files changed, 672 insertions(+), 122 deletions(-)
>>>>>
>>>>> diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
>>>>> index d829ce63529d..e398beac67b8 100644
>>>>> --- a/include/uapi/linux/magic.h
>>>>> +++ b/include/uapi/linux/magic.h
>>>>> @@ -81,5 +81,6 @@
>>>>> /* Since UDF 2.01 is ISO 13346 based... */
>>>>> #define UDF_SUPER_MAGIC		0x15013346
>>>>> #define BALLOON_KVM_MAGIC	0x13661366
>>>>> +#define ZSMALLOC_MAGIC		0x58295829
>>>>>
>>>>> #endif /* __LINUX_MAGIC_H__ */
>>>>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>>>>> index c6fb543cfb98..a80100db16d6 100644
>>>>> --- a/mm/zsmalloc.c
>>>>> +++ b/mm/zsmalloc.c
>>>>> @@ -17,14 +17,14 @@
>>>>> *
>>>>> * Usage of struct page fields:
>>>>> *	page->private: points to zspage
>>>>> - *	page->index: offset of the first object starting in this page.
>>>>> - *		For the first page, this is always 0, so we use this field
>>>>> - *		to store handle for huge object.
>>>>> - *	page->next: links together all component pages of a zspage
>>>>> + *	page->freelist(index): links together all component pages of a zspage
>>>>> + *		For the huge page, this is always 0, so we use this field
>>>>> + *		to store handle.
>>>>> *
>>>>> * Usage of struct page flags:
>>>>> *	PG_private: identifies the first component page
>>>>> *	PG_private2: identifies the last component page
>>>>> + *	PG_owner_priv_1: indentifies the huge component page
>>>>> *
>>>>> */
>>>>>
>>>>> @@ -49,6 +49,11 @@
>>>>> #include <linux/debugfs.h>
>>>>> #include <linux/zsmalloc.h>
>>>>> #include <linux/zpool.h>
>>>>> +#include <linux/mount.h>
>>>>> +#include <linux/compaction.h>
>>>>> +#include <linux/pagemap.h>
>>>>> +
>>>>> +#define ZSPAGE_MAGIC	0x58
>>>>>
>>>>> /*
>>>>> * This must be power of 2 and greater than of equal to sizeof(link_free).
>>>>> @@ -136,25 +141,23 @@
>>>>> * We do not maintain any list for completely empty or full pages
>>>>> */
>>>>> enum fullness_group {
>>>>> -	ZS_ALMOST_FULL,
>>>>> -	ZS_ALMOST_EMPTY,
>>>>> 	ZS_EMPTY,
>>>>> -	ZS_FULL
>>>>> +	ZS_ALMOST_EMPTY,
>>>>> +	ZS_ALMOST_FULL,
>>>>> +	ZS_FULL,
>>>>> +	NR_ZS_FULLNESS,
>>>>> };
>>>>>
>>>>> enum zs_stat_type {
>>>>> +	CLASS_EMPTY,
>>>>> +	CLASS_ALMOST_EMPTY,
>>>>> +	CLASS_ALMOST_FULL,
>>>>> +	CLASS_FULL,
>>>>> 	OBJ_ALLOCATED,
>>>>> 	OBJ_USED,
>>>>> -	CLASS_ALMOST_FULL,
>>>>> -	CLASS_ALMOST_EMPTY,
>>>>> +	NR_ZS_STAT_TYPE,
>>>>> };
>>>>>
>>>>> -#ifdef CONFIG_ZSMALLOC_STAT
>>>>> -#define NR_ZS_STAT_TYPE	(CLASS_ALMOST_EMPTY + 1)
>>>>> -#else
>>>>> -#define NR_ZS_STAT_TYPE	(OBJ_USED + 1)
>>>>> -#endif
>>>>> -
>>>>> struct zs_size_stat {
>>>>> 	unsigned long objs[NR_ZS_STAT_TYPE];
>>>>> };
>>>>> @@ -163,6 +166,10 @@ struct zs_size_stat {
>>>>> static struct dentry *zs_stat_root;
>>>>> #endif
>>>>>
>>>>> +#ifdef CONFIG_COMPACTION
>>>>> +static struct vfsmount *zsmalloc_mnt;
>>>>> +#endif
>>>>> +
>>>>> /*
>>>>> * number of size_classes
>>>>> */
>>>>> @@ -186,23 +193,36 @@ static const int fullness_threshold_frac = 4;
>>>>>
>>>>> struct size_class {
>>>>> 	spinlock_t lock;
>>>>> -	struct list_head fullness_list[2];
>>>>> +	struct list_head fullness_list[NR_ZS_FULLNESS];
>>>>> 	/*
>>>>> 	 * Size of objects stored in this class. Must be multiple
>>>>> 	 * of ZS_ALIGN.
>>>>> 	 */
>>>>> 	int size;
>>>>> 	int objs_per_zspage;
>>>>> -	unsigned int index;
>>>>> -
>>>>> -	struct zs_size_stat stats;
>>>>> -
>>>>> 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
>>>>> 	int pages_per_zspage;
>>>>> -	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
>>>>> -	bool huge;
>>>>> +
>>>>> +	unsigned int index;
>>>>> +	struct zs_size_stat stats;
>>>>> };
>>>>>
>>>>> +/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
>>>>> +static void SetPageHugeObject(struct page *page)
>>>>> +{
>>>>> +	SetPageOwnerPriv1(page);
>>>>> +}
>>>>> +
>>>>> +static void ClearPageHugeObject(struct page *page)
>>>>> +{
>>>>> +	ClearPageOwnerPriv1(page);
>>>>> +}
>>>>> +
>>>>> +static int PageHugeObject(struct page *page)
>>>>> +{
>>>>> +	return PageOwnerPriv1(page);
>>>>> +}
>>>>> +
>>>>> /*
>>>>> * Placed within free objects to form a singly linked list.
>>>>> * For every zspage, zspage->freeobj gives head of this list.
>>>>> @@ -244,6 +264,10 @@ struct zs_pool {
>>>>> #ifdef CONFIG_ZSMALLOC_STAT
>>>>> 	struct dentry *stat_dentry;
>>>>> #endif
>>>>> +#ifdef CONFIG_COMPACTION
>>>>> +	struct inode *inode;
>>>>> +	struct work_struct free_work;
>>>>> +#endif
>>>>> };
>>>>>
>>>>> /*
>>>>> @@ -252,16 +276,23 @@ struct zs_pool {
>>>>> */
>>>>> #define FULLNESS_BITS	2
>>>>> #define CLASS_BITS	8
>>>>> +#define ISOLATED_BITS	3
>>>>> +#define MAGIC_VAL_BITS	8
>>>>>
>>>>> struct zspage {
>>>>> 	struct {
>>>>> 		unsigned int fullness:FULLNESS_BITS;
>>>>> 		unsigned int class:CLASS_BITS;
>>>>> +		unsigned int isolated:ISOLATED_BITS;
>>>>> +		unsigned int magic:MAGIC_VAL_BITS;
>>>>> 	};
>>>>> 	unsigned int inuse;
>>>>> 	unsigned int freeobj;
>>>>> 	struct page *first_page;
>>>>> 	struct list_head list; /* fullness list */
>>>>> +#ifdef CONFIG_COMPACTION
>>>>> +	rwlock_t lock;
>>>>> +#endif
>>>>> };
>>>>>
>>>>> struct mapping_area {
>>>>> @@ -274,6 +305,28 @@ struct mapping_area {
>>>>> 	enum zs_mapmode vm_mm; /* mapping mode */
>>>>> };
>>>>>
>>>>> +#ifdef CONFIG_COMPACTION
>>>>> +static int zs_register_migration(struct zs_pool *pool);
>>>>> +static void zs_unregister_migration(struct zs_pool *pool);
>>>>> +static void migrate_lock_init(struct zspage *zspage);
>>>>> +static void migrate_read_lock(struct zspage *zspage);
>>>>> +static void migrate_read_unlock(struct zspage *zspage);
>>>>> +static void kick_deferred_free(struct zs_pool *pool);
>>>>> +static void init_deferred_free(struct zs_pool *pool);
>>>>> +static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage);
>>>>> +#else
>>>>> +static int zsmalloc_mount(void) { return 0; }
>>>>> +static void zsmalloc_unmount(void) {}
>>>>> +static int zs_register_migration(struct zs_pool *pool) { return 0; }
>>>>> +static void zs_unregister_migration(struct zs_pool *pool) {}
>>>>> +static void migrate_lock_init(struct zspage *zspage) {}
>>>>> +static void migrate_read_lock(struct zspage *zspage) {}
>>>>> +static void migrate_read_unlock(struct zspage *zspage) {}
>>>>> +static void kick_deferred_free(struct zs_pool *pool) {}
>>>>> +static void init_deferred_free(struct zs_pool *pool) {}
>>>>> +static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage) {}
>>>>> +#endif
>>>>> +
>>>>> static int create_cache(struct zs_pool *pool)
>>>>> {
>>>>> 	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
>>>>> @@ -301,7 +354,7 @@ static void destroy_cache(struct zs_pool *pool)
>>>>> static unsigned long cache_alloc_handle(struct zs_pool *pool, gfp_t gfp)
>>>>> {
>>>>> 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
>>>>> -			gfp & ~__GFP_HIGHMEM);
>>>>> +			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
>>>>> }
>>>>>
>>>>> static void cache_free_handle(struct zs_pool *pool, unsigned long handle)
>>>>> @@ -311,7 +364,8 @@ static void cache_free_handle(struct zs_pool *pool, unsigned long handle)
>>>>>
>>>>> static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
>>>>> {
>>>>> -	return kmem_cache_alloc(pool->zspage_cachep, flags & ~__GFP_HIGHMEM);
>>>>> +	return kmem_cache_alloc(pool->zspage_cachep,
>>>>> +			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
>>>>> };
>>>>>
>>>>> static void cache_free_zspage(struct zs_pool *pool, struct zspage *zspage)
>>>>> @@ -421,11 +475,17 @@ static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
>>>>> /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
>>>>> static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
>>>>>
>>>>> +static bool is_zspage_isolated(struct zspage *zspage)
>>>>> +{
>>>>> +	return zspage->isolated;
>>>>> +}
>>>>> +
>>>>> static int is_first_page(struct page *page)
>>>>> {
>>>>> 	return PagePrivate(page);
>>>>> }
>>>>>
>>>>> +/* Protected by class->lock */
>>>>> static inline int get_zspage_inuse(struct zspage *zspage)
>>>>> {
>>>>> 	return zspage->inuse;
>>>>> @@ -441,20 +501,12 @@ static inline void mod_zspage_inuse(struct zspage *zspage, int val)
>>>>> 	zspage->inuse += val;
>>>>> }
>>>>>
>>>>> -static inline int get_first_obj_offset(struct page *page)
>>>>> +static inline struct page *get_first_page(struct zspage *zspage)
>>>>> {
>>>>> -	if (is_first_page(page))
>>>>> -		return 0;
>>>>> +	struct page *first_page = zspage->first_page;
>>>>>
>>>>> -	return page->index;
>>>>> -}
>>>>> -
>>>>> -static inline void set_first_obj_offset(struct page *page, int offset)
>>>>> -{
>>>>> -	if (is_first_page(page))
>>>>> -		return;
>>>>> -
>>>>> -	page->index = offset;
>>>>> +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>>>>> +	return first_page;
>>>>> }
>>>>>
>>>>> static inline unsigned int get_freeobj(struct zspage *zspage)
>>>>> @@ -471,6 +523,8 @@ static void get_zspage_mapping(struct zspage *zspage,
>>>>> 				unsigned int *class_idx,
>>>>> 				enum fullness_group *fullness)
>>>>> {
>>>>> +	VM_BUG_ON(zspage->magic != ZSPAGE_MAGIC);
>>>>> +
>>>>> 	*fullness = zspage->fullness;
>>>>> 	*class_idx = zspage->class;
>>>>> }
>>>>> @@ -504,23 +558,19 @@ static int get_size_class_index(int size)
>>>>> static inline void zs_stat_inc(struct size_class *class,
>>>>> 				enum zs_stat_type type, unsigned long cnt)
>>>>> {
>>>>> -	if (type < NR_ZS_STAT_TYPE)
>>>>> -		class->stats.objs[type] += cnt;
>>>>> +	class->stats.objs[type] += cnt;
>>>>> }
>>>>>
>>>>> static inline void zs_stat_dec(struct size_class *class,
>>>>> 				enum zs_stat_type type, unsigned long cnt)
>>>>> {
>>>>> -	if (type < NR_ZS_STAT_TYPE)
>>>>> -		class->stats.objs[type] -= cnt;
>>>>> +	class->stats.objs[type] -= cnt;
>>>>> }
>>>>>
>>>>> static inline unsigned long zs_stat_get(struct size_class *class,
>>>>> 				enum zs_stat_type type)
>>>>> {
>>>>> -	if (type < NR_ZS_STAT_TYPE)
>>>>> -		return class->stats.objs[type];
>>>>> -	return 0;
>>>>> +	return class->stats.objs[type];
>>>>> }
>>>>>
>>>>> #ifdef CONFIG_ZSMALLOC_STAT
>>>>> @@ -664,6 +714,7 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
>>>>> }
>>>>> #endif
>>>>>
>>>>> +
>>>>> /*
>>>>> * For each size class, zspages are divided into different groups
>>>>> * depending on how "full" they are. This was done so that we could
>>>>> @@ -704,15 +755,9 @@ static void insert_zspage(struct size_class *class,
>>>>> {
>>>>> 	struct zspage *head;
>>>>>
>>>>> -	if (fullness >= ZS_EMPTY)
>>>>> -		return;
>>>>> -
>>>>> +	zs_stat_inc(class, fullness, 1);
>>>>> 	head = list_first_entry_or_null(&class->fullness_list[fullness],
>>>>> 					struct zspage, list);
>>>>> -
>>>>> -	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
>>>>> -			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
>>>>> -
>>>>> 	/*
>>>>> 	 * We want to see more ZS_FULL pages and less almost empty/full.
>>>>> 	 * Put pages with higher ->inuse first.
>>>>> @@ -734,14 +779,11 @@ static void remove_zspage(struct size_class *class,
>>>>> 				struct zspage *zspage,
>>>>> 				enum fullness_group fullness)
>>>>> {
>>>>> -	if (fullness >= ZS_EMPTY)
>>>>> -		return;
>>>>> -
>>>>> 	VM_BUG_ON(list_empty(&class->fullness_list[fullness]));
>>>>> +	VM_BUG_ON(is_zspage_isolated(zspage));
>>>>>
>>>>> 	list_del_init(&zspage->list);
>>>>> -	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
>>>>> -			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
>>>>> +	zs_stat_dec(class, fullness, 1);
>>>>> }
>>>>>
>>>>> /*
>>>>> @@ -764,8 +806,11 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
>>>>> 	if (newfg == currfg)
>>>>> 		goto out;
>>>>>
>>>>> -	remove_zspage(class, zspage, currfg);
>>>>> -	insert_zspage(class, zspage, newfg);
>>>>> +	if (!is_zspage_isolated(zspage)) {
>>>>> +		remove_zspage(class, zspage, currfg);
>>>>> +		insert_zspage(class, zspage, newfg);
>>>>> +	}
>>>>> +
>>>>> 	set_zspage_mapping(zspage, class_idx, newfg);
>>>>>
>>>>> out:
>>>>> @@ -808,19 +853,45 @@ static int get_pages_per_zspage(int class_size)
>>>>> 	return max_usedpc_order;
>>>>> }
>>>>>
>>>>> -static struct page *get_first_page(struct zspage *zspage)
>>>>> +static struct zspage *get_zspage(struct page *page)
>>>>> {
>>>>> -	return zspage->first_page;
>>>>> +	struct zspage *zspage = (struct zspage *)page->private;
>>>>> +
>>>>> +	VM_BUG_ON(zspage->magic != ZSPAGE_MAGIC);
>>>>> +	return zspage;
>>>>> }
>>>>>
>>>>> -static struct zspage *get_zspage(struct page *page)
>>>>> +static struct page *get_next_page(struct page *page)
>>>>> {
>>>>> -	return (struct zspage *)page->private;
>>>>> +	if (unlikely(PageHugeObject(page)))
>>>>> +		return NULL;
>>>>> +
>>>>> +	return page->freelist;
>>>>> }
>>>>>
>>>>> -static struct page *get_next_page(struct page *page)
>>>>> +/* Get byte offset of first object in the @page */
>>>>> +static int get_first_obj_offset(struct size_class *class,
>>>>> +				struct page *first_page, struct page *page)
>>>>> {
>>>>> -	return page->next;
>>>>> +	int pos;
>>>>> +	int page_idx = 0;
>>>>> +	int ofs = 0;
>>>>> +	struct page *cursor = first_page;
>>>>> +
>>>>> +	if (first_page == page)
>>>>> +		goto out;
>>>>> +
>>>>> +	while (page != cursor) {
>>>>> +		page_idx++;
>>>>> +		cursor = get_next_page(cursor);
>>>>> +	}
>>>>> +
>>>>> +	pos = class->objs_per_zspage * class->size *
>>>>> +		page_idx / class->pages_per_zspage;
>>>>> +
>>>>> +	ofs = (pos + class->size) % PAGE_SIZE;
>>>>> +out:
>>>>> +	return ofs;
>>>>> }
>>>>>
>>>>> /**
>>>>> @@ -857,16 +928,20 @@ static unsigned long handle_to_obj(unsigned long handle)
>>>>> 	return *(unsigned long *)handle;
>>>>> }
>>>>>
>>>>> -static unsigned long obj_to_head(struct size_class *class, struct page *page,
>>>>> -			void *obj)
>>>>> +static unsigned long obj_to_head(struct page *page, void *obj)
>>>>> {
>>>>> -	if (class->huge) {
>>>>> +	if (unlikely(PageHugeObject(page))) {
>>>>> 		VM_BUG_ON_PAGE(!is_first_page(page), page);
>>>>> 		return page->index;
>>>>> 	} else
>>>>> 		return *(unsigned long *)obj;
>>>>> }
>>>>>
>>>>> +static inline int testpin_tag(unsigned long handle)
>>>>> +{
>>>>> +	return bit_spin_is_locked(HANDLE_PIN_BIT, (unsigned long *)handle);
>>>>> +}
>>>>> +
>>>>> static inline int trypin_tag(unsigned long handle)
>>>>> {
>>>>> 	return bit_spin_trylock(HANDLE_PIN_BIT, (unsigned long *)handle);
>>>>> @@ -884,27 +959,93 @@ static void unpin_tag(unsigned long handle)
>>>>>
>>>>> static void reset_page(struct page *page)
>>>>> {
>>>>> +	__ClearPageMovable(page);
>>>>> 	clear_bit(PG_private, &page->flags);
>>>>> 	clear_bit(PG_private_2, &page->flags);
>>>>> 	set_page_private(page, 0);
>>>>> -	page->index = 0;
>>>>> +	ClearPageHugeObject(page);
>>>>> +	page->freelist = NULL;
>>>>> }
>>>>>
>>>>> -static void free_zspage(struct zs_pool *pool, struct zspage *zspage)
>>>>> +/*
>>>>> + * To prevent zspage destroy during migration, zspage freeing should
>>>>> + * hold locks of all pages in the zspage.
>>>>> + */
>>>>> +void lock_zspage(struct zspage *zspage)
>>>>> +{
>>>>> +	struct page *page = get_first_page(zspage);
>>>>> +
>>>>> +	do {
>>>>> +		lock_page(page);
>>>>> +	} while ((page = get_next_page(page)) != NULL);
>>>>> +}
>>>>> +
>>>>> +int trylock_zspage(struct zspage *zspage)
>>>>> +{
>>>>> +	struct page *cursor, *fail;
>>>>> +
>>>>> +	for (cursor = get_first_page(zspage); cursor != NULL; cursor =
>>>>> +					get_next_page(cursor)) {
>>>>> +		if (!trylock_page(cursor)) {
>>>>> +			fail = cursor;
>>>>> +			goto unlock;
>>>>> +		}
>>>>> +	}
>>>>> +
>>>>> +	return 1;
>>>>> +unlock:
>>>>> +	for (cursor = get_first_page(zspage); cursor != fail; cursor =
>>>>> +					get_next_page(cursor))
>>>>> +		unlock_page(cursor);
>>>>> +
>>>>> +	return 0;
>>>>> +}
>>>>> +
>>>>> +static void __free_zspage(struct zs_pool *pool, struct size_class *class,
>>>>> +				struct zspage *zspage)
>>>>> {
>>>>> 	struct page *page, *next;
>>>>> +	enum fullness_group fg;
>>>>> +	unsigned int class_idx;
>>>>> +
>>>>> +	get_zspage_mapping(zspage, &class_idx, &fg);
>>>>> +
>>>>> +	assert_spin_locked(&class->lock);
>>>>>
>>>>> 	VM_BUG_ON(get_zspage_inuse(zspage));
>>>>> +	VM_BUG_ON(fg != ZS_EMPTY);
>>>>>
>>>>> -	next = page = zspage->first_page;
>>>>> +	next = page = get_first_page(zspage);
>>>>> 	do {
>>>>> -		next = page->next;
>>>>> +		VM_BUG_ON_PAGE(!PageLocked(page), page);
>>>>> +		next = get_next_page(page);
>>>>> 		reset_page(page);
>>>>> +		unlock_page(page);
>>>>> 		put_page(page);
>>>>> 		page = next;
>>>>> 	} while (page != NULL);
>>>>>
>>>>> 	cache_free_zspage(pool, zspage);
>>>>> +
>>>>> +	zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>>>>> +			class->size, class->pages_per_zspage));
>>>>> +	atomic_long_sub(class->pages_per_zspage,
>>>>> +					&pool->pages_allocated);
>>>>> +}
>>>>> +
>>>>> +static void free_zspage(struct zs_pool *pool, struct size_class *class,
>>>>> +				struct zspage *zspage)
>>>>> +{
>>>>> +	VM_BUG_ON(get_zspage_inuse(zspage));
>>>>> +	VM_BUG_ON(list_empty(&zspage->list));
>>>>> +
>>>>> +	if (!trylock_zspage(zspage)) {
>>>>> +		kick_deferred_free(pool);
>>>>> +		return;
>>>>> +	}
>>>>> +
>>>>> +	remove_zspage(class, zspage, ZS_EMPTY);
>>>>> +	__free_zspage(pool, class, zspage);
>>>>> }
>>>>>
>>>>> /* Initialize a newly allocated zspage */
>>>>> @@ -912,15 +1053,13 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
>>>>> {
>>>>> 	unsigned int freeobj = 1;
>>>>> 	unsigned long off = 0;
>>>>> -	struct page *page = zspage->first_page;
>>>>> +	struct page *page = get_first_page(zspage);
>>>>>
>>>>> 	while (page) {
>>>>> 		struct page *next_page;
>>>>> 		struct link_free *link;
>>>>> 		void *vaddr;
>>>>>
>>>>> -		set_first_obj_offset(page, off);
>>>>> -
>>>>> 		vaddr = kmap_atomic(page);
>>>>> 		link = (struct link_free *)vaddr + off / sizeof(*link);
>>>>>
>>>>> @@ -952,16 +1091,17 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
>>>>> 	set_freeobj(zspage, 0);
>>>>> }
>>>>>
>>>>> -static void create_page_chain(struct zspage *zspage, struct page *pages[],
>>>>> -				int nr_pages)
>>>>> +static void create_page_chain(struct size_class *class, struct zspage *zspage,
>>>>> +				struct page *pages[])
>>>>> {
>>>>> 	int i;
>>>>> 	struct page *page;
>>>>> 	struct page *prev_page = NULL;
>>>>> +	int nr_pages = class->pages_per_zspage;
>>>>>
>>>>> 	/*
>>>>> 	 * Allocate individual pages and link them together as:
>>>>> -	 * 1. all pages are linked together using page->next
>>>>> +	 * 1. all pages are linked together using page->freelist
>>>>> 	 * 2. each sub-page point to zspage using page->private
>>>>> 	 *
>>>>> 	 * we set PG_private to identify the first page (i.e. no other sub-page
>>>>> @@ -970,16 +1110,18 @@ static void create_page_chain(struct zspage *zspage, struct page *pages[],
>>>>> 	for (i = 0; i < nr_pages; i++) {
>>>>> 		page = pages[i];
>>>>> 		set_page_private(page, (unsigned long)zspage);
>>>>> +		page->freelist = NULL;
>>>>> 		if (i == 0) {
>>>>> 			zspage->first_page = page;
>>>>> 			SetPagePrivate(page);
>>>>> +			if (unlikely(class->objs_per_zspage == 1 &&
>>>>> +					class->pages_per_zspage == 1))
>>>>> +				SetPageHugeObject(page);
>>>>> 		} else {
>>>>> -			prev_page->next = page;
>>>>> +			prev_page->freelist = page;
>>>>> 		}
>>>>> -		if (i == nr_pages - 1) {
>>>>> +		if (i == nr_pages - 1)
>>>>> 			SetPagePrivate2(page);
>>>>> -			page->next = NULL;
>>>>> -		}
>>>>> 		prev_page = page;
>>>>> 	}
>>>>> }
>>>>> @@ -999,6 +1141,8 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
>>>>> 		return NULL;
>>>>>
>>>>> 	memset(zspage, 0, sizeof(struct zspage));
>>>>> +	zspage->magic = ZSPAGE_MAGIC;
>>>>> +	migrate_lock_init(zspage);
>>>>>
>>>>> 	for (i = 0; i < class->pages_per_zspage; i++) {
>>>>> 		struct page *page;
>>>>> @@ -1013,7 +1157,7 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
>>>>> 		pages[i] = page;
>>>>> 	}
>>>>>
>>>>> -	create_page_chain(zspage, pages, class->pages_per_zspage);
>>>>> +	create_page_chain(class, zspage, pages);
>>>>> 	init_zspage(class, zspage);
>>>>>
>>>>> 	return zspage;
>>>>> @@ -1024,7 +1168,7 @@ static struct zspage *find_get_zspage(struct size_class *class)
>>>>> 	int i;
>>>>> 	struct zspage *zspage;
>>>>>
>>>>> -	for (i = ZS_ALMOST_FULL; i <= ZS_ALMOST_EMPTY; i++) {
>>>>> +	for (i = ZS_ALMOST_FULL; i >= ZS_EMPTY; i--) {
>>>>> 		zspage = list_first_entry_or_null(&class->fullness_list[i],
>>>>> 				struct zspage, list);
>>>>> 		if (zspage)
>>>>> @@ -1289,6 +1433,10 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>>>>> 	obj = handle_to_obj(handle);
>>>>> 	obj_to_location(obj, &page, &obj_idx);
>>>>> 	zspage = get_zspage(page);
>>>>> +
>>>>> +	/* migration cannot move any subpage in this zspage */
>>>>> +	migrate_read_lock(zspage);
>>>>> +
>>>>> 	get_zspage_mapping(zspage, &class_idx, &fg);
>>>>> 	class = pool->size_class[class_idx];
>>>>> 	off = (class->size * obj_idx) & ~PAGE_MASK;
>>>>> @@ -1309,7 +1457,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>>>>>
>>>>> 	ret = __zs_map_object(area, pages, off, class->size);
>>>>> out:
>>>>> -	if (!class->huge)
>>>>> +	if (likely(!PageHugeObject(page)))
>>>>> 		ret += ZS_HANDLE_SIZE;
>>>>>
>>>>> 	return ret;
>>>>> @@ -1348,6 +1496,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>>>>> 		__zs_unmap_object(area, pages, off, class->size);
>>>>> 	}
>>>>> 	put_cpu_var(zs_map_area);
>>>>> +
>>>>> +	migrate_read_unlock(zspage);
>>>>> 	unpin_tag(handle);
>>>>> }
>>>>> EXPORT_SYMBOL_GPL(zs_unmap_object);
>>>>> @@ -1377,7 +1527,7 @@ static unsigned long obj_malloc(struct size_class *class,
>>>>> 	vaddr = kmap_atomic(m_page);
>>>>> 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
>>>>> 	set_freeobj(zspage, link->next >> OBJ_ALLOCATED_TAG);
>>>>> -	if (!class->huge)
>>>>> +	if (likely(!PageHugeObject(m_page)))
>>>>> 		/* record handle in the header of allocated chunk */
>>>>> 		link->handle = handle;
>>>>> 	else
>>>>> @@ -1407,6 +1557,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t gfp)
>>>>> {
>>>>> 	unsigned long handle, obj;
>>>>> 	struct size_class *class;
>>>>> +	enum fullness_group newfg;
>>>>> 	struct zspage *zspage;
>>>>>
>>>>> 	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
>>>>> @@ -1422,28 +1573,37 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t gfp)
>>>>>
>>>>> 	spin_lock(&class->lock);
>>>>> 	zspage = find_get_zspage(class);
>>>>> -
>>>>> -	if (!zspage) {
>>>>> +	if (likely(zspage)) {
>>>>> +		obj = obj_malloc(class, zspage, handle);
>>>>> +		/* Now move the zspage to another fullness group, if required */
>>>>> +		fix_fullness_group(class, zspage);
>>>>> +		record_obj(handle, obj);
>>>>> 		spin_unlock(&class->lock);
>>>>> -		zspage = alloc_zspage(pool, class, gfp);
>>>>> -		if (unlikely(!zspage)) {
>>>>> -			cache_free_handle(pool, handle);
>>>>> -			return 0;
>>>>> -		}
>>>>>
>>>>> -		set_zspage_mapping(zspage, class->index, ZS_EMPTY);
>>>>> -		atomic_long_add(class->pages_per_zspage,
>>>>> -					&pool->pages_allocated);
>>>>> +		return handle;
>>>>> +	}
>>>>>
>>>>> -		spin_lock(&class->lock);
>>>>> -		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>>>>> -				class->size, class->pages_per_zspage));
>>>>> +	spin_unlock(&class->lock);
>>>>> +
>>>>> +	zspage = alloc_zspage(pool, class, gfp);
>>>>> +	if (!zspage) {
>>>>> +		cache_free_handle(pool, handle);
>>>>> +		return 0;
>>>>> 	}
>>>>>
>>>>> +	spin_lock(&class->lock);
>>>>> 	obj = obj_malloc(class, zspage, handle);
>>>>> -	/* Now move the zspage to another fullness group, if required */
>>>>> -	fix_fullness_group(class, zspage);
>>>>> +	newfg = get_fullness_group(class, zspage);
>>>>> +	insert_zspage(class, zspage, newfg);
>>>>> +	set_zspage_mapping(zspage, class->index, newfg);
>>>>> 	record_obj(handle, obj);
>>>>> +	atomic_long_add(class->pages_per_zspage,
>>>>> +				&pool->pages_allocated);
>>>>> +	zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>>>>> +			class->size, class->pages_per_zspage));
>>>>> +
>>>>> +	/* We completely set up zspage so mark them as movable */
>>>>> +	SetZsPageMovable(pool, zspage);
>>>>> 	spin_unlock(&class->lock);
>>>>>
>>>>> 	return handle;
>>>>> @@ -1484,6 +1644,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
>>>>> 	int class_idx;
>>>>> 	struct size_class *class;
>>>>> 	enum fullness_group fullness;
>>>>> +	bool isolated;
>>>>>
>>>>> 	if (unlikely(!handle))
>>>>> 		return;
>>>>> @@ -1493,22 +1654,28 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
>>>>> 	obj_to_location(obj, &f_page, &f_objidx);
>>>>> 	zspage = get_zspage(f_page);
>>>>>
>>>>> +	migrate_read_lock(zspage);
>>>>> +
>>>>> 	get_zspage_mapping(zspage, &class_idx, &fullness);
>>>>> 	class = pool->size_class[class_idx];
>>>>>
>>>>> 	spin_lock(&class->lock);
>>>>> 	obj_free(class, obj);
>>>>> 	fullness = fix_fullness_group(class, zspage);
>>>>> -	if (fullness == ZS_EMPTY) {
>>>>> -		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>>>>> -				class->size, class->pages_per_zspage));
>>>>> -		atomic_long_sub(class->pages_per_zspage,
>>>>> -				&pool->pages_allocated);
>>>>> -		free_zspage(pool, zspage);
>>>>> +	if (fullness != ZS_EMPTY) {
>>>>> +		migrate_read_unlock(zspage);
>>>>> +		goto out;
>>>>> 	}
>>>>> +
>>>>> +	isolated = is_zspage_isolated(zspage);
>>>>> +	migrate_read_unlock(zspage);
>>>>> +	/* If zspage is isolated, zs_page_putback will free the zspage */
>>>>> +	if (likely(!isolated))
>>>>> +		free_zspage(pool, class, zspage);
>>>>> +out:
>>>>> +
>>>>> 	spin_unlock(&class->lock);
>>>>> 	unpin_tag(handle);
>>>>> -
>>>>> 	cache_free_handle(pool, handle);
>>>>> }
>>>>> EXPORT_SYMBOL_GPL(zs_free);
>>>>> @@ -1587,12 +1754,13 @@ static unsigned long find_alloced_obj(struct size_class *class,
>>>>> 	int offset = 0;
>>>>> 	unsigned long handle = 0;
>>>>> 	void *addr = kmap_atomic(page);
>>>>> +	struct zspage *zspage = get_zspage(page);
>>>>>
>>>>> -	offset = get_first_obj_offset(page);
>>>>> +	offset = get_first_obj_offset(class, get_first_page(zspage), page);
>>>>> 	offset += class->size * index;
>>>>>
>>>>> 	while (offset < PAGE_SIZE) {
>>>>> -		head = obj_to_head(class, page, addr + offset);
>>>>> +		head = obj_to_head(page, addr + offset);
>>>>> 		if (head & OBJ_ALLOCATED_TAG) {
>>>>> 			handle = head & ~OBJ_ALLOCATED_TAG;
>>>>> 			if (trypin_tag(handle))
>>>>> @@ -1684,6 +1852,7 @@ static struct zspage *isolate_zspage(struct size_class *class, bool source)
>>>>> 		zspage = list_first_entry_or_null(&class->fullness_list[fg[i]],
>>>>> 							struct zspage, list);
>>>>> 		if (zspage) {
>>>>> +			VM_BUG_ON(is_zspage_isolated(zspage));
>>>>> 			remove_zspage(class, zspage, fg[i]);
>>>>> 			return zspage;
>>>>> 		}
>>>>> @@ -1704,6 +1873,8 @@ static enum fullness_group putback_zspage(struct size_class *class,
>>>>> {
>>>>> 	enum fullness_group fullness;
>>>>>
>>>>> +	VM_BUG_ON(is_zspage_isolated(zspage));
>>>>> +
>>>>> 	fullness = get_fullness_group(class, zspage);
>>>>> 	insert_zspage(class, zspage, fullness);
>>>>> 	set_zspage_mapping(zspage, class->index, fullness);
>>>>> @@ -1711,6 +1882,377 @@ static enum fullness_group putback_zspage(struct size_class *class,
>>>>> 	return fullness;
>>>>> }
>>>>>
>>>>> +#ifdef CONFIG_COMPACTION
>>>>> +static struct dentry *zs_mount(struct file_system_type *fs_type,
>>>>> +				int flags, const char *dev_name, void *data)
>>>>> +{
>>>>> +	static const struct dentry_operations ops = {
>>>>> +		.d_dname = simple_dname,
>>>>> +	};
>>>>> +
>>>>> +	return mount_pseudo(fs_type, "zsmalloc:", NULL, &ops, ZSMALLOC_MAGIC);
>>>>> +}
>>>>> +
>>>>> +static struct file_system_type zsmalloc_fs = {
>>>>> +	.name		= "zsmalloc",
>>>>> +	.mount		= zs_mount,
>>>>> +	.kill_sb	= kill_anon_super,
>>>>> +};
>>>>> +
>>>>> +static int zsmalloc_mount(void)
>>>>> +{
>>>>> +	int ret = 0;
>>>>> +
>>>>> +	zsmalloc_mnt = kern_mount(&zsmalloc_fs);
>>>>> +	if (IS_ERR(zsmalloc_mnt))
>>>>> +		ret = PTR_ERR(zsmalloc_mnt);
>>>>> +
>>>>> +	return ret;
>>>>> +}
>>>>> +
>>>>> +static void zsmalloc_unmount(void)
>>>>> +{
>>>>> +	kern_unmount(zsmalloc_mnt);
>>>>> +}
>>>>> +
>>>>> +static void migrate_lock_init(struct zspage *zspage)
>>>>> +{
>>>>> +	rwlock_init(&zspage->lock);
>>>>> +}
>>>>> +
>>>>> +static void migrate_read_lock(struct zspage *zspage)
>>>>> +{
>>>>> +	read_lock(&zspage->lock);
>>>>> +}
>>>>> +
>>>>> +static void migrate_read_unlock(struct zspage *zspage)
>>>>> +{
>>>>> +	read_unlock(&zspage->lock);
>>>>> +}
>>>>> +
>>>>> +static void migrate_write_lock(struct zspage *zspage)
>>>>> +{
>>>>> +	write_lock(&zspage->lock);
>>>>> +}
>>>>> +
>>>>> +static void migrate_write_unlock(struct zspage *zspage)
>>>>> +{
>>>>> +	write_unlock(&zspage->lock);
>>>>> +}
>>>>> +
>>>>> +/* Number of isolated subpage for *page migration* in this zspage */
>>>>> +static void inc_zspage_isolation(struct zspage *zspage)
>>>>> +{
>>>>> +	zspage->isolated++;
>>>>> +}
>>>>> +
>>>>> +static void dec_zspage_isolation(struct zspage *zspage)
>>>>> +{
>>>>> +	zspage->isolated--;
>>>>> +}
>>>>> +
>>>>> +static void replace_sub_page(struct size_class *class, struct zspage *zspage,
>>>>> +				struct page *newpage, struct page *oldpage)
>>>>> +{
>>>>> +	struct page *page;
>>>>> +	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE] = {NULL, };
>>>>> +	int idx = 0;
>>>>> +
>>>>> +	page = get_first_page(zspage);
>>>>> +	do {
>>>>> +		if (page == oldpage)
>>>>> +			pages[idx] = newpage;
>>>>> +		else
>>>>> +			pages[idx] = page;
>>>>> +		idx++;
>>>>> +	} while ((page = get_next_page(page)) != NULL);
>>>>> +
>>>>> +	create_page_chain(class, zspage, pages);
>>>>> +	if (unlikely(PageHugeObject(oldpage)))
>>>>> +		newpage->index = oldpage->index;
>>>>> +	__SetPageMovable(newpage, page_mapping(oldpage));
>>>>> +}
>>>>> +
>>>>> +bool zs_page_isolate(struct page *page, isolate_mode_t mode)
>>>>> +{
>>>>> +	struct zs_pool *pool;
>>>>> +	struct size_class *class;
>>>>> +	int class_idx;
>>>>> +	enum fullness_group fullness;
>>>>> +	struct zspage *zspage;
>>>>> +	struct address_space *mapping;
>>>>> +
>>>>> +	/*
>>>>> +	 * Page is locked so zspage couldn't be destroyed. For detail, look at
>>>>> +	 * lock_zspage in free_zspage.
>>>>> +	 */
>>>>> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
>>>>> +	VM_BUG_ON_PAGE(PageIsolated(page), page);
>>>>> +
>>>>> +	zspage = get_zspage(page);
>>>>> +
>>>>> +	/*
>>>>> +	 * Without class lock, fullness could be stale while class_idx is okay
>>>>> +	 * because class_idx is constant unless page is freed so we should get
>>>>> +	 * fullness again under class lock.
>>>>> +	 */
>>>>> +	get_zspage_mapping(zspage, &class_idx, &fullness);
>>>>> +	mapping = page_mapping(page);
>>>>> +	pool = mapping->private_data;
>>>>> +	class = pool->size_class[class_idx];
>>>>> +
>>>>> +	spin_lock(&class->lock);
>>>>> +	if (get_zspage_inuse(zspage) == 0) {
>>>>> +		spin_unlock(&class->lock);
>>>>> +		return false;
>>>>> +	}
>>>>> +
>>>>> +	/* zspage is isolated for object migration */
>>>>> +	if (list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
>>>>> +		spin_unlock(&class->lock);
>>>>> +		return false;
>>>>> +	}
>>>>> +
>>>>> +	/*
>>>>> +	 * If this is first time isolation for the zspage, isolate zspage from
>>>>> +	 * size_class to prevent further object allocation from the zspage.
>>>>> +	 */
>>>>> +	if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
>>>>> +		get_zspage_mapping(zspage, &class_idx, &fullness);
>>>>> +		remove_zspage(class, zspage, fullness);
>>>>> +	}
>>>>> +
>>>>> +	inc_zspage_isolation(zspage);
>>>>> +	spin_unlock(&class->lock);
>>>>> +
>>>>> +	return true;
>>>>> +}
>>>>> +
>>>>> +int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>>>> +		struct page *page, enum migrate_mode mode)
>>>>> +{
>>>>> +	struct zs_pool *pool;
>>>>> +	struct size_class *class;
>>>>> +	int class_idx;
>>>>> +	enum fullness_group fullness;
>>>>> +	struct zspage *zspage;
>>>>> +	struct page *dummy;
>>>>> +	void *s_addr, *d_addr, *addr;
>>>>> +	int offset, pos;
>>>>> +	unsigned long handle, head;
>>>>> +	unsigned long old_obj, new_obj;
>>>>> +	unsigned int obj_idx;
>>>>> +	int ret = -EAGAIN;
>>>>> +
>>>>> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
>>>>> +	VM_BUG_ON_PAGE(!PageIsolated(page), page);
>>>>> +
>>>>> +	zspage = get_zspage(page);
>>>>> +
>>>>> +	/* Concurrent compactor cannot migrate any subpage in zspage */
>>>>> +	migrate_write_lock(zspage);
>>>>> +	get_zspage_mapping(zspage, &class_idx, &fullness);
>>>>> +	pool = mapping->private_data;
>>>>> +	class = pool->size_class[class_idx];
>>>>> +	offset = get_first_obj_offset(class, get_first_page(zspage), page);
>>>>> +
>>>>> +	spin_lock(&class->lock);
>>>>> +	if (!get_zspage_inuse(zspage)) {
>>>>> +		ret = -EBUSY;
>>>>> +		goto unlock_class;
>>>>> +	}
>>>>> +
>>>>> +	pos = offset;
>>>>> +	s_addr = kmap_atomic(page);
>>>>> +	while (pos < PAGE_SIZE) {
>>>>> +		head = obj_to_head(page, s_addr + pos);
>>>>> +		if (head & OBJ_ALLOCATED_TAG) {
>>>>> +			handle = head & ~OBJ_ALLOCATED_TAG;
>>>>> +			if (!trypin_tag(handle))
>>>>> +				goto unpin_objects;
>>>>> +		}
>>>>> +		pos += class->size;
>>>>> +	}
>>>>> +
>>>>> +	/*
>>>>> +	 * Here, any user cannot access all objects in the zspage so let's move.
>>>>> +	 */
>>>>> +	d_addr = kmap_atomic(newpage);
>>>>> +	memcpy(d_addr, s_addr, PAGE_SIZE);
>>>>> +	kunmap_atomic(d_addr);
>>>>> +
>>>>> +	for (addr = s_addr + offset; addr < s_addr + pos;
>>>>> +					addr += class->size) {
>>>>> +		head = obj_to_head(page, addr);
>>>>> +		if (head & OBJ_ALLOCATED_TAG) {
>>>>> +			handle = head & ~OBJ_ALLOCATED_TAG;
>>>>> +			if (!testpin_tag(handle))
>>>>> +				BUG();
>>>>> +
>>>>> +			old_obj = handle_to_obj(handle);
>>>>> +			obj_to_location(old_obj, &dummy, &obj_idx);
>>>>> +			new_obj = (unsigned long)location_to_obj(newpage,
>>>>> +								obj_idx);
>>>>> +			new_obj |= BIT(HANDLE_PIN_BIT);
>>>>> +			record_obj(handle, new_obj);
>>>>> +		}
>>>>> +	}
>>>>> +
>>>>> +	replace_sub_page(class, zspage, newpage, page);
>>>>> +	get_page(newpage);
>>>>> +
>>>>> +	dec_zspage_isolation(zspage);
>>>>> +
>>>>> +	/*
>>>>> +	 * Page migration is done so let's putback isolated zspage to
>>>>> +	 * the list if @page is final isolated subpage in the zspage.
>>>>> +	 */
>>>>> +	if (!is_zspage_isolated(zspage))
>>>>> +		putback_zspage(class, zspage);
>>>>> +
>>>>> +	reset_page(page);
>>>>> +	put_page(page);
>>>>> +	page = newpage;
>>>>> +
>>>>> +	ret = 0;
>>>>> +unpin_objects:
>>>>> +	for (addr = s_addr + offset; addr < s_addr + pos;
>>>>> +						addr += class->size) {
>>>>> +		head = obj_to_head(page, addr);
>>>>> +		if (head & OBJ_ALLOCATED_TAG) {
>>>>> +			handle = head & ~OBJ_ALLOCATED_TAG;
>>>>> +			if (!testpin_tag(handle))
>>>>> +				BUG();
>>>>> +			unpin_tag(handle);
>>>>> +		}
>>>>> +	}
>>>>> +	kunmap_atomic(s_addr);
>>>>> +unlock_class:
>>>>> +	spin_unlock(&class->lock);
>>>>> +	migrate_write_unlock(zspage);
>>>>> +
>>>>> +	return ret;
>>>>> +}
>>>>> +
>>>>> +void zs_page_putback(struct page *page)
>>>>> +{
>>>>> +	struct zs_pool *pool;
>>>>> +	struct size_class *class;
>>>>> +	int class_idx;
>>>>> +	enum fullness_group fg;
>>>>> +	struct address_space *mapping;
>>>>> +	struct zspage *zspage;
>>>>> +
>>>>> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
>>>>> +	VM_BUG_ON_PAGE(!PageIsolated(page), page);
>>>>> +
>>>>> +	zspage = get_zspage(page);
>>>>> +	get_zspage_mapping(zspage, &class_idx, &fg);
>>>>> +	mapping = page_mapping(page);
>>>>> +	pool = mapping->private_data;
>>>>> +	class = pool->size_class[class_idx];
>>>>> +
>>>>> +	spin_lock(&class->lock);
>>>>> +	dec_zspage_isolation(zspage);
>>>>> +	if (!is_zspage_isolated(zspage)) {
>>>>> +		fg = putback_zspage(class, zspage);
>>>>> +		/*
>>>>> +		 * Due to page_lock, we cannot free zspage immediately
>>>>> +		 * so let's defer.
>>>>> +		 */
>>>>> +		if (fg == ZS_EMPTY)
>>>>> +			schedule_work(&pool->free_work);
>>>>> +	}
>>>>> +	spin_unlock(&class->lock);
>>>>> +}
>>>>> +
>>>>> +const struct address_space_operations zsmalloc_aops = {
>>>>> +	.isolate_page = zs_page_isolate,
>>>>> +	.migratepage = zs_page_migrate,
>>>>> +	.putback_page = zs_page_putback,
>>>>> +};
>>>>> +
>>>>> +static int zs_register_migration(struct zs_pool *pool)
>>>>> +{
>>>>> +	pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
>>>>> +	if (IS_ERR(pool->inode)) {
>>>>> +		pool->inode = NULL;
>>>>> +		return 1;
>>>>> +	}
>>>>> +
>>>>> +	pool->inode->i_mapping->private_data = pool;
>>>>> +	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
>>>>> +	return 0;
>>>>> +}
>>>>> +
>>>>> +static void zs_unregister_migration(struct zs_pool *pool)
>>>>> +{
>>>>> +	flush_work(&pool->free_work);
>>>>> +	if (pool->inode)
>>>>> +		iput(pool->inode);
>>>>> +}
>>>>> +
>>>>> +/*
>>>>> + * Caller should hold page_lock of all pages in the zspage
>>>>> + * In here, we cannot use zspage meta data.
>>>>> + */
>>>>> +static void async_free_zspage(struct work_struct *work)
>>>>> +{
>>>>> +	int i;
>>>>> +	struct size_class *class;
>>>>> +	unsigned int class_idx;
>>>>> +	enum fullness_group fullness;
>>>>> +	struct zspage *zspage, *tmp;
>>>>> +	LIST_HEAD(free_pages);
>>>>> +	struct zs_pool *pool = container_of(work, struct zs_pool,
>>>>> +					free_work);
>>>>> +
>>>>> +	for (i = 0; i < zs_size_classes; i++) {
>>>>> +		class = pool->size_class[i];
>>>>> +		if (class->index != i)
>>>>> +			continue;
>>>>> +
>>>>> +		spin_lock(&class->lock);
>>>>> +		list_splice_init(&class->fullness_list[ZS_EMPTY], &free_pages);
>>>>> +		spin_unlock(&class->lock);
>>>>> +	}
>>>>> +
>>>>> +
>>>>> +	list_for_each_entry_safe(zspage, tmp, &free_pages, list) {
>>>>> +		list_del(&zspage->list);
>>>>> +		lock_zspage(zspage);
>>>>> +
>>>>> +		get_zspage_mapping(zspage, &class_idx, &fullness);
>>>>> +		VM_BUG_ON(fullness != ZS_EMPTY);
>>>>> +		class = pool->size_class[class_idx];
>>>>> +		spin_lock(&class->lock);
>>>>> +		__free_zspage(pool, pool->size_class[class_idx], zspage);
>>>>> +		spin_unlock(&class->lock);
>>>>> +	}
>>>>> +};
>>>>> +
>>>>> +static void kick_deferred_free(struct zs_pool *pool)
>>>>> +{
>>>>> +	schedule_work(&pool->free_work);
>>>>> +}
>>>>> +
>>>>> +static void init_deferred_free(struct zs_pool *pool)
>>>>> +{
>>>>> +	INIT_WORK(&pool->free_work, async_free_zspage);
>>>>> +}
>>>>> +
>>>>> +static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage)
>>>>> +{
>>>>> +	struct page *page = get_first_page(zspage);
>>>>> +
>>>>> +	do {
>>>>> +		WARN_ON(!trylock_page(page));
>>>>> +		__SetPageMovable(page, pool->inode->i_mapping);
>>>>> +		unlock_page(page);
>>>>> +	} while ((page = get_next_page(page)) != NULL);
>>>>> +}
>>>>> +#endif
>>>>> +
>>>>> /*
>>>>> *
>>>>> * Based on the number of unused allocated objects calculate
>>>>> @@ -1745,10 +2287,10 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>>>>> 			break;
>>>>>
>>>>> 		cc.index = 0;
>>>>> -		cc.s_page = src_zspage->first_page;
>>>>> +		cc.s_page = get_first_page(src_zspage);
>>>>>
>>>>> 		while ((dst_zspage = isolate_zspage(class, false))) {
>>>>> -			cc.d_page = dst_zspage->first_page;
>>>>> +			cc.d_page = get_first_page(dst_zspage);
>>>>> 			/*
>>>>> 			 * If there is no more space in dst_page, resched
>>>>> 			 * and see if anyone had allocated another zspage.
>>>>> @@ -1765,11 +2307,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>>>>>
>>>>> 		putback_zspage(class, dst_zspage);
>>>>> 		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
>>>>> -			zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>>>>> -					class->size, class->pages_per_zspage));
>>>>> -			atomic_long_sub(class->pages_per_zspage,
>>>>> -					&pool->pages_allocated);
>>>>> -			free_zspage(pool, src_zspage);
>>>>> +			free_zspage(pool, class, src_zspage);
>>>>> 			pool->stats.pages_compacted += class->pages_per_zspage;
>>>>> 		}
>>>>> 		spin_unlock(&class->lock);
>>>>> @@ -1885,6 +2423,7 @@ struct zs_pool *zs_create_pool(const char *name)
>>>>> 	if (!pool)
>>>>> 		return NULL;
>>>>>
>>>>> +	init_deferred_free(pool);
>>>>> 	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
>>>>> 			GFP_KERNEL);
>>>>> 	if (!pool->size_class) {
>>>>> @@ -1939,12 +2478,10 @@ struct zs_pool *zs_create_pool(const char *name)
>>>>> 		class->pages_per_zspage = pages_per_zspage;
>>>>> 		class->objs_per_zspage = class->pages_per_zspage *
>>>>> 						PAGE_SIZE / class->size;
>>>>> -		if (pages_per_zspage == 1 && class->objs_per_zspage == 1)
>>>>> -			class->huge = true;
>>>>> 		spin_lock_init(&class->lock);
>>>>> 		pool->size_class[i] = class;
>>>>> -		for (fullness = ZS_ALMOST_FULL; fullness <= ZS_ALMOST_EMPTY;
>>>>> -								fullness++)
>>>>> +		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
>>>>> +							fullness++)
>>>>> 			INIT_LIST_HEAD(&class->fullness_list[fullness]);
>>>>>
>>>>> 		prev_class = class;
>>>>> @@ -1953,6 +2490,9 @@ struct zs_pool *zs_create_pool(const char *name)
>>>>> 	/* debug only, don't abort if it fails */
>>>>> 	zs_pool_stat_create(pool, name);
>>>>>
>>>>> +	if (zs_register_migration(pool))
>>>>> +		goto err;
>>>>> +
>>>>> 	/*
>>>>> 	 * Not critical, we still can use the pool
>>>>> 	 * and user can trigger compaction manually.
>>>>> @@ -1972,6 +2512,7 @@ void zs_destroy_pool(struct zs_pool *pool)
>>>>> 	int i;
>>>>>
>>>>> 	zs_unregister_shrinker(pool);
>>>>> +	zs_unregister_migration(pool);
>>>>> 	zs_pool_stat_destroy(pool);
>>>>>
>>>>> 	for (i = 0; i < zs_size_classes; i++) {
>>>>> @@ -1984,7 +2525,7 @@ void zs_destroy_pool(struct zs_pool *pool)
>>>>> 		if (class->index != i)
>>>>> 			continue;
>>>>>
>>>>> -		for (fg = ZS_ALMOST_FULL; fg <= ZS_ALMOST_EMPTY; fg++) {
>>>>> +		for (fg = ZS_EMPTY; fg < NR_ZS_FULLNESS; fg++) {
>>>>> 			if (!list_empty(&class->fullness_list[fg])) {
>>>>> 				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
>>>>> 					class->size, fg);
>>>>> @@ -2002,7 +2543,13 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
>>>>>
>>>>> static int __init zs_init(void)
>>>>> {
>>>>> -	int ret = zs_register_cpu_notifier();
>>>>> +	int ret;
>>>>> +
>>>>> +	ret = zsmalloc_mount();
>>>>> +	if (ret)
>>>>> +		goto out;
>>>>> +
>>>>> +	ret = zs_register_cpu_notifier();
>>>>>
>>>>> 	if (ret)
>>>>> 		goto notifier_fail;
>>>>> @@ -2019,7 +2566,8 @@ static int __init zs_init(void)
>>>>>
>>>>> notifier_fail:
>>>>> 	zs_unregister_cpu_notifier();
>>>>> -
>>>>> +	zsmalloc_unmount();
>>>>> +out:
>>>>> 	return ret;
>>>>> }
>>>>>
>>>>> @@ -2028,6 +2576,7 @@ static void __exit zs_exit(void)
>>>>> #ifdef CONFIG_ZPOOL
>>>>> 	zpool_unregister_driver(&zs_zpool_driver);
>>>>> #endif
>>>>> +	zsmalloc_unmount();
>>>>> 	zs_unregister_cpu_notifier();
>>>>>
>>>>> 	zs_stat_exit();
>>>>>
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
