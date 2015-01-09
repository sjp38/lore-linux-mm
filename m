Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 06A546B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 12:43:23 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id dc16so7945621qab.8
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 09:43:22 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id u9si11991811qab.87.2015.01.09.09.43.21
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 09:43:22 -0800 (PST)
Message-ID: <54B01335.4060901@arm.com>
Date: Fri, 09 Jan 2015 17:43:17 +0000
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
Subject: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

Hi

We have hit a hang on ARM64 defconfig, while running LTP tests on=20
3.19-rc3. We are
in the process of a git bisect and will update the results as and
when we find the commit.

During the ksm ltp run, the test hangs trying to mount memcg with the=20
following strace
output:

mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ? ERESTARTNOINTR=
=20
(To be restarted)
mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ? ERESTARTNOINTR=
=20
(To be restarted)
[ ... repeated forever ... ]

At this point, one can try mounting the memcg to verify the problem.
# mount -t cgroup -o memory memcg memcg_dir
--hangs--

Strangely, if we run the mount command from a cold boot (i.e. without=20
running LTP first),
then it succeeds.

Upon a quick look we are hitting the following code :
kernel/cgroup.c: cgroup_mount() :

1779         for_each_subsys(ss, i) {
1780                 if (!(opts.subsys_mask & (1 << i)) ||
1781                     ss->root =3D=3D &cgrp_dfl_root)
1782                         continue;
1783
1784                 if=20
(!percpu_ref_tryget_live(&ss->root->cgrp.self.refcnt)) {
1785                         mutex_unlock(&cgroup_mutex);
1786                         msleep(10);
1787                         ret =3D restart_syscall(); <=3D=3D=3D=3D=3D
1788                         goto out_free;
1789                 }
1790                 cgroup_put(&ss->root->cgrp);
1791         }

with ss->root->cgrp.self.refct.percpu_count_ptr =3D=3D __PERCPU_REF_ATOMIC_=
DEAD

Any ideas?

Thanks
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
