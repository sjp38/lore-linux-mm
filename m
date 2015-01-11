Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 097376B0075
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 03:58:50 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id z107so14388984qgd.2
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 00:58:49 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0118.outbound.protection.outlook.com. [65.55.169.118])
        by mx.google.com with ESMTPS id z110si18511920qgd.73.2015.01.11.00.58.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 11 Jan 2015 00:58:48 -0800 (PST)
Message-ID: <54B23B37.5080306@amd.com>
Date: Sun, 11 Jan 2015 10:58:31 +0200
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: [BUG] 3.19-rc3+ - mm: prevent endless growth of anon_vma hierarchy
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: koct9i@gmail.com, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: dan.forrest@ssec.wisc.edu, jmarchan@redhat.com, "Bridgman, John" <John.Bridgman@amd.com>, "Elifaz, Dana" <Dana.Elifaz@amd.com>, Dave Airlie <airlied@gmail.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello,

Today I took latest branch from Linus repo to check for amdkfd regressions
due to my fixes pulled for 3.19-rc4, and I got a kernel bug (see below dmesg
output).

I did a bisect and the first bad commit is:

7a3ef208e662f4b63d43a23f61a64a129c525bbc is the first bad commit
commit 7a3ef208e662f4b63d43a23f61a64a129c525bbc
Author: Konstantin Khlebnikov <koct9i@gmail.com>
Date:   Thu Jan 8 14:32:15 2015 -0800

    mm: prevent endless growth of anon_vma hierarchy

The bug is before the pull of latest amdkfd fixes, so it is not related to
my pull request. From the bisect log (end of email), you can see 3.19-rc3 is
fine.

The problem occurred while running java over HSA. The Kernel is 64-bit and
userspace processes are 64-bit as well. CPU is AMD Kaveri (A10-7850).
OpenCL/OpenMP over HSA run without problems.

dmesg output:

[  266.491864] ------------[ cut here ]------------
[  266.491904] kernel BUG at mm/rmap.c:399!
[  266.491934] invalid opcode: 0000 [#1] SMP
[  266.491962] Modules linked in: amdkfd amd_iommu_v2 radeon cfbfillrect
cfbimgblt cfbcopyarea drm_kms_helper ttm fuse
[  266.492043] CPU: 3 PID: 5155 Comm: java Not tainted 3.19.0-rc3-kfd+ #24
[  266.492087] Hardware name: AMD BALLINA/Ballina, BIOS
WBL3B20N_Weekly_13_11_2 11/20/2013
[  266.492141] task: ffff8800a3b3c840 ti: ffff8800916f8000 task.ti:
ffff8800916f8000
[  266.492191] RIP: 0010:[<ffffffff81126630>]  [<ffffffff81126630>]
unlink_anon_vmas+0x102/0x159
[  266.492249] RSP: 0018:ffff8800916fbb68  EFLAGS: 00010286
[  266.492285] RAX: ffff88008f6b3ba0 RBX: ffff88008f6b3b90 RCX: ffff8800a3b3cf30
[  266.492331] RDX: ffff8800914b3c98 RSI: 0000000000000001 RDI: ffff8800914b3c98
[  266.492376] RBP: ffff8800916fbba8 R08: 0000000000000002 R09: 0000000000000000
[  266.492421] R10: 0000000000000008 R11: 0000000000000001 R12: ffff88008f686068
[  266.492465] R13: ffff8800914b3c98 R14: ffff88008f6b3b90 R15: ffff88008f686000
[  266.492513] FS:  00007fb8966f6700(0000) GS:ffff88011ed80000(0000)
knlGS:0000000000000000
[  266.492566] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  266.492601] CR2: 00007f50fa190770 CR3: 0000000001b31000 CR4: 00000000000407e0
[  266.492652] Stack:
[  266.492665]  0000000000000000 ffff88008f686078 ffff8800916fbba8
ffff88008f686000
[  266.492714]  ffff8800916fbc08 0000000000000000 0000000000000000
ffff88008f686000
[  266.492764]  ffff8800916fbbf8 ffffffff8111ba5d 00007fb885918000
ffff88008edf3000
[  266.492815] Call Trace:
[  266.492834]  [<ffffffff8111ba5d>] free_pgtables+0x8e/0xcc
[  266.492873]  [<ffffffff8112253e>] exit_mmap+0x84/0x116
[  266.492907]  [<ffffffff8103f789>] mmput+0x52/0xe9
[  266.492940]  [<ffffffff81043918>] do_exit+0x3cd/0x9c9
[  266.492975]  [<ffffffff8170c1ec>] ? _raw_spin_unlock_irq+0x2d/0x32
[  266.493016]  [<ffffffff81044d7f>] do_group_exit+0x4c/0xc9
[  266.493051]  [<ffffffff8104eb87>] get_signal+0x58f/0x5bc
[  266.493090]  [<ffffffff810022c4>] do_signal+0x28/0x5b1
[  266.493123]  [<ffffffff8170ca0c>] ? sysret_signal+0x5/0x43
[  266.493162]  [<ffffffff81002882>] do_notify_resume+0x35/0x68
[  266.493200]  [<ffffffff8170cc7f>] int_signal+0x12/0x17
[  266.493235] Code: e8 03 b7 f4 ff 49 8b 47 78 4c 8b 20 48 8d 58 f0 49 83
ec 10 48 8d 43 10 48 39 45 c8 74 55 48 8b 7b 08 83 bf 8c 00 00 00 00 74 02
<0f> 0b e8 a4 fd ff ff 48 8b 43 18 48 8b 53 10 48 89 df 48 89 42
[  266.493404] RIP  [<ffffffff81126630>] unlink_anon_vmas+0x102/0x159
[  266.493447]  RSP <ffff8800916fbb68>
[  266.508877] ---[ end trace 02d28fe9b3de2e1a ]---
[  266.508880] Fixing recursive fault but reboot is needed!


git bisect log:

git bisect start
# bad: [a4ad89a46882b91b7df9cfb83dd21c06b8065c30] fix to qcom eth ctrl
git bisect bad a4ad89a46882b91b7df9cfb83dd21c06b8065c30
# good: [b1940cd21c0f4abdce101253e860feff547291b0] Linux 3.19-rc3
git bisect good b1940cd21c0f4abdce101253e860feff547291b0
# bad: [03c751a5e10caafbb6d1afcaf1ea67f2153c3193] Merge branch 'for-linus'
of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
git bisect bad 03c751a5e10caafbb6d1afcaf1ea67f2153c3193
# bad: [53dc20b9a3d928b0744dad5aee65b610de1cc85d] ocfs2: fix the wrong
directory passed to ocfs2_lookup_ino_from_name() when link file
git bisect bad 53dc20b9a3d928b0744dad5aee65b610de1cc85d
# good: [e8829f007e982a9a8fb4023109233d5f344d4657] batman-adv: fix counter
for multicast supporting nodes
git bisect good e8829f007e982a9a8fb4023109233d5f344d4657
# good: [2abad79afa700e837cb4feed170141292e0720c0] qla3xxx: don't allow
never end busy loop
git bisect good 2abad79afa700e837cb4feed170141292e0720c0
# good: [0adc1803880db728fa7f8cbad5b214ab657e5e0d] Merge tag 'for-linus-3'
of git://git.code.sf.net/p/openipmi/linux-ipmi
git bisect good 0adc1803880db728fa7f8cbad5b214ab657e5e0d
# good: [3245d6acab981a2388ffb877c7ecc97e763c59d4] exit: fix race between
wait_consider_task() and wait_task_zombie()
git bisect good 3245d6acab981a2388ffb877c7ecc97e763c59d4
# bad: [2d6d7f98284648c5ed113fe22a132148950b140f] mm: protect
set_page_dirty() from ongoing truncation
git bisect bad 2d6d7f98284648c5ed113fe22a132148950b140f
# bad: [7a3ef208e662f4b63d43a23f61a64a129c525bbc] mm: prevent endless growth
of anon_vma hierarchy
git bisect bad 7a3ef208e662f4b63d43a23f61a64a129c525bbc
# first bad commit: [7a3ef208e662f4b63d43a23f61a64a129c525bbc] mm: prevent
endless growth of anon_vma hierarchy

I saw this commit is marked stable, so this is quite problematic as it could
break userspace HSA apps out there (although amdkfd will only be present
from 3.19).

Could you please take a look and help solve this issue ?

Thanks,

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
