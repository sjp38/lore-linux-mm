Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 092206B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 20:52:34 -0400 (EDT)
Received: by iwn10 with SMTP id 10so787407iwn.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 17:52:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100805141706.GB2985@barrios-desktop>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
	<20100805151304.31C0.A69D9226@jp.fujitsu.com>
	<20100805141706.GB2985@barrios-desktop>
Date: Fri, 6 Aug 2010 09:52:37 +0900
Message-ID: <AANLkTimYxERF5Gj300tKyF-DANQ4dae-wHpadf2putyh@mail.gmail.com>
Subject: Re: [PATCH 3/7] vmscan: synchrounous lumpy reclaim use lock_page()
	instead trylock_page()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 5, 2010 at 11:17 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Aug 05, 2010 at 03:13:39PM +0900, KOSAKI Motohiro wrote:
>> When synchrounous lumpy reclaim, there is no reason to give up to
>> reclaim pages even if page is locked. We use lock_page() instead
>> trylock_page() in this case.
>>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> ---
>> =A0mm/vmscan.c | =A0 =A04 +++-
>> =A01 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 1cdc3db..833b6ad 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -665,7 +665,9 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_to_page(page_list);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_page(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sync_writeback =3D=3D PAGEOUT_IO_SYNC)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else if (!trylock_page(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(PageActive(page));
>> --
>> 1.6.5.2
>>
>>
>>
>
> Hmm. We can make sure lumpy already doesn't select the page locked?
> I mean below scenario.
>
> LRU head -> page A -> page B -> LRU tail
>
> lock_page(page A)
> some_function()
> direct reclaim
> select victim page B
> enter lumpy mode
> select victim page A as well as page B
> shrink_page_list
> lock_page(page A)
>
>
> --
> Kind regards,
> Minchan Kim
>

Ignore above comment.
lock_page doesn't have a deadlock problem. My bad.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
