Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 647706B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 21:37:16 -0400 (EDT)
Received: by ywh40 with SMTP id 40so944008ywh.8
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 18:37:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090903140602.e0169ffc.akpm@linux-foundation.org>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
	 <20090903140602.e0169ffc.akpm@linux-foundation.org>
Date: Fri, 4 Sep 2009 10:37:17 +0900
Message-ID: <28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
	sc->isolate_pages() return value.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vincent Li <macli@brc.ubc.ca>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 4, 2009 at 6:06 AM, Andrew Morton<akpm@linux-foundation.org> wr=
ote:
> On Wed, =C2=A02 Sep 2009 16:49:25 -0700
> Vincent Li <macli@brc.ubc.ca> wrote:
>
>> If we can't isolate pages from LRU list, we don't have to account page m=
ovement, either.
>> Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
>>
>> This patch removes unnecessary overhead of page accounting
>> and locking in shrink_active_list as follow-up work of commit 5343daceec=
.
>>
>> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A09 +++++++--
>> =C2=A01 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 460a6f7..2d1c846 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_p=
ages, struct zone *zone,
>> =C2=A0 =C2=A0 =C2=A0 if (scanning_global_lru(sc)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned +=
=3D pgscanned;
>> =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>> -
>> =C2=A0 =C2=A0 =C2=A0 __count_zone_vm_events(PGREFILL, zone, pgscanned);
>> +
>> + =C2=A0 =C2=A0 if (nr_taken =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto done;
>> +
>> + =C2=A0 =C2=A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>> =C2=A0 =C2=A0 =C2=A0 if (file)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(z=
one, NR_ACTIVE_FILE, -nr_taken);
>> =C2=A0 =C2=A0 =C2=A0 else
>> @@ -1383,6 +1386,8 @@ static void shrink_active_list(unsigned long nr_pa=
ges, struct zone *zone,
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_ANON + file=
, -nr_taken);
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, LRU_ACTIVE + file * LRU=
_FILE, nr_rotated);
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, LRU_BASE + file * LRU_F=
ILE, nr_deactivated);
>> +
>> +done:
>> =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
>> =C2=A0}
>
> How do we know this patch is a net gain?
>
> IOW, with what frequency is `nr_taken' zero here?

I think It's not so simple.

In fact, the probability of (nr_taken =3D=3D 0)
would be very low in active list.

If we verify the benefit, we have to measure trade-off between
loss of compare instruction in most case and
gain of avoiding unnecessary overheads in rare case through
micro-benchmark. I don't know which benchmark can do it.

but if we can know the number of frequent and it's very low,
we can add 'unlikely(if (nr_taken=3D=3D0))' at least, I think.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
