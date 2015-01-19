Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id D79646B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:51:31 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id n8so23720696qaq.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 04:51:31 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id f3si17052709qaq.129.2015.01.19.04.51.29
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 04:51:30 -0800 (PST)
Message-ID: <54BCFDCF.9090603@arm.com>
Date: Mon, 19 Jan 2015 12:51:27 +0000
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
References: <54B01335.4060901@arm.com> <20150110085525.GD2110@esperanza>
In-Reply-To: <20150110085525.GD2110@esperanza>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, mhocko@suse.cz, akpm@linux-foundation.org

On 10/01/15 08:55, Vladimir Davydov wrote:
> On Fri, Jan 09, 2015 at 05:43:17PM +0000, Suzuki K. Poulose wrote:
>> Hi
>>
>> We have hit a hang on ARM64 defconfig, while running LTP tests on
>> 3.19-rc3. We are
>> in the process of a git bisect and will update the results as and
>> when we find the commit.
>>
>> During the ksm ltp run, the test hangs trying to mount memcg with
>> the following strace
>> output:
>>
>> mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ?
>> ERESTARTNOINTR (To be restarted)
>> mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ?
>> ERESTARTNOINTR (To be restarted)
>> [ ... repeated forever ... ]
>>
>> At this point, one can try mounting the memcg to verify the problem.
>> # mount -t cgroup -o memory memcg memcg_dir
>> --hangs--
>>
>> Strangely, if we run the mount command from a cold boot (i.e.
>> without running LTP first),
>> then it succeeds.
>>
>> Upon a quick look we are hitting the following code :
>> kernel/cgroup.c: cgroup_mount() :
>>
>> 1779         for_each_subsys(ss, i) {
>> 1780                 if (!(opts.subsys_mask & (1 << i)) ||
>> 1781                     ss->root =3D=3D &cgrp_dfl_root)
>> 1782                         continue;
>> 1783
>> 1784                 if
>> (!percpu_ref_tryget_live(&ss->root->cgrp.self.refcnt)) {
>> 1785                         mutex_unlock(&cgroup_mutex);
>> 1786                         msleep(10);
>> 1787                         ret =3D restart_syscall(); <=3D=3D=3D=3D=3D
>> 1788                         goto out_free;
>> 1789                 }
>> 1790                 cgroup_put(&ss->root->cgrp);
>> 1791         }
>>
>> with ss->root->cgrp.self.refct.percpu_count_ptr =3D=3D __PERCPU_REF_ATOM=
IC_DEAD
>>
>> Any ideas?
>
> The problem is that the memory cgroup controller takes a css reference
> per each charged page and does not reparent charged pages on css
> offline, while cgroup_mount/cgroup_kill_sb expect all css references to
> offline cgroups to be gone soon, restarting the syscall if the ref count
> !=3D 0. As a result, if you create a memory cgroup, charge some page cach=
e
> to it, and then remove it, unmount/mount will hang forever.
>
> May be, we should kill the ref counter to the memory controller root in
> cgroup_kill_sb only if there is no children at all, neither online nor
> offline.
>

Still reproducible on 3.19-rc5 with the same setup. From git bisect, the=20
last good commit is :

commit 8df0c2dcf61781d2efa8e6e5b06870f6c6785735
Author: Pranith Kumar <bobby.prani@gmail.com>
Date:   Wed Dec 10 15:42:28 2014 -0800

     slab: replace smp_read_barrier_depends() with lockless_dereference()



Thanks
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
