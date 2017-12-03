Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40FE86B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 08:23:08 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id z195so13327244iof.21
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 05:23:08 -0800 (PST)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 1si8062403iow.145.2017.12.03.05.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 05:23:07 -0800 (PST)
From: gengdongjiu <gengdongjiu@huawei.com>
Subject: [question] handle the page table RAS error
Date: Sun, 3 Dec 2017 13:22:25 +0000
Message-ID: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tony.luck@intel.com" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "wangxiongfeng (C)" <wangxiongfeng2@huawei.com>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>

Hi all,
   Sorry to disturb you. Now the ARM64 has supported the RAS, when enabling=
 this feature, we encounter a issue. If the user space application happen p=
age table RAS error,
Memory error handler(memory_failure()) will do nothing except make a poison=
ed page flag, and fault handler in arch/arm64/mm/fault.c will deliver a sig=
nal to kill this
application. when this application exit, it will call unmap_vmas () to rele=
ase his vma resource, but here it will touch the error page table again, th=
en will trigger RAS error again, so
this application cannot be killed and system will be panic, the log is show=
n in [2].

As shown the stack in [1], unmap_page_range() will touch the error page tab=
le, so system will panic, does this panic behavior is expected?  How the x8=
6 handle the page table
RAS error? If user space application happen page table RAS error, I think t=
he expected behavior should be killing the application instead of panic OS.=
 In current code, when release=20
application vma resource, I do not see it will check whether table page is =
poisoned, could you give me some suggestion about how to handle this case? =
Thanks a lot.=20

[1]:
get_signal()
   do_group_exit()
      mmput()
		exit_mmap()
			unmap_vmas()
				unmap_single_vma()
					unmap_page_range()
					=09

[2]
[  676.669053] Synchronous External Abort: level 0 (translation table walk)=
 (0x82000214) at 0x0000000033ff7008
[  676.686469] Memory failure: 0xcd4b: already hardware poisoned=20
[  676.700652] Synchronous External Abort: synchronous external abort (0x96=
000410) at 0x0000000033ff7008
[  676.723301] Internal error: : 96000410 [#1] PREEMPT SMP=20
[  676.723616] Modules linked in: inject_memory_error(O)
[  676.724601] CPU: 0 PID: 1506 Comm: mca-recover Tainted: G           O   =
 4.14.0-rc8-00019-g5b5c6f4-dirty #109
[  676.724844] task: ffff80000cd41d00 task.stack: ffff000009b30000=20
[  676.726616] PC is at unmap_page_range+0x78/0x6fc=20
[  676.726960] LR is at unmap_single_vma+0x88/0xdc=20
[  676.727122] pc : [<ffff0000081f109c>] lr : [<ffff0000081f17a8>] pstate: =
80400149
[  676.727227] sp : ffff000009b339b0
[  676.727348] x29: ffff000009b339b0 x28: ffff80000cd41d00=20
[  676.727653] x27: 0000000000000000 x26: ffff80000cd42410=20
[  676.727919] x25: ffff80000cd41d00 x24: ffff80000cd1e180=20
[  676.728161] x23: ffff80000ce22300 x22: 0000000000000000=20
[  676.728407] x21: ffff000009b33b28 x20: 0000000000400000=20
[  676.728642] x19: ffff80000cd1e180 x18: 000000000000016d=20
[  676.728875] x17: 0000000000000190 x16: 0000000000000064=20
[  676.729117] x15: 0000000000000339 x14: 0000000000000000=20
[  676.729344] x13: 00000000000061a8 x12: 0000000000000339=20
[  676.729582] x11: 0000000000000018 x10: 0000000000000a80=20
[  676.729829] x9 : ffff000009b33c60 x8 : ffff80000cd427e0=20
[  676.730065] x7 : ffff000009b33de8 x6 : 00000000004a2000=20
[  676.730287] x5 : 0000000000400000 x4 : ffff80000cd4b000=20
[  676.730517] x3 : 00000000004a1fff x2 : 0000008000000000=20
[  676.730741] x1 : 0000007fffffffff x0 : 0000008000000000=20
[  676.731101] Process mca-recover (pid: 1506, stack limit =3D 0xffff000009=
b30000)=20
[  676.731281] Call trace:
[  676.734196] [<ffff0000081f109c>] unmap_page_range+0x78/0x6fc=20
[  676.734539] [<ffff0000081f17a8>] unmap_single_vma+0x88/0xdc=20
[  676.734892] [<ffff0000081f1aa8>] unmap_vmas+0x68/0xb4=20
[  676.735456] [<ffff0000081fa56c>] exit_mmap+0x90/0x140=20
[  676.736468] [<ffff0000080ccb34>] mmput+0x60/0x118=20
[  676.736791] [<ffff0000080d4060>] do_exit+0x240/0x9cc=20
[  676.736997] [<ffff0000080d4854>] do_group_exit+0x38/0x98=20
[  676.737384] [<ffff0000080df4d0>] get_signal+0x1ec/0x548=20
[  676.738313] [<ffff000008088b80>] do_signal+0x7c/0x668=20
[  676.738617] [<ffff000008089538>] do_notify_resume+0xcc/0x114=20
 [  676.740983] [<ffff0000080836c0>] work_pending+0x8/0x10=20
[  676.741360] Code: f94043a4 f9404ba2 f94037a3 d1000441 (f9400080)=20
[  676.741745] ---[ end trace e42d453027313552 ]---=20
[  676.804174] Fixing recursive fault but reboot is needed!
[  677.462082] Memory failure: 0xcd4b: already hardware poisoned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
