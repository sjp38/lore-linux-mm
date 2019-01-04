Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2448E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 05:35:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so36874335pfe.0
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 02:35:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h66sor26059132plb.46.2019.01.04.02.35.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 02:35:42 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <20190104101216.GM31793@dhcp22.suse.cz>
Date: Fri, 4 Jan 2019 18:35:35 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <6EBEAC88-6309-4D8F-97CA-78DC1C9AF3AC@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <20190104090441.GI31793@dhcp22.suse.cz>
 <E699E11E-32B9-4061-93BD-54FE52F972BA@bytedance.com>
 <20190104101216.GM31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>



> On Jan 4, 2019, at 18:12, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Fri 04-01-19 18:02:19, Fam Zheng wrote:
>>=20
>>=20
>>> On Jan 4, 2019, at 17:04, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> This is a natural side effect of shared memory, I am afraid. =
Isolated
>>> memory cgroups should limit any shared resources to bare minimum. =
You
>>> will get "who touches first gets charged" behavior otherwise and =
that is
>>> not really deterministic.
>>=20
>> I don=E2=80=99t quite understand your comment. I think the current =
behavior
>> for the ext4_inode_cachep slab family is just =E2=80=9Cwho touches =
first
>> gets charged=E2=80=9D, and later users of the same file from a =
different mem
>> cgroup can benefit from the cache, keep it from being released, but
>> doesn=E2=80=99t get charged.
>=20
> Yes, this is exactly what I've said. And that leads to =
non-deterministic
> behavior because users from other memcgs are keeping charges alive and
> the isolation really doesn't work properly. Think of it as using =
memory
> on behalf of other party that is supposed to be isolated from you.
>=20
> Sure this can work reasonably well if the sharing is not really
> predominated.

OK, I see what you mean. The reality is that the applications want to =
share files (e.g. docker run -v ...) , and IMO charging accuracy is not =
the trouble here. The problem is that there are memory usages which are =
not strictly necessary once a mem cgroup is deleted, such as the biggish =
struct mem_cgroup and the shadow slabs from which we no longer alloc new =
objects.

Fam

> --=20
> Michal Hocko
> SUSE Labs
