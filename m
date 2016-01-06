Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id BDCE66B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 00:02:37 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id 6so217116155qgy.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 21:02:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c69si100332241qkb.11.2016.01.05.21.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 21:02:37 -0800 (PST)
From: Mateusz Guzik <mguzik@redhat.com>
Subject: [PATCH 0/2] fix up {arg,env}_{start,end} vs prctl
Date: Wed,  6 Jan 2016 06:02:27 +0100
Message-Id: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

An unprivileged user can trigger an oops on a kernel with
CONFIG_CHECKPOINT_RESTORE.

proc_pid_cmdline_read takes mmap_sem for reading and obtains args + env
start/end values. These get sanity checked as follows:
        BUG_ON(arg_start > arg_end);
        BUG_ON(env_start > env_end);

These can be changed by prctl_set_mm. Turns out also takes the semaphore for
reading, effectively rendering it useless. This results in:

[   50.530255] kernel BUG at fs/proc/base.c:240!
[   50.543351] invalid opcode: 0000 [#1] SMP 
[   50.556389] Modules linked in: virtio_net
[   50.569320] CPU: 0 PID: 925 Comm: a.out Not tainted 4.4.0-rc8-next-20160105dupa+ #71
[   50.594875] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   50.607972] task: ffff880077a68000 ti: ffff8800784d0000 task.ti: ffff8800784d0000
[   50.633486] RIP: 0010:[<ffffffff812c5b70>]  [<ffffffff812c5b70>] proc_pid_cmdline_read+0x520/0x530
[   50.659469] RSP: 0018:ffff8800784d3db8  EFLAGS: 00010206
[   50.672420] RAX: ffff880077c5b6b0 RBX: ffff8800784d3f18 RCX: 0000000000000000
[   50.697771] RDX: 0000000000000002 RSI: 00007f78e8857000 RDI: 0000000000000246
[   50.723783] RBP: ffff8800784d3e40 R08: 0000000000000008 R09: 0000000000000001
[   50.749176] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000050
[   50.775319] R13: 00007f78e8857800 R14: ffff88006fcef000 R15: ffff880077c5b600
[   50.800986] FS:  00007f78e884a740(0000) GS:ffff88007b200000(0000) knlGS:0000000000000000
[   50.826426] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   50.839435] CR2: 00007f78e8361770 CR3: 00000000790a5000 CR4: 00000000000006f0
[   50.865024] Stack:
[   50.877583]  ffffffff81d69c95 ffff8800784d3de8 0000000000000246 ffffffff81d69c95
[   50.903400]  0000000000000104 ffff880077c5b6b0 00007f78e8857000 00007fffffffe6df
[   50.929364]  00007fffffffe6d7 00007ffd519b6d60 ffff88006fc68038 000000005934de93
[   50.954794] Call Trace:
[   50.967405]  [<ffffffff81247027>] __vfs_read+0x37/0x100
[   50.980353]  [<ffffffff8142bfa6>] ? security_file_permission+0xa6/0xc0
[   50.993623]  [<ffffffff812475e2>] ? rw_verify_area+0x52/0xe0
[   51.007089]  [<ffffffff812476f2>] vfs_read+0x82/0x130
[   51.020528]  [<ffffffff812487e8>] SyS_read+0x58/0xd0
[   51.033914]  [<ffffffff81a0a132>] entry_SYSCALL_64_fastpath+0x12/0x76
[   51.046976] Code: 4c 8b 7d a8 eb e9 48 8b 9d 78 ff ff ff 4c 8b 7d 90 48 8b 03 48 39 45 a8 0f 87 f0 fe ff ff e9 d1 fe ff ff 4c 8b 7d 90 eb c6 0f 0b <0f> 0b 0f 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 
[   51.087392] RIP  [<ffffffff812c5b70>] proc_pid_cmdline_read+0x520/0x530
[   51.100659]  RSP <ffff8800784d3db8>
[   51.113353] ---[ end trace 97882617ae9c6818 ]---

Turns out there are instances where the code just reads aformentioned
values without locking whatsoever - namely environ_read and get_cmdline.

Interestingly these functions look quite resilient against bogus values,
but I don't believe this should be relied upon.

The first patch gets rid of the oops bug by grabbing mmap_sem for writing.

The second patch is optional and puts locking around aformentioned consumers
for safety. Consumers of other fields don't seem to benefit from similar
treatment and are left untouched.

Mateusz Guzik (2):
  prctl: take mmap sem for writing to protect against others
  proc read mm's {arg,env}_{start,end} with mmap semaphore taken.

 fs/proc/base.c | 13 ++++++++++---
 kernel/sys.c   | 20 ++++++++++----------
 mm/util.c      | 16 ++++++++++++----
 3 files changed, 32 insertions(+), 17 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
