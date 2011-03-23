Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0D18D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 02:59:07 -0400 (EDT)
Received: by iyf13 with SMTP id 13so11322486iyf.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 23:59:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110323142133.1AC6.A69D9226@jp.fujitsu.com>
References: <20110322200523.B061.A69D9226@jp.fujitsu.com>
	<20110322144950.GA2628@barrios-desktop>
	<20110323142133.1AC6.A69D9226@jp.fujitsu.com>
Date: Wed, 23 Mar 2011 15:59:04 +0900
Message-ID: <AANLkTim1HcdkPcxnWrv+VbMUSh3kQBC=-myZ-j-a8Wiy@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Mar 23, 2011 at 2:21 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Minchan,
>
>> > zone->all_unreclaimable and zone->pages_scanned are neigher atomic
>> > variables nor protected by lock. Therefore a zone can become a state
>> > of zone->page_scanned=3D0 and zone->all_unreclaimable=3D1. In this cas=
e,
>>
>> Possible although it's very rare.
>
> Can you test by yourself andrey's case on x86 box? It seems
> reprodusable.
>
>> > current all_unreclaimable() return false even though
>> > zone->all_unreclaimabe=3D1.
>>
>> The case is very rare since we reset zone->all_unreclaimabe to zero
>> right before resetting zone->page_scanned to zero.
>> But I admit it's possible.
>
> Please apply this patch and run oom-killer. You may see following
> pages_scanned:0 and all_unreclaimable:yes combination. likes below.
> (but you may need >30min)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Node 0 DMA free:4024kB min:40kB low:48kB high:=
60kB active_anon:11804kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0inactive_anon:0kB active_file:0kB inactive_fil=
e:4kB unevictable:0kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0isolated(anon):0kB isolated(file):0kB present:=
15676kB mlocked:0kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dirty:0kB writeback:0kB mapped:0kB shmem:0kB s=
lab_reclaimable:0kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0slab_unreclaimable:0kB kernel_stack:0kB pageta=
bles:68kB unstable:0kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bounce:0kB writeback_tmp:0kB pages_scanned:0 a=
ll_unreclaimable? yes
>
>
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU 1
>> free_pcppages_bulk =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0balance_pgdat
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->all_unreclaimabe =3D 0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->all_unreclaimabe=
 =3D 1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned =3D 0
>> >
>> > Is this ignorable minor issue? No. Unfortunatelly, x86 has very
>> > small dma zone and it become zone->all_unreclamble=3D1 easily. and
>> > if it becase all_unreclaimable, it never return all_unreclaimable=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^^^^^ it's very important verb. =C2=A0 =C2=
=A0^^^^^ return? reset?
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 I can't understand your point due to the typ=
o. Please correct the typo.
>>
>> > beucase it typicall don't have reclaimable pages.
>>
>> If DMA zone have very small reclaimable pages or zero reclaimable pages,
>> zone_reclaimable() can return false easily so all_unreclaimable() could =
return
>> true. Eventually oom-killer might works.
>
> The point is, vmscan has following all_unreclaimable check in several pla=
ce.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>
> But, if the zone has only a few lru pages, get_scan_count(DEF_PRIORITY) r=
eturn
> {0, 0, 0, 0} array. It mean zone will never scan lru pages anymore. there=
fore
> false negative smaller pages_scanned can't be corrected.
>
> Then, false negative all_unreclaimable() also can't be corrected.
>
>
> btw, Why get_scan_count() return 0 instead 1? Why don't we round up?
> Git log says it is intentionally.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit e0f79b8f1f3394bb344b7b83d6f121ac2af327d=
e
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: Johannes Weiner <hannes@saeurebad.de>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Sat Oct 18 20:26:55 2008 -0700
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vmscan: don't accumulate scan pr=
essure on unrelated lists
>
>>
>> In my test, I saw the livelock, too so apparently we have a problem.
>> I couldn't dig in it recently by another urgent my work.
>> I think you know root cause but the description in this patch isn't enou=
gh
>> for me to be persuaded.
>>
>> Could you explain the root cause in detail?
>
> If you have an another fixing idea, please let me know. :)
>
>
>
>

Okay. I got it.

The problem is following as.
By the race the free_pcppages_bulk and balance_pgdat, it is possible
zone->all_unreclaimable =3D 1 and zone->pages_scanned =3D 0.
DMA zone have few LRU pages and in case of no-swap and big memory
pressure, there could be a just a page in inactive file list like your
example. (anon lru pages isn't important in case of non-swap system)
In such case, shrink_zones doesn't scan the page at all until priority
become 0 as get_scan_count does scan >>=3D priority(it's mostly zero).
And although priority become 0, nr_scan_try_batch returns zero until
saved pages become 32. So for scanning the page, at least, we need 32
times iteration of priority 12..0.  If system has fork-bomb, it is
almost livelock.

If is is right, how about this?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 148c6e6..34983e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1973,6 +1973,9 @@ static void shrink_zones(int priority, struct
zonelist *zonelist,

 static bool zone_reclaimable(struct zone *zone)
 {
+       if (zone->all_unreclaimable)
+               return false;
+
        return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
 }


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
