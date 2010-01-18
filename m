Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CEC8C6B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:10:59 -0500 (EST)
Received: by pzk34 with SMTP id 34so1920117pzk.11
        for <linux-mm@kvack.org>; Sun, 17 Jan 2010 18:10:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100118104910.AE2D.A69D9226@jp.fujitsu.com>
References: <20100118100359.AE22.A69D9226@jp.fujitsu.com>
	 <28c262361001171747w450c8fd8j4daf84b72fb68e1a@mail.gmail.com>
	 <20100118104910.AE2D.A69D9226@jp.fujitsu.com>
Date: Mon, 18 Jan 2010 11:10:56 +0900
Message-ID: <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

I missed Cc.

On Mon, Jan 18, 2010 at 10:54 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, KOSAKI.
>>
>> On Mon, Jan 18, 2010 at 10:04 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> Hi, KOSAKI.
>> >>
>> >> On Thu, Jan 14, 2010 at 2:18 PM, KOSAKI Motohiro
>> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >> > Well. zone->lock and zone->lru_lock should be not taked at the s=
ame time.
>> >> >>
>> >> >> I looked over the code since I am out of office.
>> >> >> I can't find any locking problem zone->lock and zone->lru_lock.
>> >> >> Do you know any locking order problem?
>> >> >> Could you explain it with call graph if you don't mind?
>> >> >>
>> >> >> I am out of office by tomorrow so I can't reply quickly.
>> >> >> Sorry for late reponse.
>> >> >
>> >> > This is not lock order issue. both zone->lock and zone->lru_lock ar=
e
>> >> > hotpath lock. then, same tame grabbing might cause performance impa=
ct.
>> >>
>> >> Sorry for late response.
>> >>
>> >> Your patch makes get_anon_scan_ratio of zoneinfo stale.
>> >> What you said about performance impact is effective when VM pressure =
high.
>> >> I think stale data is all right normally.
>> >> But when VM pressure is high and we want to see the information in zo=
neinfo(
>> >> this case is what you said), stale data is not a good, I think.
>> >>
>> >> If it's not a strong argue, I want to use old get_scan_ratio
>> >> in get_anon_scan_ratio.
>> >
>> > please looks such function again.
>> >
>> > usally we use recent_rotated/recent_scanned ratio. then following
>> > decreasing doesn't change any scan-ratio meaning. it only prevent
>> > stat overflow.
>>
>> It has a primary role that floating average as well as prevenitng overfl=
ow. :)
>> So, It's important.
>>
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(reclaim_stat->recent_scanned[0=
] > anon / 4)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&=
zone->lru_lock);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_stat->r=
ecent_scanned[0] /=3D 2;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_stat->r=
ecent_rotated[0] /=3D 2;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq=
(&zone->lru_lock);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> >
>> > So, I don't think current implementation can show stale data.
>>
>> It can make stale data when high memory pressure happens.
>
> ?? why? and when?
> I think it depend on what's stale mean.
>
> Currently(i.e. before the patch), get_scan_ratio have following fomula.
> in such region, recent_scanned is not protected by zone->lru_lock.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ap =3D (anon_prio + 1) * (reclaim_stat->recent=
_scanned[0] + 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ap /=3D reclaim_stat->recent_rotated[0] + 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fp =3D (file_prio + 1) * (reclaim_stat->recent=
_scanned[1] + 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fp /=3D reclaim_stat->recent_rotated[1] + 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[0] =3D 100 * ap / (ap + fp + 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[1] =3D 100 - percent[0];
>
> It mean, shrink_zone() doesn't use exactly recent_scanned value. then
> zoneinfo can use the same unexactly value.

Absoultely right. I missed that. Thanks.
get_scan_ratio used lru_lock to get reclaim_stat->recent_xxxx.
But, it doesn't used lru_lock to get ap/fp.

Is it intentional? I think you or Rik know it. :)
I think if we want to get exact value, we have to use lru_lock until
getting ap/fp.
If it isn't, we don't need lru_lock when we get the reclaim_stat->recent_xx=
xx.

What do you think about it?

>
>
>> Moreever, I don't want to make complicate thing(ie, need_update)
>> than old if it doesn't have some benefit.(I think lru_lock isn't big ove=
rhead)
>
> Hmm..
> I think lru_lock can makes big overhead.

I don't want to argue strongly about this.
That's because i don't have seen that.
If you have a conern about lru_lock, I don't opposed your patch.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
