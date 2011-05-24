Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC8A56B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:34:23 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1471945qyk.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 18:34:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=wVOPSv1BA_mZq9=r14Vu3kUh3_w@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
	<20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520101120.GC11729@random.random>
	<BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com>
	<20110520153346.GA1843@barrios-desktop>
	<BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com>
	<20110520161934.GA2386@barrios-desktop>
	<BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
	<BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
	<BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com>
	<BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
	<BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com>
	<BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
	<BANLkTi=wVOPSv1BA_mZq9=r14Vu3kUh3_w@mail.gmail.com>
Date: Tue, 24 May 2011 10:34:21 +0900
Message-ID: <BANLkTimw23VP4yyuDed-KrLEcnfLMMA-fQ@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Tue, May 24, 2011 at 10:19 AM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Sun, May 22, 2011 at 7:12 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> Could you test below patch based on vanilla 2.6.38.6?
>> The expect result is that system hang never should happen.
>> I hope this is last test about hang.
>>
>> Thanks.
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 292582c..1663d24 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -231,8 +231,11 @@ unsigned long shrink_slab(struct shrink_control *sh=
rink,
>> =C2=A0 =C2=A0 =C2=A0 if (scanned =3D=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scanned =3D SWAP_CLUSTE=
R_MAX;
>>
>> - =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem))
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1; =C2=A0 =C2=
=A0 =C2=A0 /* Assume we'll be able to shrink next time */
>> + =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Assume we'll be ab=
le to shrink next time */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> + =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(shrinker, &shrinker_list, list)=
 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long long delt=
a;
>> @@ -286,6 +289,8 @@ unsigned long shrink_slab(struct shrink_control *shr=
ink,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrinker->nr +=3D total=
_scan;
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 up_read(&shrinker_rwsem);
>> +out:
>> + =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> =C2=A0 =C2=A0 =C2=A0 return ret;
>> =C2=A0}
>>
>> @@ -2331,7 +2336,7 @@ static bool sleeping_prematurely(pg_data_t
>> *pgdat, int order, long remaining,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* must be balanced
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 if (order)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return pgdat_balanced=
(pgdat, balanced, classzone_idx);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !pgdat_balance=
d(pgdat, balanced, classzone_idx);
>> =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !all_zones_ok;
>> =C2=A0}
>
> So far with this patch I can't reproduce the hang or the bogus OOM.
>
> To be completely clear, I have COMPACTION, MIGRATION, and THP off, I'm
> running 2.6.38.6, and I have exactly two patches applied. =C2=A0One is th=
e
> attached patch and the other is a the fpu.ko/aesni_intel.ko merger
> which I need to get dracut to boot my box.
>
> For fun, I also upgraded to 8GB of RAM and it still works.
>

Hmm. Could you test it with enable thp and 2G RAM?
Isn't it a original test environment?
Please don't change test environment. :)

Thanks for your effort, Andrew.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
