Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 062FF8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 04:01:34 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so42805982pfr.6
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 01:01:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j22sor36216490pll.8.2019.01.07.01.01.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 01:01:32 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <20190107085316.GY31793@dhcp22.suse.cz>
Date: Mon, 7 Jan 2019 17:01:27 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <CF1BB6A7-8650-43F3-82C2-E7C6F309CC90@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
 <20190107085316.GY31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, Yang Shi <shy828301@gmail.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com



> On Jan 7, 2019, at 16:53, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 07-01-19 13:10:17, Fam Zheng wrote:
>>=20
>>=20
>>> On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
>>>=20
>>>=20
>>> drop_caches would drop all page caches globally. You may not want to
>>> drop the page caches used by other memcgs.
>>=20
>> We=E2=80=99ve tried your async force_empty patch (with a modification =
to default it to true to make it transparently enabled for the sake of =
testing), and for the past few days the stale mem cgroups still =
accumulate, up to 40k.
>>=20
>> We=E2=80=99ve double checked that the force_empty routines are =
invoked when a mem cgroup is offlined. But this doesn=E2=80=99t look =
very effective so far. Because, once we do `echo 1 > =
/proc/sys/vm/drop_caches`, all the groups immediately go away.
>>=20
>> This is a bit unexpected.
>>=20
>> Yang, could you hint what are missing in the force_empty operation, =
compared to a blanket drop cache?
>=20
> I would suspect that not all slab pages holding dentries and inodes =
got
> reclaimed during the slab shrinking inoked by the direct reclaimed
> triggered by force emptying.

I don=E2=80=99t think so, we=E2=80=99ve ensured =
cgroup.memory=3Dnokmem,nosocket first, as observed with the result of =
=E2=80=98echo 1=E2=80=99 command. It=E2=80=99s not slabs but the page =
caches holding mem cgroups.

It might well be that we=E2=80=99ve missing 68600f623d6, though. We=E2=80=99=
ll check it.

Thanks,

Fam

> --=20
> Michal Hocko
> SUSE Labs
