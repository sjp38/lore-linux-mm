Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF0B18E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 23:45:03 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69so36364147pff.5
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 20:45:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l14sor27128399pfj.27.2019.01.03.20.45.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 20:45:02 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
Date: Fri, 4 Jan 2019 12:44:56 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, mhocko@kernel.org, vdavydov.dev@gmail.com, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>

Fixing the mm list address. Sorry for the noise.

Fam


> On Jan 4, 2019, at 12:43, Fam Zheng <zhengfeiran@bytedance.com> wrote:
>=20
> Hi,
>=20
> In our server which frequently spawns containers, we find that if a =
process used pagecache in memory cgroup, after the process exits and =
memory cgroup is offlined, because the pagecache is still charged in =
this memory cgroup, this memory cgroup will not be destroyed until the =
pagecaches are dropped. This brings huge memory stress over time. We =
find that over one hundred thounsand such offlined memory cgroup in =
system hold too much memory (~100G). This memory can not be released =
immediately even after all associated pagecahes are released, because =
those memory cgroups are destroy asynchronously by a kworker. In some =
cases this can cause oom, since the synchronous memory allocation =
failed.
>=20
> We think a fix is to create a kworker that scans all pagecaches and =
dentry caches etc. in the background, if a referenced memory cgroup is =
offline, try to drop the cache or move it to the parent cgroup. This =
kworker can wake up periodically, or upon memory cgroup offline event =
(or both).
>=20
> There is a similar problem in inode. After digging in ext4 code, we =
find that when creating inode cache, SLAB_ACCOUNT is used. In this case, =
inode will alloc in slab which belongs to the current memory cgroup. =
After this memory cgroup goes offline, this inode may be held by a =
dentry cache. If another process uses the same file. this inode will be =
held by that process, preventing the previous memory cgroup from being =
destroyed until this other process closes the file and drops the dentry =
cache.
>=20
> We still don't have a reasonable way to fix this.
>=20
> Ideas?
