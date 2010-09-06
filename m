Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 107356B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:30:44 -0400 (EDT)
Received: by vws16 with SMTP id 16so4335158vws.14
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 06:30:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100906093042.GB23089@tiehlicka.suse.cz>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906093042.GB23089@tiehlicka.suse.cz>
Date: Mon, 6 Sep 2010 22:30:43 +0900
Message-ID: <AANLkTikOi6BqXs2wiLetFP9OgYtXD+vbC+Ez8a7z0dcU@mail.gmail.com>
Subject: Re: [PATCH 3/3] memory hotplug: use unified logic for is_removable
 and offline_pages
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

2010/9/6 Michal Hocko <mhocko@suse.cz>:
> On Mon 06-09-10 14:47:16, KAMEZAWA Hiroyuki wrote:
>>
>> Now, sysfs interface of memory hotplug shows whether the section is
>> removable or not. But it checks only migrateype of pages and doesn't
>> check details of cluster of pages.
>>
>> Next, memory hotplug's set_migratetype_isolate() has the same kind
>> of check, too. But the migrate-type is just a "hint" and the pageblock
>> can contain several types of pages if fragmentation is very heavy.
>>
>> To get precise information, we need to check
>> =A0- the pageblock only contains free pages or LRU pages.
>>
>> This patch adds the function __count_unmovable_pages() and makes
>> above 2 checks to use the same logic. This will improve user experience
>> of memory hotplug because sysfs interface tells accurate information.
>>
>> Note:
>> it may be better to check MIGRATE_UNMOVABLE for making failure case quic=
k.
>>
>> Changelog: 2010/09/06
>> =A0- added comments.
>> =A0- removed zone->lock.
>> =A0- changed the name of the function to be is_pageblock_removable_async=
().
>> =A0 =A0because I removed the zone->lock.
>
> wouldn't be __is_pageblock_removable a better name? _async suffix is
> usually used for asynchronous operations and this is just a function
> withtout locks.
>
rename as _is_pagebloc_removable_nolock().


>>
>> Reported-by: Michal Hocko <mhocko@suse.cz>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0include/linux/memory_hotplug.h | =A0 =A01
>> =A0mm/memory_hotplug.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 15 -------
>> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 77 +++++++++++++=
+++++++++++++++++-----------
>> =A03 files changed, 60 insertions(+), 33 deletions(-)
>>
>> Index: kametest/mm/page_alloc.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- kametest.orig/mm/page_alloc.c
>> +++ kametest/mm/page_alloc.c
>> @@ -5274,11 +5274,61 @@ void set_pageblock_flags_group(struct pa
>> =A0 * page allocater never alloc memory from ISOLATE block.
>> =A0 */
>>
>
> Can we add a comment on the locking? Something like:
> Caller should hold zone->lock if he needs consistent results.
>
Hmm. ok.

>> +static int __count_immobile_pages(struct zone *zone, struct page *page)
>> +{
>> + =A0 =A0 unsigned long pfn, iter, found;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* For avoiding noise data, lru_add_drain_all() should be ca=
lled
>> + =A0 =A0 =A0* If ZONE_MOVABLE, the zone never contains immobile pages
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (zone_idx(zone) =3D=3D ZONE_MOVABLE)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 pfn =3D page_to_pfn(page);
>> + =A0 =A0 for (found =3D 0, iter =3D 0; iter < pageblock_nr_pages; iter+=
+) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long check =3D pfn + iter;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pfn_valid_within(check)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iter++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 page =3D pfn_to_page(check);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!page_count(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageBuddy(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iter +=3D (1 <=
< page_order(page)) - 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!PageLRU(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 found++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page is not RAM, page_count()shoul=
d be 0.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* we don't need more check. This is an _use=
d_ not-movable page.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* The problematic thing here is PG_reserved=
 pages. PG_reserved
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* is set to both of a memory hole page and =
a _used_ kernel
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* page at boot.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 }
>> + =A0 =A0 return found;
>> +}
>> +
>> +bool is_pageblock_removable_async(struct page *page)
>> +{
>> + =A0 =A0 struct zone *zone =3D page_zone(page);
>> + =A0 =A0 unsigned long flags;
>> + =A0 =A0 int num;
>> + =A0 =A0 /* Don't take zone->lock interntionally. */
>
> Could you add the reason?
> Don't take zone-> lock intentionally because we are called from the
> userspace (sysfs interface).
>
I don't like to assume caller context which will limit the callers.

/* holding zone->lock or not is caller's job. */


> [...]
>> =A0 =A0 =A0 /* All pageblocks in the memory block are likely to be hot-r=
emovable */
>> Index: kametest/include/linux/memory_hotplug.h
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- kametest.orig/include/linux/memory_hotplug.h
>> +++ kametest/include/linux/memory_hotplug.h
>> @@ -69,6 +69,7 @@ extern void online_page(struct page *pag
>> =A0/* VM interface that may be used by firmware interface */
>> =A0extern int online_pages(unsigned long, unsigned long);
>> =A0extern void __offline_isolated_pages(unsigned long, unsigned long);
>
> #ifdef CONFIG_HOTREMOVE
>
>> +extern bool is_pageblock_removable_async(struct page *page);
>
> #else
> #define is_pageblock_removable_async(p) 0
> #endif
> ?

Is this function is called even if HOTREMOVE is off ?
If so, the caller is buggy. I'll check tomorrow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
