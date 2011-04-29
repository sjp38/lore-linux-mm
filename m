Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 280C4900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:18:04 -0400 (EDT)
Received: by qyk2 with SMTP id 2so386497qyk.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 08:18:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428103505.GS4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
	<20110428103505.GS4658@suse.de>
Date: Sat, 30 Apr 2011 00:18:02 +0900
Message-ID: <BANLkTi=kLjZRp+kxrhG8Q-bEFw7x-O6vgg@mail.gmail.com>
Subject: Re: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Apr 28, 2011 at 7:35 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Apr 27, 2011 at 01:25:20AM +0900, Minchan Kim wrote:
>> In some __zone_reclaim case, we don't want to shrink mapped page.
>> Nonetheless, we have isolated mapped page and re-add it into
>> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
>>
>> Of course, when we isolate the page, the page might be mapped but
>> when we try to migrate the page, the page would be not mapped.
>> So it could be migrated. But race is rare and although it happens,
>> it's no big deal.
>>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
>> index 71d2da9..e8d6190 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1147,7 +1147,8 @@ static unsigned long isolate_lru_pages(unsigned lo=
ng nr_to_scan,
>>
>> =C2=A0static unsigned long isolate_pages_global(unsigned long nr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_=
head *dst,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *scan=
ned, int order,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *scan=
ned,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct scan_control=
 *sc,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int mode, st=
ruct zone *z,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, =
int file)
>> =C2=A0{
>> @@ -1156,8 +1157,8 @@ static unsigned long isolate_pages_global(unsigned=
 long nr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru +=3D LRU_ACTIVE;
>> =C2=A0 =C2=A0 =C2=A0 if (file)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru +=3D LRU_FILE;
>> - =C2=A0 =C2=A0 return isolate_lru_pages(nr, &z->lru[lru].list, dst, sca=
nned, order,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mode, file, 0, 0);
>> + =C2=A0 =C2=A0 return isolate_lru_pages(nr, &z->lru[lru].list, dst, sca=
nned, sc->order,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mode, file, 0, !sc-=
>may_unmap);
>> =C2=A0}
>>
>
> Why not take may_writepage into account for dirty pages?

I missed it.
I will consider it in next version.
Thanks, Mel.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
