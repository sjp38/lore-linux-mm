Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E6516B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 13:15:04 -0400 (EDT)
Received: by vws16 with SMTP id 16so4564325vws.14
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 10:15:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100906133914.GL8384@csn.ul.ie>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906144228.4ee5a738.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906133914.GL8384@csn.ul.ie>
Date: Tue, 7 Sep 2010 02:15:01 +0900
Message-ID: <AANLkTikPkKcxja4tqRPmJErEGs3YZ=NS4dBNyz1e--+d@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 1/3] memory hotplug: fix next block calculation in is_removable
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

2010/9/6 Mel Gorman <mel@csn.ul.ie>:
> On Mon, Sep 06, 2010 at 02:42:28PM +0900, KAMEZAWA Hiroyuki wrote:
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> next_active_pageblock() is for finding next _used_ freeblock. It skips
>> several blocks when it finds there are a chunk of free pages lager than
>> pageblock. But it has 2 bugs.
>>
>> =A0 1. We have no lock. page_order(page) - pageblock_order can be minus.
>> =A0 2. pageblocks_stride +=3D is wrong. it should skip page_order(p) of =
pages.
>>
>> CC: stable@kernel.org
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/memory_hotplug.c | =A0 16 ++++++++--------
>> =A01 file changed, 8 insertions(+), 8 deletions(-)
>>
>> Index: kametest/mm/memory_hotplug.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- kametest.orig/mm/memory_hotplug.c
>> +++ kametest/mm/memory_hotplug.c
>> @@ -584,19 +584,19 @@ static inline int pageblock_free(struct
>> =A0/* Return the start of the next active pageblock after a given page *=
/
>> =A0static struct page *next_active_pageblock(struct page *page)
>> =A0{
>> - =A0 =A0 int pageblocks_stride;
>> -
>> =A0 =A0 =A0 /* Ensure the starting page is pageblock-aligned */
>> =A0 =A0 =A0 BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
>>
>> - =A0 =A0 /* Move forward by at least 1 * pageblock_nr_pages */
>> - =A0 =A0 pageblocks_stride =3D 1;
>> -
>> =A0 =A0 =A0 /* If the entire pageblock is free, move to the end of free =
page */
>> - =A0 =A0 if (pageblock_free(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 pageblocks_stride +=3D page_order(page) - page=
block_order;
>> + =A0 =A0 if (pageblock_free(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 int order;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* be careful. we don't have locks, page_order=
 can be changed.*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 order =3D page_order(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (order > pageblock_order)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return page + (1 << order);
>> + =A0 =A0 }
>
> As you note in your changelog, page_order() is unsafe because we do not h=
ave
> the zone lock but you don't check if order is somewhere between pageblock=
_order
> and MAX_ORDER_NR_PAGES. How is this safer?
>
Ah, I missed that.

if ((pageblock_order <=3D order) && (order < MAX_ORDER))
          return page + (1 << order);
ok ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
