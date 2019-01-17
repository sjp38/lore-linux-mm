Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF6C8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:41:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g13so5149845plo.10
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:41:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k11sor289032pll.39.2019.01.16.18.41.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 18:41:37 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <CAHbLzkoy02EvyrDv3v5zFpFRZ0XCg0HZr85nG=rge5nPPGHqjA@mail.gmail.com>
Date: Thu, 17 Jan 2019 10:41:31 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <99AFB530-E90E-4784-B199-FA3F91171649@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
 <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
 <CAHbLzkpHst6bA=eVjoHRFuCuOfo8kKnCPE7Tg4voaJ_kwruVqw@mail.gmail.com>
 <C7C72217-D4AF-474C-A98E-975E389BC85C@bytedance.com>
 <CAHbLzkoy02EvyrDv3v5zFpFRZ0XCg0HZr85nG=rge5nPPGHqjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com



> On Jan 17, 2019, at 05:06, Yang Shi <shy828301@gmail.com> wrote:
>=20
> On Tue, Jan 15, 2019 at 7:52 PM Fam Zheng <zhengfeiran@bytedance.com> =
wrote:
>>=20
>>=20
>>=20
>>> On Jan 16, 2019, at 08:50, Yang Shi <shy828301@gmail.com> wrote:
>>>=20
>>> On Thu, Jan 10, 2019 at 12:30 AM Fam Zheng =
<zhengfeiran@bytedance.com> wrote:
>>>>=20
>>>>=20
>>>>=20
>>>>> On Jan 10, 2019, at 13:36, Yang Shi <shy828301@gmail.com> wrote:
>>>>>=20
>>>>> On Sun, Jan 6, 2019 at 9:10 PM Fam Zheng =
<zhengfeiran@bytedance.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>>> On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
>>>>>>>=20
>>>>>>>=20
>>>>>>> drop_caches would drop all page caches globally. You may not =
want to
>>>>>>> drop the page caches used by other memcgs.
>>>>>>=20
>>>>>> We=E2=80=99ve tried your async force_empty patch (with a =
modification to default it to true to make it transparently enabled for =
the sake of testing), and for the past few days the stale mem cgroups =
still accumulate, up to 40k.
>>>>>>=20
>>>>>> We=E2=80=99ve double checked that the force_empty routines are =
invoked when a mem cgroup is offlined. But this doesn=E2=80=99t look =
very effective so far. Because, once we do `echo 1 > =
/proc/sys/vm/drop_caches`, all the groups immediately go away.
>>>>>>=20
>>>>>> This is a bit unexpected.
>>>>>>=20
>>>>>> Yang, could you hint what are missing in the force_empty =
operation, compared to a blanket drop cache?
>>>>>=20
>>>>> Drop caches does invalidate pages inode by inode. But, memcg
>>>>> force_empty does call memcg direct reclaim.
>>>>=20
>>>> But force_empty touches things that drop_caches doesn=E2=80=99t? If =
so then maybe combining both approaches is more reliable. Since like you =
said,
>>>=20
>>> AFAICS, force_empty may unmap pages, but drop_caches doesn't.
>>>=20
>>>> dropping _all_ pages is usually too much thus not desired, we may =
want to somehow limit the dropped caches to those that are in the memory =
cgroup in question. What do you think?
>>>=20
>>> This is what force_empty is supposed to do.  But, as your test shows
>>> some page cache may still remain after force_empty, then cause =
offline
>>> memcgs accumulated.  I haven't figured out what happened.  You may =
try
>>> what Michal suggested.
>>=20
>> None of the existing patches helped so far, but we suspect that the =
pages cannot be locked at the force_empty moment. We have being working =
on a =E2=80=9Cretry=E2=80=9D patch which does solve the problem. We=E2=80=99=
ll do more tracing (to have a better understanding of the issue) and =
post the findings and/or the patch later. Thanks.
>=20
> You mean it solves the problem by retrying more times?  Actually, I'm
> not sure if you have swap setup in your test, but force_empty does do
> swap if swap is on. This may cause it can't reclaim all the page cache
> in 5 retries.  I have a patch within that series to skip swap.

Basically yes, retrying solves the problem. But compared to immediate =
retries, a scheduled retry in a few seconds is much more effective.

We don=E2=80=99t have swap on.

What do you mean by 5 retries? I=E2=80=99m still a bit lost in the LRU =
code and patches.

>=20
> Yang
>=20
>>=20
>> Fam
>>=20
>>>=20
>>> Yang
>>>=20
>>>>=20
>>>>=20
>>>>>=20
>>>>> Offlined memcgs will not go away if there is still page charged. =
Maybe
>>>>> relate to per cpu memcg stock. I recall there are some commits =
which
>>>>> do solve the per cpu page counter cache problem.
>>>>>=20
>>>>> 591edfb10a94 mm: drain memcg stocks on css offlining
>>>>> d12c60f64cf8 mm: memcontrol: drain memcg stock on force_empty
>>>>> bb4a7ea2b144 mm: memcontrol: drain stocks on resize limit
>>>>>=20
>>>>> Not sure if they would help out.
>>>>=20
>>>> These are all in 4.20, which is tested but not helpful.
>>>>=20
>>>> Fam
