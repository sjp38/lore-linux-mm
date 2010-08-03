Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 170646008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:42:45 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5509149iwn.14
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 21:47:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100803042835.GA17377@localhost>
References: <20100802124734.GI2486@arachsys.com>
	<AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
	<20100803033108.GA23117@arachsys.com>
	<AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
	<20100803042835.GA17377@localhost>
Date: Tue, 3 Aug 2010 13:47:36 +0900
Message-ID: <AANLkTimC1z0MwTxUjxED7N1-R4D_YXtvnPSbiKXdR+4W@mail.gmail.com>
Subject: Re: Over-eager swapping
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chris Webb <chris@arachsys.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 3, 2010 at 1:28 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Tue, Aug 03, 2010 at 12:09:18PM +0800, Minchan Kim wrote:
>> On Tue, Aug 3, 2010 at 12:31 PM, Chris Webb <chris@arachsys.com> wrote:
>> > Minchan Kim <minchan.kim@gmail.com> writes:
>> >
>> >> Another possibility is _zone_reclaim_ in NUMA.
>> >> Your working set has many anonymous page.
>> >>
>> >> The zone_reclaim set priority to ZONE_RECLAIM_PRIORITY.
>> >> It can make reclaim mode to lumpy so it can page out anon pages.
>> >>
>> >> Could you show me /proc/sys/vm/[zone_reclaim_mode/min_unmapped_ratio]=
 ?
>> >
>> > Sure, no problem. On the machine with the /proc/meminfo I showed earli=
er,
>> > these are
>> >
>> > =A0# cat /proc/sys/vm/zone_reclaim_mode
>> > =A00
>> > =A0# cat /proc/sys/vm/min_unmapped_ratio
>> > =A01
>>
>> if zone_reclaim_mode is zero, it doesn't swap out anon_pages.
>
> If there are lots of order-1 or higher allocations, anonymous pages
> will be randomly evicted, regardless of their LRU ages. This is

I thought swapped out page is huge (ie, 3G) even though it enters lumpy mod=
e.
But it's possible. :)

> probably another factor why the users claim. Are there easy ways to
> confirm this other than patching the kernel?

cat /proc/buddyinfo can help?

Off-topic:
It would be better to add new vmstat of lumpy entrance.

Pseudo code.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f9f624..d10ff4e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1641,7 +1641,7 @@ out:
        }
 }

-static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc)
+static void set_lumpy_reclaim_mode(int priority, struct scan_control
*sc, struct zone *zone)
 {
        /*
         * If we need a large contiguous chunk of memory, or have
@@ -1654,6 +1654,9 @@ static void set_lumpy_reclaim_mode(int priority,
struct scan_control *sc)
                sc->lumpy_reclaim_mode =3D 1;
        else
                sc->lumpy_reclaim_mode =3D 0;
+
+       if (sc->lumpy_reclaim_mode)
+               inc_zone_state(zone, NR_LUMPY);
 }

 /*
@@ -1670,7 +1673,7 @@ static void shrink_zone(int priority, struct zone *zo=
ne,

        get_scan_count(zone, sc, nr, priority);

-       set_lumpy_reclaim_mode(priority, sc);
+       set_lumpy_reclaim_mode(priority, sc, zone);

        while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
                                        nr[LRU_INACTIVE_FILE]) {

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
