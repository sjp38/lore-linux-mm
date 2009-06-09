Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9E1BF6B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:20:59 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so2065184ywm.26
        for <linux-mm@kvack.org>; Tue, 09 Jun 2009 00:48:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090609161925.DD70.A69D9226@jp.fujitsu.com>
References: <20090608165457.fa8d17e6.nishimura@mxp.nes.nec.co.jp>
	 <20090609161330.fcd5facb.nishimura@mxp.nes.nec.co.jp>
	 <20090609161925.DD70.A69D9226@jp.fujitsu.com>
Date: Tue, 9 Jun 2009 16:48:20 +0900
Message-ID: <28c262360906090048x792fb3f9i6678298b693f6c5a@mail.gmail.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH
	mmotm] vmscan: fix may_swap handling for memcg)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, KOSAKI.

As you know, this problem caused by if condition(priority) in shrink_zone.
Let me have a question.

Why do we have to prevent scan value calculation when the priority is zero =
?
As I know, before split-lru, we didn't do it.

Is there any specific issue in case of the priority is zero ?

On Tue, Jun 9, 2009 at 4:20 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > and, too many recliaming pages is not only memcg issue. I don't thin=
k this
>> > > patch provide generic solution.
>> > >
>> > Ah, you're right. It's not only memcg issue.
>> >
>> How about this one ?
>>
>> =3D=3D=3D
>> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>>
>> Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintrod=
uce
>> sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
>>
>> But the result of get_scan_ratio() is ignored when priority =3D=3D 0,
>> so anon lru is scanned even if may_swap =3D=3D 0 or nr_swap_pages =3D=3D=
 0.
>> IMHO, this is not an expected behavior.
>>
>> As for memcg especially, because of this behavior many and many pages ar=
e
>> swapped-out just in vain when oom is invoked by mem+swap limit.
>>
>> This patch is for handling may_swap flag more strictly.
>>
>> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> Looks great.
> your patch doesn't only improve memcg, bug also improve noswap system.
>
> Thanks.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@=
jp.fujitsu.com>
>
>
>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 18 +++++++++---------
>> =C2=A01 files changed, 9 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 2ddcfc8..bacb092 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1407,13 +1407,6 @@ static void get_scan_ratio(struct zone *zone, str=
uct scan_control *sc,
>> =C2=A0 =C2=A0 =C2=A0 unsigned long ap, fp;
>> =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat =3D get_recl=
aim_stat(zone, sc);
>>
>> - =C2=A0 =C2=A0 /* If we have no swap space, do not bother scanning anon=
 pages. */
>> - =C2=A0 =C2=A0 if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[0] =3D 0;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[1] =3D 100;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> - =C2=A0 =C2=A0 }
>> -
>> =C2=A0 =C2=A0 =C2=A0 anon =C2=A0=3D zone_nr_pages(zone, sc, LRU_ACTIVE_A=
NON) +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_nr_pages(zone, sc,=
 LRU_INACTIVE_ANON);
>> =C2=A0 =C2=A0 =C2=A0 file =C2=A0=3D zone_nr_pages(zone, sc, LRU_ACTIVE_F=
ILE) +
>> @@ -1511,15 +1504,22 @@ static void shrink_zone(int priority, struct zon=
e *zone,
>> =C2=A0 =C2=A0 =C2=A0 enum lru_list l;
>> =C2=A0 =C2=A0 =C2=A0 unsigned long nr_reclaimed =3D sc->nr_reclaimed;
>> =C2=A0 =C2=A0 =C2=A0 unsigned long swap_cluster_max =3D sc->swap_cluster=
_max;
>> + =C2=A0 =C2=A0 int noswap =3D 0;
>>
>> - =C2=A0 =C2=A0 get_scan_ratio(zone, sc, percent);
>> + =C2=A0 =C2=A0 /* If we have no swap space, do not bother scanning anon=
 pages. */
>> + =C2=A0 =C2=A0 if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 noswap =3D 1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[0] =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[1] =3D 100;
>> + =C2=A0 =C2=A0 } else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_scan_ratio(zone, sc, per=
cent);
>>
>> =C2=A0 =C2=A0 =C2=A0 for_each_evictable_lru(l) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int file =3D is_file_lr=
u(l);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long scan;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scan =3D zone_nr_pages(=
zone, sc, l);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priority) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priority || noswap) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 scan >>=3D priority;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 scan =3D (scan * percent[file]) / 100;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
