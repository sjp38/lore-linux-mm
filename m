Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4DCF8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 00:00:55 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so43754164qtj.21
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 21:00:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n45sor50845173qtc.52.2019.01.03.21.00.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 21:00:54 -0800 (PST)
MIME-Version: 1.0
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com> <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
In-Reply-To: <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 3 Jan 2019 21:00:43 -0800
Message-ID: <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>

On Thu, Jan 3, 2019 at 8:45 PM Fam Zheng <zhengfeiran@bytedance.com> wrote:
>
> Fixing the mm list address. Sorry for the noise.
>
> Fam
>
>
> > On Jan 4, 2019, at 12:43, Fam Zheng <zhengfeiran@bytedance.com> wrote:
> >
> > Hi,
> >
> > In our server which frequently spawns containers, we find that if a pro=
cess used pagecache in memory cgroup, after the process exits and memory cg=
roup is offlined, because the pagecache is still charged in this memory cgr=
oup, this memory cgroup will not be destroyed until the pagecaches are drop=
ped. This brings huge memory stress over time. We find that over one hundre=
d thounsand such offlined memory cgroup in system hold too much memory (~10=
0G). This memory can not be released immediately even after all associated =
pagecahes are released, because those memory cgroups are destroy asynchrono=
usly by a kworker. In some cases this can cause oom, since the synchronous =
memory allocation failed.
> >

Does force_empty help out your usecase? You can write to
memory.force_empty to reclaim as much as possible memory before
rmdir'ing memcg. This would prevent from page cache accumulating.

BTW, this is cgroup v1 only, I'm working on a patch to bring this back
into v2 as discussed in https://lkml.org/lkml/2019/1/3/484.

> > We think a fix is to create a kworker that scans all pagecaches and den=
try caches etc. in the background, if a referenced memory cgroup is offline=
, try to drop the cache or move it to the parent cgroup. This kworker can w=
ake up periodically, or upon memory cgroup offline event (or both).

Reparenting has been deprecated for a long time. I don't think we want
to bring it back. Actually, css offline is handled by kworker now. I
proposed a patch to do force_empty in kworker, please see
https://lkml.org/lkml/2019/1/2/377.

> >
> > There is a similar problem in inode. After digging in ext4 code, we fin=
d that when creating inode cache, SLAB_ACCOUNT is used. In this case, inode=
 will alloc in slab which belongs to the current memory cgroup. After this =
memory cgroup goes offline, this inode may be held by a dentry cache. If an=
other process uses the same file. this inode will be held by that process, =
preventing the previous memory cgroup from being destroyed until this other=
 process closes the file and drops the dentry cache.

I'm not sure if you really need kmem charge. If not, you may try
cgroup.memory=3Dnokmem.

Regards,
Yang

> >
> > We still don't have a reasonable way to fix this.
> >
> > Ideas?
>
