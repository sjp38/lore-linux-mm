Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15F9FC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A755920679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:08:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A755920679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D33D6B000D; Tue, 13 Aug 2019 05:08:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 385036B000E; Tue, 13 Aug 2019 05:08:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29ABD6B0010; Tue, 13 Aug 2019 05:08:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 02DB46B000D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:08:15 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9B669180AD801
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:08:15 +0000 (UTC)
X-FDA: 75816828150.27.mark13_2ad5cec04fc06
X-HE-Tag: mark13_2ad5cec04fc06
X-Filterd-Recvd-Size: 12170
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:08:14 +0000 (UTC)
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 1BA99C68DE6B44D23AC4;
	Tue, 13 Aug 2019 17:08:10 +0800 (CST)
Received: from [127.0.0.1] (10.133.217.137) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Tue, 13 Aug 2019
 17:08:05 +0800
CC: Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Jann Horn
	<jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>, Michal Hocko
	<mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
To: linux-mm <linux-mm@kvack.org>
Message-ID: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
Date: Tue, 13 Aug 2019 17:08:05 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.217.137]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrea Arcangeli and all,

There is a BUG after apply patch "04f5866e41fb coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping".
The following is reproducer and panic log, could anyone check it?

Syzkaller reproducer:
# {Threaded:true Collide:true Repeat:false RepeatTimes:0 Procs:1 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true EnableNetDev:true EnableNetReset:false EnableCgroups:false EnableBinfmtMisc:true EnableCloseFds:true UseTmpDir:true HandleSegv:true Repro:false Trace:false}
r0 = userfaultfd(0x80800)
ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000000200))
ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000000080)={{&(0x7f0000ff2000/0xe000)=nil, 0xe000}, 0x1})
ioctl$UFFDIO_COPY(r0, 0xc028aa03, 0x0)
ioctl$UFFDIO_COPY(r0, 0xc028aa03, &(0x7f0000000000)={&(0x7f0000ffc000/0x3000)=nil, &(0x7f0000ffd000/0x2000)=nil, 0x3000})
syz_execute_func(&(0x7f00000000c0)="4134de984013e80f059532058300000071f3c4e18dd1ce5a65460f18320ce0b9977d8f64360f6e54e3a50fe53ff30fb837c42195dc42eddb8f087ca2a4d2c4017b708fa878c3e600f3266440d9a200000000c4016c5bdd7d0867dfe07f00f20f2b5f0009404cc442c102282cf2f20f51e22ef2e1291010f2262ef045814cb39700000000f32e3ef0fe05922f79a4000030470f3b58c1312fe7460f50ce0502338d00858526660f346253f6010f0f801d000000470f0f2c0a90c7c7df84feefff3636260fe02c98c8b8fcfc81fc51720a40400e700064660f71e70d2e0f57dfe819d0253f3ecaf06ad647608c41ffc42249bccb430f9bc8b7a042420f8d0042171e0f95ca9f7f921000d9fac4a27d5a1fc4a37961309de9000000003171460fc4d303c466410fd6389dc4426c456300c4233d4c922d92abf90ac6c34df30f5ee50909430f3a15e7776f6e866b0fdfdfc482797841cf6ffc842d9b9a516dc2e52ef2ac2636f20f114832d46231bffd4834eaeac4237d09d0003766420f160182c4a37d047882007f108f2808a6e68fc401505d6a82635d1467440fc7ba0c000000d4c482359652745300")
poll(&(0x7f00000000c0)=[{}], 0x1, 0x0)

./syz-execprog -executor=./syz-executor -repeat=0 -procs=16 -cover=0 repofile


[   74.783362] invalid opcode: 0000 [#1] SMP PTI
[   74.783740] ------------[ cut here ]------------
[   74.784430] CPU: 5 PID: 12803 Comm: syz-executor.15 Not tainted 5.3.0-rc4 #15
[   74.785831] kernel BUG at ../fs/userfaultfd.c:385!
[   74.787906] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[   74.787916] RIP: 0010:handle_userfault+0x615/0x6b0
[   74.793714] Code: c3 e9 ed fc ff ff 48 39 84 24 a0 00 00 00 0f 85 1a fe ff ff e9 69 fe ff ff e8 f7 28 d8 ff 0f 0b 0f 0b 0f 0b 90 e9 71 fa ff ff <0f> 0b bd 00 01 00 00 e9 29 fa ff ff a8 08 75 49 48 c7 c7 e0 1a e5
[   74.793716] RSP: 0018:ffffc9000853b9a0 EFLAGS: 00010287
[   74.793719] RAX: ffff88842b685708 RBX: ffffc9000853baa8 RCX: 00000000ebeaed2d
[   74.793720] RDX: 0000000000000100 RSI: 0000000000000200 RDI: ffffc9000853baa8
[   74.793721] RBP: ffff88841b29afe8 R08: ffff88841bdb8cb8 R09: 00000000fffffff0
[   74.793723] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88841f6b2400
[   74.793724] R13: ffff88841b6e6900 R14: ffff888107d0f000 R15: ffff88842b685708
[   74.793726] FS:  00007f662e18f700(0000) GS:ffff88842fa80000(0000) knlGS:0000000000000000
[   74.793728] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   74.793729] CR2: 0000000020ffd000 CR3: 000000041b3aa006 CR4: 00000000000206e0
[   74.793734] Call Trace:
[   74.793741]  ? __lock_acquire+0x44a/0x10d0
[   74.793749]  ? find_held_lock+0x31/0xa0
[   74.793755]  ? __handle_mm_fault+0xfc2/0x1140
[   74.827705]  __handle_mm_fault+0xfcf/0x1140
[   74.827714]  handle_mm_fault+0x18d/0x390
[   74.830599]  ? handle_mm_fault+0x46/0x390
[   74.830604]  __do_page_fault+0x250/0x4e0
[   74.830609]  do_page_fault+0x31/0x210
[   74.830635]  async_page_fault+0x43/0x50
[   74.836532] RIP: 0010:copy_user_handle_tail+0x2/0x10
[   74.836534] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
[   74.836536] RSP: 0018:ffffc9000853bcc0 EFLAGS: 00010246
[   74.836538] RAX: 0000000020ffe000 RBX: 0000000020ffd000 RCX: 0000000000001000
[   74.836539] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8884216d0000
[   74.836541] RBP: 0000000000001000 R08: 0000000000000001 R09: 0000000000000000
[   74.853625] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8884216d0000
[   74.853627] R13: ffff88841ba56838 R14: ffff88841bdb8000 R15: fffffffffffffffe
[   74.853654]  _copy_from_user+0x69/0xa0
[   74.859716]  mcopy_atomic+0x80f/0xc30
[   74.859719]  ? find_held_lock+0x31/0xa0
[   74.859728]  userfaultfd_ioctl+0x2f6/0x1290
[   74.859749]  ? __lock_acquire+0x44a/0x10d0
[   74.864385]  ? __lock_acquire+0x44a/0x10d0
[   74.864393]  do_vfs_ioctl+0xa6/0x6f0
[   74.864401]  ksys_ioctl+0x60/0x90
[   74.867616]  __x64_sys_ioctl+0x16/0x20
[   74.867622]  do_syscall_64+0x5a/0x270
[   74.867625]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   74.867629] RIP: 0033:0x458c59
[   74.872142] Code: ad b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 7b b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
[   74.872144] RSP: 002b:00007f662e18ec78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[   74.872146] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458c59
[   74.872148] RDX: 0000000020000000 RSI: 00000000c028aa03 RDI: 0000000000000003
[   74.872149] RBP: 000000000073c040 R08: 0000000000000000 R09: 0000000000000000
[   74.872151] R10: 0000000000000000 R11: 0000000000000246 R12: 00007f662e18f6d4
[   74.872152] R13: 00000000004c34cf R14: 00000000004d6958 R15: 00000000ffffffff
[   74.872159] Modules linked in:
[   74.894123] Dumping ftrace buffer:
[   74.894141]    (ftrace buffer empty)
[   74.894173] invalid opcode: 0000 [#2] SMP PTI
[   74.894205] ---[ end trace 046fbc99545d7cd2 ]---
[   74.894209] RIP: 0010:handle_userfault+0x615/0x6b0
[   74.894211] Code: c3 e9 ed fc ff ff 48 39 84 24 a0 00 00 00 0f 85 1a fe ff ff e9 69 fe ff ff e8 f7 28 d8 ff 0f 0b 0f 0b 0f 0b 90 e9 71 fa ff ff <0f> 0b bd 00 01 00 00 e9 29 fa ff ff a8 08 75 49 48 c7 c7 e0 1a e5
[   74.894212] RSP: 0018:ffffc9000853b9a0 EFLAGS: 00010287
[   74.894215] RAX: ffff88842b685708 RBX: ffffc9000853baa8 RCX: 00000000ebeaed2d
[   74.894216] RDX: 0000000000000100 RSI: 0000000000000200 RDI: ffffc9000853baa8
[   74.894217] RBP: ffff88841b29afe8 R08: ffff88841bdb8cb8 R09: 00000000fffffff0
[   74.894219] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88841f6b2400
[   74.894220] R13: ffff88841b6e6900 R14: ffff888107d0f000 R15: ffff88842b685708
[   74.894222] FS:  00007f662e18f700(0000) GS:ffff88842fa80000(0000) knlGS:0000000000000000
[   74.894224] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   74.894225] CR2: 0000000020ffd000 CR3: 000000041b3aa006 CR4: 00000000000206e0
[   74.894229] Kernel panic - not syncing: Fatal exception
[   74.925215] CPU: 0 PID: 12801 Comm: syz-executor.12 Tainted: G      D           5.3.0-rc4-nocordump #15
[   74.927904] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[   74.930520] RIP: 0010:handle_userfault+0x615/0x6b0
[   74.931725] Code: c3 e9 ed fc ff ff 48 39 84 24 a0 00 00 00 0f 85 1a fe ff ff e9 69 fe ff ff e8 f7 28 d8 ff 0f 0b 0f 0b 0f 0b 90 e9 71 fa ff ff <0f> 0b bd 00 01 00 00 e9 29 fa ff ff a8 08 75 49 48 c7 c7 e0 1a e5
[   74.935662] RSP: 0018:ffffc9000852b9a0 EFLAGS: 00010287
[   74.936776] RAX: ffff88841b6d5190 RBX: ffffc9000852baa8 RCX: 0000000000000000
[   74.938282] RDX: 0000000000000100 RSI: 0000000000000200 RDI: ffffc9000852baa8
[   74.939796] RBP: ffff88841b2fafe8 R08: 0000000000000000 R09: 0000000000000000
[   74.941292] R10: 0000000000000000 R11: 0000000000000000 R12: ffff888427672400
[   74.942793] R13: ffff88841b6e6000 R14: ffff888107d0f000 R15: ffff88841b6d5190
[   74.944295] FS:  00007fa9e620e700(0000) GS:ffff88842f800000(0000) knlGS:0000000000000000
[   74.945989] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   74.947205] CR2: 0000000020ffd000 CR3: 000000041b2ac003 CR4: 00000000000206f0
[   74.948701] Call Trace:
[   74.949237]  ? __lock_acquire+0x44a/0x10d0
[   74.950116]  ? __update_load_avg_se+0x1ed/0x2a0
[   74.951088]  ? __handle_mm_fault+0xe54/0x1140
[   74.952017]  __handle_mm_fault+0xfcf/0x1140
[   74.952911]  handle_mm_fault+0x18d/0x390
[   74.953750]  ? handle_mm_fault+0x46/0x390
[   74.954610]  __do_page_fault+0x250/0x4e0
[   74.955463]  do_page_fault+0x31/0x210
[   74.956250]  async_page_fault+0x43/0x50
[   74.957072] RIP: 0010:copy_user_handle_tail+0x2/0x10
[   74.958118] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
[   74.962044] RSP: 0018:ffffc9000852bcc0 EFLAGS: 00010246
[   74.963164] RAX: 0000000020ffe000 RBX: 0000000020ffd000 RCX: 0000000000001000
[   74.964663] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8884216cf000
[   74.966164] RBP: 0000000000001000 R08: 0000000000000001 R09: 0000000000000000
[   74.967680] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8884216cf000
[   74.969176] R13: ffff88841bd9c838 R14: ffff88841b879f00 R15: fffffffffffffffe
[   74.970685]  _copy_from_user+0x69/0xa0
[   74.971498]  mcopy_atomic+0x80f/0xc30
[   74.972288]  ? find_held_lock+0x31/0xa0
[   74.973117]  userfaultfd_ioctl+0x2f6/0x1290
[   74.974011]  ? __lock_acquire+0x44a/0x10d0
[   74.974895]  ? __lock_acquire+0x44a/0x10d0
[   74.975774]  do_vfs_ioctl+0xa6/0x6f0
[   74.976545]  ksys_ioctl+0x60/0x90
[   74.977262]  __x64_sys_ioctl+0x16/0x20
[   74.978068]  do_syscall_64+0x5a/0x270
[   74.978867]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   74.979925] RIP: 0033:0x458c59
[   74.980582] Code: ad b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 7b b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
[   74.984467] RSP: 002b:00007fa9e620dc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[   74.986047] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458c59
[   74.987552] RDX: 0000000020000000 RSI: 00000000c028aa03 RDI: 0000000000000003
[   74.989052] RBP: 000000000073c040 R08: 0000000000000000 R09: 0000000000000000
[   74.990545] R10: 0000000000000000 R11: 0000000000000246 R12: 00007fa9e620e6d4
[   74.992058] R13: 00000000004c34cf R14: 00000000004d6958 R15: 00000000ffffffff
[   74.993560] Modules linked in:
[   74.994217] Dumping ftrace buffer:
[   74.994952]    (ftrace buffer empty)
[   74.995753] Dumping ftrace buffer:
[   74.996496]    (ftrace buffer empty)
[   74.997253] Kernel Offset: disabled
[   74.997995] Rebooting in 86400 seconds..


