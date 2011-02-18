Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 272738D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 17:07:04 -0500 (EST)
Received: by iyf13 with SMTP id 13so704426iyf.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 14:07:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110218165827.GB13246@csn.ul.ie>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<7563767d6b6e841a8ac5f8315ee166e0f039723c.1297940291.git.minchan.kim@gmail.com>
	<20110218165827.GB13246@csn.ul.ie>
Date: Sat, 19 Feb 2011 07:07:01 +0900
Message-ID: <AANLkTikom2dZaE4v2fNBaRV+OKT+0ZF3ZcEnvkRH0oJW@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] add profile information for invalidated page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Mel,

On Sat, Feb 19, 2011 at 1:58 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Feb 18, 2011 at 12:08:22AM +0900, Minchan Kim wrote:
>> This patch adds profile information about invalidated page reclaim.
>> It's just for profiling for test so it is never for merging.
>>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0include/linux/vmstat.h | =C2=A0 =C2=A04 ++--
>> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A03 +++
>> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A03 +++
>> =C2=A03 files changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
>> index 833e676..c38ad95 100644
>> --- a/include/linux/vmstat.h
>> +++ b/include/linux/vmstat.h
>> @@ -30,8 +30,8 @@
>>
>> =C2=A0enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGALLOC),
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFREE, PGACTIVATE, PGDEACTI=
VATE,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFAULT, PGMAJFAULT,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFREE, PGACTIVATE, PGDEACTI=
VATE, PGINVALIDATE,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGRECLAIM, PGFAULT, PGMAJFAU=
LT,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGREFILL)=
,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGSTEAL),
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGSCAN_KS=
WAPD),
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 0a33714..980c17b 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -397,6 +397,7 @@ static void lru_deactivate(struct page *page, struct=
 zone *zone)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* is _really_ sma=
ll and =C2=A0it's non-critical problem.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageReclaim(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __count_vm_event(PGRECLAIM);
>> =C2=A0 =C2=A0 =C2=A0 } else {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The page's writ=
eback ends up during pagevec
>
> Is this name potentially misleading?
>
> Pages that are reclaimed are accounted for with _steal. It's not particul=
arly
> obvious but that's the name it was given. I'd worry that an administrator=
 that
> was not aware of *_steal would read pgreclaim as "pages that were reclaim=
ed"
> when this is not necessarily the case.
>
> Is there a better name for this? pginvalidate_deferred
> or pginvalidate_delayed maybe?
>

Yep. Your suggestion is fair enough. But as I said in description,
It's just for testing for my profiling, not merging so I didn't care
about it.
I don't think we need new vmstat of pginvalidate.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
