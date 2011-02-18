Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6432A8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 18:38:38 -0500 (EST)
Received: by iwl42 with SMTP id 42so854369iwl.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 15:38:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110218231732.GC13246@csn.ul.ie>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<7563767d6b6e841a8ac5f8315ee166e0f039723c.1297940291.git.minchan.kim@gmail.com>
	<20110218165827.GB13246@csn.ul.ie>
	<AANLkTikom2dZaE4v2fNBaRV+OKT+0ZF3ZcEnvkRH0oJW@mail.gmail.com>
	<20110218231732.GC13246@csn.ul.ie>
Date: Sat, 19 Feb 2011 08:38:36 +0900
Message-ID: <AANLkTikDsDs5vBC6iG92o787jB9yFRnLc3NEuX4-6nCs@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] add profile information for invalidated page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat, Feb 19, 2011 at 8:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Sat, Feb 19, 2011 at 07:07:01AM +0900, Minchan Kim wrote:
>> Hi Mel,
>>
>> On Sat, Feb 19, 2011 at 1:58 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On Fri, Feb 18, 2011 at 12:08:22AM +0900, Minchan Kim wrote:
>> >> This patch adds profile information about invalidated page reclaim.
>> >> It's just for profiling for test so it is never for merging.
>> >>
>> >> Acked-by: Rik van Riel <riel@redhat.com>
>> >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> >> Cc: Nick Piggin <npiggin@kernel.dk>
>> >> Cc: Mel Gorman <mel@csn.ul.ie>
>> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> >> ---
>> >> =C2=A0include/linux/vmstat.h | =C2=A0 =C2=A04 ++--
>> >> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A03 +++
>> >> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A03 +++
>> >> =C2=A03 files changed, 8 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
>> >> index 833e676..c38ad95 100644
>> >> --- a/include/linux/vmstat.h
>> >> +++ b/include/linux/vmstat.h
>> >> @@ -30,8 +30,8 @@
>> >>
>> >> =C2=A0enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGALLO=
C),
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFREE, PGACTIVATE, PGDEA=
CTIVATE,
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFAULT, PGMAJFAULT,
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGFREE, PGACTIVATE, PGDEA=
CTIVATE, PGINVALIDATE,
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGRECLAIM, PGFAULT, PGMAJ=
FAULT,
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGREFI=
LL),
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGSTEA=
L),
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FOR_ALL_ZONES(PGSCAN=
_KSWAPD),
>> >> diff --git a/mm/swap.c b/mm/swap.c
>> >> index 0a33714..980c17b 100644
>> >> --- a/mm/swap.c
>> >> +++ b/mm/swap.c
>> >> @@ -397,6 +397,7 @@ static void lru_deactivate(struct page *page, str=
uct zone *zone)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* is _really_ =
small and =C2=A0it's non-critical problem.
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageReclaim(page)=
;
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __count_vm_event(PGRECLAI=
M);
>> >> =C2=A0 =C2=A0 =C2=A0 } else {
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The page's w=
riteback ends up during pagevec
>> >
>> > Is this name potentially misleading?
>> >
>> > Pages that are reclaimed are accounted for with _steal. It's not parti=
cularly
>> > obvious but that's the name it was given. I'd worry that an administra=
tor that
>> > was not aware of *_steal would read pgreclaim as "pages that were recl=
aimed"
>> > when this is not necessarily the case.
>> >
>> > Is there a better name for this? pginvalidate_deferred
>> > or pginvalidate_delayed maybe?
>> >
>>
>> Yep. Your suggestion is fair enough. But as I said in description,
>> It's just for testing for my profiling, not merging so I didn't care
>> about it. I don't think we need new vmstat of pginvalidate.
>>
>
> My bad. I was treating this piece of information as something we'd keep
> around and did not read the introduction clearly enough. If it's just for
> evaluation, the name does not matter as long as the reviewers know what i=
t
> is. The figures look good and I have no problem with the series. I didn't
> ack the memcg parts but only because memcg is not an area I'm familiar en=
ough
> for my ack to proper meaning. If there are no other objections, I'd sugge=
st
> resubmitting minus this patch.

Okay. I will wait any comments from others by this week and resubmit
the series at next week as remove profiling patch.
Thanks, Mel.

>
> Thanks.
>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
