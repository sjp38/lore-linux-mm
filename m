Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 84DE9900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:15:04 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2613900qwa.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 08:15:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428084820.GH12437@cmpxchg.org>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<4dc5e63cfc8672426336e43dea29057d5bb6e863.1303833417.git.minchan.kim@gmail.com>
	<20110428084820.GH12437@cmpxchg.org>
Date: Sat, 30 Apr 2011 00:15:01 +0900
Message-ID: <BANLkTina+YuDgACZfDV8T_Lnipo50J6zVA@mail.gmail.com>
Subject: Re: [RFC 2/8] compaction: make isolate_lru_page with filter aware
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Hi Hannes,

On Thu, Apr 28, 2011 at 5:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Apr 27, 2011 at 01:25:19AM +0900, Minchan Kim wrote:
>> In async mode, compaction doesn't migrate dirty or writeback pages.
>> So, it's meaningless to pick the page and re-add it to lru list.
>>
>> Of course, when we isolate the page in compaction, the page might
>> be dirty or writeback but when we try to migrate the page, the page
>> would be not dirty, writeback. So it could be migrated. But it's
>> very unlikely as isolate and migration cycle is much faster than
>> writeout.
>>
>> So, this patch helps cpu and prevent unnecessary LRU churning.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/compaction.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index dea32e3..9f80b5a 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -335,7 +335,7 @@ static unsigned long isolate_migratepages(struct zon=
e *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Try isolate the page=
 */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page(page,=
 ISOLATE_BOTH, 0, 0, 0) !=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page(page,=
 ISOLATE_BOTH, 0, !cc->sync, 0) !=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>
> With the suggested flags argument from 1/8, this would look like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0flags =3D ISOLATE_BOTH;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cc->sync)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flags |=3D ISOLATE=
_CLEAN;
>
> ?

Yes. I will change it.

>
> Anyway, nice change indeed!

Thanks!


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
