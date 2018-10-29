Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE856B0378
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 09:20:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z7-v6so6003809edh.19
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 06:20:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l21-v6si1000141ejs.32.2018.10.29.06.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 06:20:39 -0700 (PDT)
Date: Mon, 29 Oct 2018 14:20:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
Message-ID: <20181029132035.GI32673@dhcp22.suse.cz>
References: <1540792855.22373.34.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540792855.22373.34.camel@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Cc Vladimir and Johannes - the full report is http://lkml.kernel.org/r/1540792855.22373.34.camel@gmx.de

On Mon 29-10-18 07:00:55, Mike Galbraith wrote:
> Greetings,
> 
> The attached config makes boom on both real HW, and KVM.  First
> encountered after RT merge, then reproduced in virgin source with
> config based on the enterprise-ish RT config.
> 
> [    4.412732] BUG: unable to handle kernel NULL pointer dereference at 00000000000000f8
> [    4.414047] PGD 0 P4D 0
> [    4.414769] Oops: 0002 [#1] PREEMPT SMP PTI
> [    4.415651] CPU: 7 PID: 1 Comm: systemd Not tainted 4.19.0.g69d5b97-preempt #110
> [    4.416849] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> [    4.419475] RIP: 0010:page_counter_try_charge+0x25/0xc0

I strongly suspect memcg is NULL here.

> [    4.420976] Code: f3 c3 0f 1f 00 0f 1f 44 00 00 48 85 ff 0f 84 a8 00 00 00 41 56 48 89 f8 41 55 49 89 fe 41 54 49 89 d5 55 49 89 f4 53 48 89 f3 <f0> 48 0f c1 1f 48 01 f3 48 39 5f 18 48 89 fd 73 17 eb 41 48 89 e8
> [    4.424162] RSP: 0018:ffffb27840c57cb0 EFLAGS: 00010202
> [    4.425236] RAX: 00000000000000f8 RBX: 0000000000000020 RCX: 0000000000000200
> [    4.426467] RDX: ffffb27840c57d08 RSI: 0000000000000020 RDI: 00000000000000f8
> [    4.427652] RBP: 0000000000000001 R08: 0000000000000000 R09: ffffb278410bc000
> [    4.428883] R10: ffffb27840c57ed0 R11: 0000000000000040 R12: 0000000000000020
> [    4.430168] R13: ffffb27840c57d08 R14: 00000000000000f8 R15: 00000000006000c0
> [    4.431411] FS:  00007f79081a3940(0000) GS:ffff92a4b7bc0000(0000) knlGS:0000000000000000
> [    4.432748] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    4.433836] CR2: 00000000000000f8 CR3: 00000002310ac002 CR4: 00000000001606e0
> [    4.435500] Call Trace:
> [    4.436319]  try_charge+0x92/0x7b0
> [    4.437284]  ? unlazy_walk+0x4c/0xb0
> [    4.438676]  ? terminate_walk+0x91/0x100
> [    4.439984]  memcg_kmem_charge_memcg+0x28/0x80
> [    4.441059]  memcg_kmem_charge+0x88/0x1d0
> [    4.442105]  copy_process.part.37+0x23a/0x2070

Could you faddr2line this please?

> [    4.443128]  ? shmem_tmpfile+0x90/0x90
> [    4.444061]  ? shmem_mknod+0xbf/0xd0
> [    4.444968]  _do_fork+0xbd/0x3e0
> [    4.445907]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [    4.447729]  do_syscall_64+0x5a/0x170
> [    4.449792]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [    4.451386] RIP: 0033:0x7f790672e193
> [    4.452285] Code: db 45 85 ed 0f 85 ad 01 00 00 64 4c 8b 04 25 10 00 00 00 31 d2 4d 8d 90 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff ff 0f 87 f1 00 00 00 85 c0 41 89 c4 0f 85 fe 00 00
> [    4.455686] RSP: 002b:00007ffe60886b70 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
> [    4.457112] RAX: ffffffffffffffda RBX: 00007ffe60886b70 RCX: 00007f790672e193
> [    4.458488] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
> [    4.461035] RBP: 00007ffe60886bc0 R08: 00007f79081a3940 R09: 0000000000000000
> [    4.462378] R10: 00007f79081a3c10 R11: 0000000000000246 R12: 0000000000000000
> [    4.463626] R13: 0000000000000000 R14: 0000000000000000 R15: 000055838becab00
> [    4.464862] Modules linked in:
> [    4.465649] Dumping ftrace buffer:
> [    4.466502]    (ftrace buffer empty)
> [    4.467336] CR2: 00000000000000f8
-- 
Michal Hocko
SUSE Labs
