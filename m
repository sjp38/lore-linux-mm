From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 19 Apr 2008 02:25:56 +0900 (JST)
Subject: Re: Re: [PATCH]Fix usemap for DISCONTIG/FLATMEM with not-aligned zone initilaization.
In-Reply-To: <20080418161522.GB9147@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080418161522.GB9147@csn.ul.ie>
 <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shi Weihua <shiwh@cn.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Thank you for looking into.

>> -		if ((pfn & (pageblock_nr_pages-1)))
>> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>> +		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>>  
>
>The point of the if there was so that set_pageblock_migratetype() would
>only be called once per pageblock. The impact with an unaligned zone is
>that the first block is not set and will be used for UNMOVABLE pages
>initially. However, this is not a major impact and there is no need to
>call set_pageblock_migratetype for every page.
>
But if ((pfn & (pageblock_nr_pages -1))) is not correct.
for calling set_pageblock_migrationtype() once in a pageblock,
!((pfn & (pageblock_nr_pages -1))) is correct.


>
>This is a pretty large change for what seems to be a fairly basic problem -
I think so ;(

>alignment issues during boot where I'm guessing we are writing past the end
>of the bitmap. Even if the virtual memmap is covering non-existant pages,
>the PFNs there for bitmaps and the like should still not be getting used
>and the map size is already rounded up to the pageblock size. It's also
>expanding the size of zone which seems overkill.
>
>I think I have a possible alternative fix below.
>
ok.

>What about something like the following? Instead of expanding the size of
>structures, it sanity checks input parameters. It touches a number of places
>because of an API change but it is otherwise straight-forward.
>
>Unfortunately, I do not have an IA-64 machine that can reproduce the problem
>to see if this still fixes it or not so a test as well as a review would be
>appreciated. What should happen is the machine boots but prints a warning
>about the unexpected PFN ranges. It boot-tested fine on a number of other
>machines (x86-32 x86-64 and ppc64).
>
ok, I'll test today if I have a chance. At least, I think I can test this
until Monday. but I have one concern (below)


>+	/*
>+	 * Sanity check the values passed in. It is possible an architecture
>+	 * calling this function directly will use values outside of the memory
>+	 * they registered
>+	 */
>+	if (start_pfn < zone->zone_start_pfn) {
>+		WARN_ON_ONCE(1);
>+		start_pfn = zone->zone_start_pfn;
>+	}
>+
>+	if (size > zone->spanned_pages) {
>+		WARN_ON_ONCE(1);
>+		size = zone->spanned_pages;
>+	}
> 
My concern here is, memmap out-of-zone is not initialized and not
marked as PG_reserved...sholdn't we initialize existing memmap even
if they are out-ot-zone ? I think all existing mem_map for memory hole
should be initialized properly.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
