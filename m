Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 04BEA6B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 20:47:21 -0500 (EST)
Received: by pwj10 with SMTP id 10so1772656pwj.6
        for <linux-mm@kvack.org>; Sun, 17 Jan 2010 17:47:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100118100359.AE22.A69D9226@jp.fujitsu.com>
References: <20100114141735.672B.A69D9226@jp.fujitsu.com>
	 <28c262361001150923l138f6805t22546887bf81b283@mail.gmail.com>
	 <20100118100359.AE22.A69D9226@jp.fujitsu.com>
Date: Mon, 18 Jan 2010 10:47:20 +0900
Message-ID: <28c262361001171747w450c8fd8j4daf84b72fb68e1a@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, KOSAKI.

On Mon, Jan 18, 2010 at 10:04 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, KOSAKI.
>>
>> On Thu, Jan 14, 2010 at 2:18 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> > Well. zone->lock and zone->lru_lock should be not taked at the same=
 time.
>> >>
>> >> I looked over the code since I am out of office.
>> >> I can't find any locking problem zone->lock and zone->lru_lock.
>> >> Do you know any locking order problem?
>> >> Could you explain it with call graph if you don't mind?
>> >>
>> >> I am out of office by tomorrow so I can't reply quickly.
>> >> Sorry for late reponse.
>> >
>> > This is not lock order issue. both zone->lock and zone->lru_lock are
>> > hotpath lock. then, same tame grabbing might cause performance impact.
>>
>> Sorry for late response.
>>
>> Your patch makes get_anon_scan_ratio of zoneinfo stale.
>> What you said about performance impact is effective when VM pressure hig=
h.
>> I think stale data is all right normally.
>> But when VM pressure is high and we want to see the information in zonei=
nfo(
>> this case is what you said), stale data is not a good, I think.
>>
>> If it's not a strong argue, I want to use old get_scan_ratio
>> in get_anon_scan_ratio.
>
> please looks such function again.
>
> usally we use recent_rotated/recent_scanned ratio. then following
> decreasing doesn't change any scan-ratio meaning. it only prevent
> stat overflow.

It has a primary role that floating average as well as prevenitng overflow.=
 :)
So, It's important.

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(reclaim_stat->recent_scanned[0] >=
 anon / 4)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&zon=
e->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_stat->rece=
nt_scanned[0] /=3D 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_stat->rece=
nt_rotated[0] /=3D 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&z=
one->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>
> So, I don't think current implementation can show stale data.

It can make stale data when high memory pressure happens.

>
> Thanks.
>

Moreever, I don't want to make complicate thing(ie, need_update)
than old if it doesn't have some benefit.(I think lru_lock isn't big overhe=
ad)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
