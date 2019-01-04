Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A97778E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 14:36:40 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so45516105qtj.21
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 11:36:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b184sor26958788qke.10.2019.01.04.11.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 11:36:39 -0800 (PST)
MIME-Version: 1.0
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com> <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
In-Reply-To: <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 4 Jan 2019 11:36:27 -0800
Message-ID: <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Thu, Jan 3, 2019 at 9:12 PM Fam Zheng <zhengfeiran@bytedance.com> wrote:
>
>
>
> On Jan 4, 2019, at 13:00, Yang Shi <shy828301@gmail.com> wrote:
>
> On Thu, Jan 3, 2019 at 8:45 PM Fam Zheng <zhengfeiran@bytedance.com> wrot=
e:
>
>
> Fixing the mm list address. Sorry for the noise.
>
> Fam
>
>
> On Jan 4, 2019, at 12:43, Fam Zheng <zhengfeiran@bytedance.com> wrote:
>
> Hi,
>
> In our server which frequently spawns containers, we find that if a proce=
ss used pagecache in memory cgroup, after the process exits and memory cgro=
up is offlined, because the pagecache is still charged in this memory cgrou=
p, this memory cgroup will not be destroyed until the pagecaches are droppe=
d. This brings huge memory stress over time. We find that over one hundred =
thounsand such offlined memory cgroup in system hold too much memory (~100G=
). This memory can not be released immediately even after all associated pa=
gecahes are released, because those memory cgroups are destroy asynchronous=
ly by a kworker. In some cases this can cause oom, since the synchronous me=
mory allocation failed.
>
>
> Does force_empty help out your usecase? You can write to
> memory.force_empty to reclaim as much as possible memory before
> rmdir'ing memcg. This would prevent from page cache accumulating.
>
>
> Hmm, this might be an option. FWIW we have been using drop_caches to work=
around.

drop_caches would drop all page caches globally. You may not want to
drop the page caches used by other memcgs.

>
>
> BTW, this is cgroup v1 only, I'm working on a patch to bring this back
> into v2 as discussed in https://lkml.org/lkml/2019/1/3/484.
>
> We think a fix is to create a kworker that scans all pagecaches and dentr=
y caches etc. in the background, if a referenced memory cgroup is offline, =
try to drop the cache or move it to the parent cgroup. This kworker can wak=
e up periodically, or upon memory cgroup offline event (or both).
>
>
> Reparenting has been deprecated for a long time. I don't think we want
> to bring it back. Actually, css offline is handled by kworker now. I
> proposed a patch to do force_empty in kworker, please see
> https://lkml.org/lkml/2019/1/2/377.
>
>
> Could you elaborate a bit about why reparenting is not a good idea?

AFAIK, reparenting may cause some tricky race condition. Since we can
iterate offline memcgs now, so the memory charged to offline memcg
could get reclaimed when memory pressure happens.

Johannes and Michal would know more about the background than me.

Yang

>
>
>
> There is a similar problem in inode. After digging in ext4 code, we find =
that when creating inode cache, SLAB_ACCOUNT is used. In this case, inode w=
ill alloc in slab which belongs to the current memory cgroup. After this me=
mory cgroup goes offline, this inode may be held by a dentry cache. If anot=
her process uses the same file. this inode will be held by that process, pr=
eventing the previous memory cgroup from being destroyed until this other p=
rocess closes the file and drops the dentry cache.
>
>
> I'm not sure if you really need kmem charge. If not, you may try
> cgroup.memory=3Dnokmem.
>
>
> A very good hint, we=E2=80=99ll investigate, thanks!
>
> Fam
>
>
> Regards,
> Yang
>
>
> We still don't have a reasonable way to fix this.
>
> Ideas?
>
>
