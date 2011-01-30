Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD10A8D0039
	for <linux-mm@kvack.org>; Sat, 29 Jan 2011 21:26:20 -0500 (EST)
Received: by iyj17 with SMTP id 17so3990958iyj.14
        for <linux-mm@kvack.org>; Sat, 29 Jan 2011 18:26:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128173655.7c1d9ebd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
	<20110128081723.GD2213@cmpxchg.org>
	<AANLkTinikUM09bXbLZ5zU1gdgfdPZSQmbycbbeSyGk59@mail.gmail.com>
	<20110128173655.7c1d9ebd.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 30 Jan 2011 11:26:18 +0900
Message-ID: <AANLkTik=yJnHoZbyjc8bMp_vbGaNdgzvAXY1P5qZ8W6W@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for hugepage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 5:36 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 28 Jan 2011 17:25:58 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Hannes,
>>
>> On Fri, Jan 28, 2011 at 5:17 PM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Fri, Jan 28, 2011 at 05:04:16PM +0900, Minchan Kim wrote:
>> >> Hi Kame,
>> >>
>> >> On Fri, Jan 28, 2011 at 1:58 PM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > How about this ?
>> >> > =3D=3D
>> >> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >> >
>> >> > Current memory cgroup's code tends to assume page_size =3D=3D PAGE_=
SIZE
>> >> > and arrangement for THP is not enough yet.
>> >> >
>> >> > This is one of fixes for supporing THP. This adds
>> >> > mem_cgroup_check_margin() and checks whether there are required amo=
unt of
>> >> > free resource after memory reclaim. By this, THP page allocation
>> >> > can know whether it really succeeded or not and avoid infinite-loop
>> >> > and hangup.
>> >> >
>> >> > Total fixes for do_charge()/reclaim memory will follow this patch.
>> >>
>> >> If this patch is only related to THP, I think patch order isn't good.
>> >> Before applying [2/4], huge page allocation will retry without
>> >> reclaiming and loop forever by below part.
>> >>
>> >> @@ -1854,9 +1858,6 @@ static int __mem_cgroup_do_charge(struct
>> >> =C2=A0 =C2=A0 =C2=A0 } else
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_over_limit =3D m=
em_cgroup_from_res_counter(fail_res, res);
>> >>
>> >> - =C2=A0 =C2=A0 if (csize > PAGE_SIZE) /* change csize and retry */
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return CHARGE_RETRY;
>> >> -
>> >> =C2=A0 =C2=A0 =C2=A0 if (!(gfp_mask & __GFP_WAIT))
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return CHARGE_WOULDB=
LOCK;
>> >>
>> >> Am I missing something?
>> >
>> > No, you are correct. =C2=A0But I am not sure the order really matters =
in
>> > theory: you have two endless loops that need independent fixing.
>>
>> That's why I ask a question.
>> Two endless loop?
>>
>> One is what I mentioned. The other is what?
>> Maybe this patch solve the other.
>> But I can't guess it by only this description. Stupid..
>>
>> Please open my eyes.
>>
>
> One is.
>
> =C2=A0if (csize > PAGE_SIZE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return CHARGE_RETRY;
>
> By this, reclaim will never be called.
>
>
> Another is a check after memory reclaim.
> =3D=3D
> =C2=A0 =C2=A0 =C2=A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_lim=
it, NULL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gfp_mask,=
 flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * try_to_free_mem_cgroup_pages() might not gi=
ve us a full
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * picture of reclaim. Some pages are reclaime=
d and might be
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * moved to swap cache or just unmapped from t=
he cgroup.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Check the limit again to see if the reclaim=
 reduced the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * current usage of the cgroup before giving u=
p
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret || mem_cgroup_check_under_limit(mem_ov=
er_limit))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return CHARGE_RETR=
Y;
> =3D=3D
>
> ret !=3D 0 if one page is reclaimed. Then, khupaged will retry charge and
> cannot get enough room, reclaim, one page -> again. SO, in busy memcg,
> HPAGE_SIZE allocation never fails.
>
> Even if khupaged luckly allocates HPAGE_SIZE, because khugepaged walks vm=
as
> one by one and try to collapse each pmd, under mmap_sem(), this seems a h=
ang by
> khugepaged, infinite loop.
>
>
> Thanks,
> -Kame
>
>

Kame, Hannes, Thanks.

I understood yours opinion. :)
As I said earlier, at least, it can help patch review.
When I saw only [1/4] firstly, I felt it doesn't affect anything since
THP allocation would return earlier before reaching the your patch so
infinite loop still happens.

Of course, when we apply [2/4], the problem will be gone.
But I can't know the fact until I read [2/4]. It makes reviewers confuse.

So I suggest [2/4] is ahead of [1/4] and includes following as in [2/4].
"This patch still has a infinite problem in case of xxxx. Next patch solves=
 it"

I hope if it doesn't have a problem on bisect, patch order would be
changed if you don't mind. When I review Hannes's version, it's same.
:(

I will review again when Hannes resends the series.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
