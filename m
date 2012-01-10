Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id D34986B0070
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 10:04:15 -0500 (EST)
Received: by eeke53 with SMTP id e53so327149eek.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 07:04:14 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 05/11] mm: mmzone: MIGRATE_CMA migration type added
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-6-git-send-email-m.szyprowski@samsung.com>
 <20120110143836.GC3910@csn.ul.ie>
Date: Tue, 10 Jan 2012 16:04:12 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7vitat33l0zgt@mpn-glaptop>
In-Reply-To: <20120110143836.GC3910@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Tue, 10 Jan 2012 15:38:36 +0100, Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Dec 29, 2011 at 01:39:06PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>

>> @@ -35,13 +35,35 @@
>>   */
>>  #define PAGE_ALLOC_COSTLY_ORDER 3
>>
>> -#define MIGRATE_UNMOVABLE     0
>> -#define MIGRATE_RECLAIMABLE   1
>> -#define MIGRATE_MOVABLE       2
>> -#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp li=
sts */
>> -#define MIGRATE_RESERVE       3
>> -#define MIGRATE_ISOLATE       4 /* can't allocate from here */
>> -#define MIGRATE_TYPES         5
>> +enum {
>> +	MIGRATE_UNMOVABLE,
>> +	MIGRATE_RECLAIMABLE,
>> +	MIGRATE_MOVABLE,
>> +	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
>> +	MIGRATE_RESERVE =3D MIGRATE_PCPTYPES,
>> +	/*
>> +	 * MIGRATE_CMA migration type is designed to mimic the way
>> +	 * ZONE_MOVABLE works.  Only movable pages can be allocated
>> +	 * from MIGRATE_CMA pageblocks and page allocator never
>> +	 * implicitly change migration type of MIGRATE_CMA pageblock.
>> +	 *
>> +	 * The way to use it is to change migratetype of a range of
>> +	 * pageblocks to MIGRATE_CMA which can be done by
>> +	 * __free_pageblock_cma() function.  What is important though
>> +	 * is that a range of pageblocks must be aligned to
>> +	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
>> +	 * a single pageblock.
>> +	 */
>> +	MIGRATE_CMA,
>> +	MIGRATE_ISOLATE,	/* can't allocate from here */
>> +	MIGRATE_TYPES
>> +};
>
> MIGRATE_CMA is being added whether or not CONFIG_CMA is set. This
> increases the size of the pageblock bitmap and where that is just 1 bi=
t
> per pageblock in the system, it may be noticable on large machines.

Wasn't aware of that, will do.  In fact, in earlier versions in was done=
 this way,
but resulted in more #ifdefs.

>
>> +
>> +#ifdef CONFIG_CMA
>> +#  define is_migrate_cma(migratetype) unlikely((migratetype) =3D=3D =
MIGRATE_CMA)
>> +#else
>> +#  define is_migrate_cma(migratetype) false
>> +#endif

> Use static inlines.

I decide to use #define for the sake of situations like
is_migrate_cma(get_pageblock_migratetype(page)).  With a static inline i=
t will have
to read pageblock's migrate type even if !CONFIG_CMA.  A macro gets rid =
of this
operation all together.

>>  #define for_each_migratetype_order(order, type) \
>>  	for (order =3D 0; order < MAX_ORDER; order++) \
>> @@ -54,6 +76,11 @@ static inline int get_pageblock_migratetype(struct=
 page *page)
>>  	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);=

>>  }
>>
>> +static inline bool is_pageblock_cma(struct page *page)
>> +{
>> +	return is_migrate_cma(get_pageblock_migratetype(page));
>> +}
>> +
>
> This allows additional calls to get_pageblock_migratetype() even if
> CONFIG_CMA is not set.
>
>>  struct free_area {
>>  	struct list_head	free_list[MIGRATE_TYPES];
>>  	unsigned long		nr_free;
>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isol=
ation.h
>> index d305080..af650db 100644
>> --- a/include/linux/page-isolation.h
>> +++ b/include/linux/page-isolation.h
>> @@ -37,4 +37,7 @@ extern void unset_migratetype_isolate(struct page *=
page);
>>  int alloc_contig_range(unsigned long start, unsigned long end);
>>  void free_contig_range(unsigned long pfn, unsigned nr_pages);
>>
>> +/* CMA stuff */
>> +extern void init_cma_reserved_pageblock(struct page *page);
>> +
>>  #endif
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 011b110..e080cac 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -192,7 +192,7 @@ config COMPACTION
>>  config MIGRATION
>>  	bool "Page migration"
>>  	def_bool y
>> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
>> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CM=
A
>>  	help
>>  	  Allows the migration of the physical location of pages of process=
es
>>  	  while the virtual addresses are not changed. This is useful in
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 8733441..46783b4 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -21,6 +21,11 @@
>>  #define CREATE_TRACE_POINTS
>>  #include <trace/events/compaction.h>
>>
>> +static inline bool is_migrate_cma_or_movable(int migratetype)
>> +{
>> +	return is_migrate_cma(migratetype) || migratetype =3D=3D MIGRATE_MO=
VABLE;
>> +}
>> +
>
> That is not a name that helps any. migrate_async_suitable() would be
> marginally better.
>
>>  /**
>>   * isolate_freepages_range() - isolate free pages, must hold zone->l=
ock.
>>   * @zone:	Zone pages are in.
>> @@ -213,7 +218,7 @@ isolate_migratepages_range(struct zone *zone, str=
uct compact_control *cc,
>>  		 */
>>  		pageblock_nr =3D low_pfn >> pageblock_order;
>>  		if (!cc->sync && last_pageblock_nr !=3D pageblock_nr &&
>> -				get_pageblock_migratetype(page) !=3D MIGRATE_MOVABLE) {
>> +		    is_migrate_cma_or_movable(get_pageblock_migratetype(page))) {
>>  			low_pfn +=3D pageblock_nr_pages;
>>  			low_pfn =3D ALIGN(low_pfn, pageblock_nr_pages) - 1;
>>  			last_pageblock_nr =3D pageblock_nr;
>
> I know I suggested migrate_async_suitable() here but the check may
> not even happen if CMA uses sync migration.

For CMA, we know that pageblock's migrate type is MIGRATE_CMA.

>
>> @@ -295,8 +300,8 @@ static bool suitable_migration_target(struct page=
 *page)
>>  	if (PageBuddy(page) && page_order(page) >=3D pageblock_order)
>>  		return true;
>>
>> -	/* If the block is MIGRATE_MOVABLE, allow migration */
>> -	if (migratetype =3D=3D MIGRATE_MOVABLE)
>> +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration =
*/
>> +	if (is_migrate_cma_or_movable(migratetype))
>>  		return true;
>>
>>  	/* Otherwise skip the block */
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 47b0a85..06a7861 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -722,6 +722,26 @@ void __meminit __free_pages_bootmem(struct page =
*page, unsigned int order)
>>  	}
>>  }
>>
>> +#ifdef CONFIG_CMA
>> +/*
>> + * Free whole pageblock and set it's migration type to MIGRATE_CMA.
>> + */
>> +void __init init_cma_reserved_pageblock(struct page *page)
>> +{
>> +	unsigned i =3D pageblock_nr_pages;
>> +	struct page *p =3D page;
>> +
>> +	do {
>> +		__ClearPageReserved(p);
>> +		set_page_count(p, 0);
>> +	} while (++p, --i);
>> +
>> +	set_page_refcounted(page);
>> +	set_pageblock_migratetype(page, MIGRATE_CMA);
>> +	__free_pages(page, pageblock_order);
>> +	totalram_pages +=3D pageblock_nr_pages;
>> +}
>> +#endif
>>
>>  /*
>>   * The order of subdivision here is critical for the IO subsystem.
>> @@ -830,11 +850,10 @@ struct page *__rmqueue_smallest(struct zone *zo=
ne, unsigned int order,
>>   * This array describes the order lists are fallen back to when
>>   * the free lists for the desirable migrate type are depleted
>>   */
>> -static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] =3D {
>> +static int fallbacks[MIGRATE_PCPTYPES][4] =3D {
>>  	[MIGRATE_UNMOVABLE]   =3D { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,  =
 MIGRATE_RESERVE },
>>  	[MIGRATE_RECLAIMABLE] =3D { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,  =
 MIGRATE_RESERVE },
>> -	[MIGRATE_MOVABLE]     =3D { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,=
 MIGRATE_RESERVE },
>> -	[MIGRATE_RESERVE]     =3D { MIGRATE_RESERVE,     MIGRATE_RESERVE,  =
 MIGRATE_RESERVE }, /* Never used */
>> +	[MIGRATE_MOVABLE]     =3D { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,=
 MIGRATE_CMA    , MIGRATE_RESERVE },
>
> Why did you delete [MIGRATE_RESERVE] here?

It is never used anyway.

> It changes the array from being expressed in terms of MIGRATE_TYPES to=

> being a hard-coded value.

I don't follow.  This is only used in code path that fills in pcp lists,=
 so only
the first MIGRATE_PCPTYPES rows are used.

> I do not see the advantage and it's not clear how it is related to the=
 patch.

No real advantages, I can revert that change.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
