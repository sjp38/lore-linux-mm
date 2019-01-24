Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF6F88E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:57:11 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id n201so1759143ybg.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:57:11 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 127si13291498ybq.85.2019.01.24.13.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 13:57:10 -0800 (PST)
Subject: Re: [PATCH] selinux: avc: mark avc node as not a leak
References: <1547023162-6381-1-git-send-email-prpatel@nvidia.com>
 <20190109113126.nzpmb7xx4xqtn37w@mbp>
From: Prateek Patel <prpatel@nvidia.com>
Message-ID: <75b75170-9316-9f7a-13a6-5f2b92b35bb2@nvidia.com>
Date: Fri, 25 Jan 2019 03:26:54 +0530
MIME-Version: 1.0
In-Reply-To: <20190109113126.nzpmb7xx4xqtn37w@mbp>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, eparis@parisplace.org, linux-kernel@vger.kernel.org, selinux@vger.kernel.org, linux-tegra@vger.kernel.org, talho@nvidia.com, swarren@nvidia.com, linux-mm@kvack.org, snikam@nvidia.com, vdumpa@nvidia.com


On 1/9/2019 5:01 PM, Catalin Marinas wrote:
> Hi Prateek,
>
> On Wed, Jan 09, 2019 at 02:09:22PM +0530, Prateek Patel wrote:
>> From: Sri Krishna chowdary <schowdary@nvidia.com>
>>
>> kmemleak detects allocated objects as leaks if not accessed for
>> default scan time. The memory allocated using avc_alloc_node
>> is freed using rcu mechanism when nodes are reclaimed or on
>> avc_flush. So, there is no real leak here and kmemleak_scan
>> detects it as a leak which is false positive. Hence, mark it as
>> kmemleak_not_leak.
> In theory, kmemleak should detect the node->rhead in the lists used by
> call_rcu() and not report it as a leak. Which RCU options do you have
> enabled (just to check whether kmemleak tracks the RCU internal lists)?
>
> Also, does this leak eventually disappear without your patch? Does
>
>    echo dump=3D0xffffffc0dd1a0e60 > /sys/kernel/debug/kmemleak
>
> still display this object?
>
> Thanks.
Hi Catalin,
It was intermittently showing leak and didn't repro on multiple runs. To=20
repo, I decreased the
minimum object age for reporting, I found triggering the second scan=20
just after first is not showing
any leak. Also, without my patch, on echo dump, obj is not displaying.
Is increasing minimum object age for reporting a good idea to handle=20
such type of issues to
avoid false-positives?

Following is the log:

t186_int:/ # echo scan > /sys/kernel/debug/kmemleak
t186_int:/ # cat /sys/kernel/debug/kmemleak

unreferenced object 0xffffffc1e06424c8 (size 72):
 =C2=A0 comm "netd", pid 4891, jiffies 4294906431 (age 23.120s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 97 01 00 00 1b 00 00 00 0b 00 00 00 57 06 04 00 .......=
.....W...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 ff ff ff ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de1b8>] avc_has_perm+0xf8/0x1b8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e37f8>] file_has_perm+0xb8/0xe8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e3d64>] match_file+0x44/0x98
 =C2=A0=C2=A0=C2=A0 [<ffffff80082cc9d4>] iterate_fd+0x84/0xd0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e2b3c>] selinux_bprm_committing_creds+0xec=
/0x230
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d842c>] security_bprm_committing_creds+0x4=
4/0x60
 =C2=A0=C2=A0=C2=A0 [<ffffff80082ad020>] install_exec_creds+0x20/0x70
 =C2=A0=C2=A0=C2=A0 [<ffffff800831b9a4>] load_elf_binary+0x31c/0xd10
 =C2=A0=C2=A0=C2=A0 [<ffffff80082ae530>] search_binary_handler+0x98/0x288
 =C2=A0=C2=A0=C2=A0 [<ffffff80082af078>] do_execveat_common.isra.14+0x550/0=
x6d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80082af4ac>] SyS_execve+0x4c/0x60
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffffc1ab3c61b0 (size 72):
 =C2=A0 comm "crash_dump64", pid 5058, jiffies 4294907834 (age 17.508s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 2f 02 00 00 6b 00 00 00 07 00 00 00 53 04 04 00 /...k..=
.....S...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 ff ff fd ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de084>] avc_has_perm_noaudit+0xe4/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e1264>] selinux_inode_permission+0xc4/0x1c=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d8fe8>] security_inode_permission+0x60/0x8=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2cf4>] __inode_permission2+0x54/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2e30>] inode_permission2+0x38/0x80
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b4b58>] may_open+0x70/0x128
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b6fd4>] do_last+0x234/0xee8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b7d30>] path_openat+0xa8/0x310
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b9390>] do_filp_open+0x88/0x108
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a1fec>] do_sys_open+0x1a4/0x290
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a215c>] SyS_openat+0x3c/0x50
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffffc1d3bcf678 (size 72):
 =C2=A0 comm "mediaserver", pid 5156, jiffies 4294909577 (age 10.536s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 0b 02 00 00 e2 01 00 00 07 00 00 00 53 04 04 00 .......=
.....S...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 f7 ff ff ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de084>] avc_has_perm_noaudit+0xe4/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e1264>] selinux_inode_permission+0xc4/0x1c=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d8fe8>] security_inode_permission+0x60/0x8=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2cf4>] __inode_permission2+0x54/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2e30>] inode_permission2+0x38/0x80
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b4b58>] may_open+0x70/0x128
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b6fd4>] do_last+0x234/0xee8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b7d30>] path_openat+0xa8/0x310
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b9390>] do_filp_open+0x88/0x108
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a1fec>] do_sys_open+0x1a4/0x290
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a21f4>] compat_SyS_openat+0x3c/0x50
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
t186_int:/ # echo dump=3D0xffffffc1d3bcf678 > /sys/kernel/debug/kmemleak
kmemleak: Unknown object at 0xffffffc1d3bcf678

Thanks,
