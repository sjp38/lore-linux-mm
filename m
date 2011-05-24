Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BBD6A6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:34:44 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4634387qwa.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 01:34:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDB3A1E.6090206@jp.fujitsu.com>
References: <4DCDA347.9080207@cray.com>
	<BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
	<4DD2991B.5040707@cray.com>
	<BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>
	<20110520164924.GB2386@barrios-desktop>
	<4DDB3A1E.6090206@jp.fujitsu.com>
Date: Tue, 24 May 2011 17:34:40 +0900
Message-ID: <BANLkTinkcu5j1H8tHNT4aTmOL-GXfSwPQw@mail.gmail.com>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc: patch.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

On Tue, May 24, 2011 at 1:54 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>>From 8bd3f16736548375238161d1bd85f7d7c381031f Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan.kim@gmail.com>
>> Date: Sat, 21 May 2011 01:37:41 +0900
>> Subject: [PATCH] Prevent unending loop in __alloc_pages_slowpath
>>
>> From: Andrew Barry <abarry@cray.com>
>>
>> I believe I found a problem in __alloc_pages_slowpath, which allows a pr=
ocess to
>> get stuck endlessly looping, even when lots of memory is available.
>>
>> Running an I/O and memory intensive stress-test I see a 0-order page all=
ocation
>> with __GFP_IO and __GFP_WAIT, running on a system with very little free =
memory.
>> Right about the same time that the stress-test gets killed by the OOM-ki=
ller,
>> the utility trying to allocate memory gets stuck in __alloc_pages_slowpa=
th even
>> though most of the systems memory was freed by the oom-kill of the stres=
s-test.
>>
>> The utility ends up looping from the rebalance label down through the
>> wait_iff_congested continiously. Because order=3D0, __alloc_pages_direct=
_compact
>> skips the call to get_page_from_freelist. Because all of the reclaimable=
 memory
>> on the system has already been reclaimed, __alloc_pages_direct_reclaim s=
kips the
>> call to get_page_from_freelist. Since there is no __GFP_FS flag, the blo=
ck with
>> __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, =
then
>> jumps back to rebalance without ever trying to get_page_from_freelist. T=
his loop
>> repeats infinitely.
>>
>> The test case is pretty pathological. Running a mix of I/O stress-tests =
that do
>> a lot of fork() and consume all of the system memory, I can pretty relia=
bly hit
>> this on 600 nodes, in about 12 hours. 32GB/node.
>>
>> Signed-off-by: Andrew Barry <abarry@cray.com>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> ---
>> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3f8bce2..e78b324 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2064,6 +2064,7 @@ restart:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 first_zones_zonelist(zo=
nelist, high_zoneidx, NULL,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &preferred_z=
one);
>>
>> +rebalance:
>> =C2=A0 =C2=A0 =C2=A0 /* This is the last chance, in general, before the =
goto nopage. */
>> =C2=A0 =C2=A0 =C2=A0 page =3D get_page_from_freelist(gfp_mask, nodemask,=
 order, zonelist,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
>> @@ -2071,7 +2072,6 @@ restart:
>> =C2=A0 =C2=A0 =C2=A0 if (page)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto got_pg;
>>
>> -rebalance:
>> =C2=A0 =C2=A0 =C2=A0 /* Allocate without watermarks if the context allow=
s */
>> =C2=A0 =C2=A0 =C2=A0 if (alloc_flags & ALLOC_NO_WATERMARKS) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D __alloc_pages_=
high_priority(gfp_mask, order,
>
> I'm sorry I missed this thread long time.

No problem. It would be better than not review.

>
> In this case, I think we should call drain_all_pages(). then following
> patch is better.

Strictly speaking, this problem isn't related to drain_all_pages.
This problem caused by lru empty but I admit it could work well if
your patch applied.
So yours could help, too.

> However I also think your patch is valuable. because while the task is
> sleeping in wait_iff_congested(), an another task may free some pages.
> thus, rebalance path should try to get free pages. iow, you makes sense.

Yes.
Off-topic.
I would like to move cond_resched below get_page_from_freelist in
__alloc_pages_direct_reclaim. Otherwise, it is likely we can be stolen
pages to other processes.
One more benefit is that if it's apparently OOM path(ie,
did_some_progress =3D 0), we can reduce OOM kill latency due to remove
unnecessary cond_resched.

>
> So, I'd like to propose to merge both your and my patch.

Recently, there was discussion on drain_all_pages with Wu.
He saw much overhead in 8-core system, AFAIR.
I Cced Wu.

How about checking per-cpu before calling drain_all_pages() than
unconditional calling?
if (per_cpu_ptr(zone->pageset, smp_processor_id())
    drain_all_pages();

Of course, It can miss other CPU free pages. But above routine assume
local cpu direct reclaim is successful but it failed by per-cpu. So I
think it works.

Thanks for good suggestion and Reviewed-by, KOSAKI.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
