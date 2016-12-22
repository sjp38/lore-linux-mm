Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1496A6B03E8
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 19:36:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so416985766pgc.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:36:29 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b27si28441741pfe.274.2016.12.21.16.36.27
        for <linux-mm@kvack.org>;
        Wed, 21 Dec 2016 16:36:28 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 0/3] Fix zsmalloc crash problem
Date: Thu, 22 Dec 2016 09:36:17 +0900
Message-Id: <1482366980-3782-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

During developemnt for zram-swap asynchronous writeback, I found strange
corruption of compressed page.

Modules linked in: zram(E)
CPU: 3 PID: 1520 Comm: zramd-1 Tainted: G            E   4.8.0-mm1-00320-ge0d4894c9c38-dirty #3274
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff88007620b840 task.stack: ffff880078090000
RIP: 0010:[<ffffffff811d6f3d>]  [<ffffffff811d6f3d>] set_freeobj.part.43+0x1c/0x1f
RSP: 0018:ffff880078093ca8  EFLAGS: 00010246
RAX: 0000000000000018 RBX: ffff880076798d88 RCX: ffffffff81c408c8
RDX: 0000000000000018 RSI: 0000000000000000 RDI: 0000000000000246
RBP: ffff880078093cb0 R08: 0000000000000000 R09: 0000000000000000
R10: ffff88005bc43030 R11: 0000000000001df3 R12: ffff880076798d88
R13: 000000000005bc43 R14: ffff88007819d1b8 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88007e380000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc934048f20 CR3: 0000000077b01000 CR4: 00000000000406e0
Stack:
 ffffea00016f10c0 ffff880078093d08 ffffffff811d43cb ffff88005bc43030
 ffff88005bc43030 0000000000000001 ffff88007aa17f68 ffff88007819d1b8
 000000000200020a 0000000002000200 ffff880076798d88 ffff88007aa17f68
Call Trace:
 [<ffffffff811d43cb>] obj_malloc+0x22b/0x260
 [<ffffffff811d4be4>] zs_malloc+0x1e4/0x580
 [<ffffffff81355490>] ? lz4_compress_crypto+0x30/0x50
 [<ffffffffa000269d>] zram_bvec_rw+0x4cd/0x830 [zram]
 [<ffffffffa000356c>] page_requests_rw+0x9c/0x130 [zram]
 [<ffffffffa0003600>] ? page_requests_rw+0x130/0x130 [zram]
 [<ffffffffa00036e6>] zram_thread+0xe6/0x173 [zram]
 [<ffffffff810b67e0>] ? wake_atomic_t_function+0x60/0x60
 [<ffffffff81094cfa>] kthread+0xca/0xe0
 [<ffffffff81094c30>] ? kthread_park+0x60/0x60
 [<ffffffff817ae775>] ret_from_fork+0x25/0x30

With investigation, it reveals currently stable page doesn't support
anonymous page.  IOW, reuse_swap_page can reuse the page without
waiting writeback completion so it can overwrite page zram is
compressing.

Unfortunately, zram has used per-cpu stream feature from v4.7.
It aims for increasing cache hit ratio of scratch buffer for
compressing. Downside of that approach is that zram should ask
memory space for compressed page in per-cpu context which requires
stricted gfp flag which could be failed. If so, it retries to
allocate memory space out of per-cpu context so it could get memory
this time and compress the data again, copies it to the memory space.

In this scenario, zram assumes the data should never be changed
but it is not true unless stable page supports. So, If the data is
changed under us, zram can make buffer overrun because second
compression size could be bigger than one we got in previous trial
and blindly, copy bigger size object to smaller buffer which is
buffer overrun. The overrun breaks zsmalloc free object chaining
so system goes crash like above.

I think below is same problem.
https://bugzilla.suse.com/show_bug.cgi?id=997574

This patchset fixes the problem.
[1/3] is to support anonymous stable page.
[2/3] is prepartion step for support zram stable write support.
[3/3] is to support stable write for zram.

This patchset should go to the stable for [4.7+].

* from v3
  * add a trivial comment

Minchan Kim (3):
  [1] mm: support anonymous stable page
  [2] zram: revalidate disk under init_lock
  [3] zram: support BDI_CAP_STABLE_WRITES

 drivers/block/zram/zram_drv.c | 19 +++++++++++--------
 include/linux/swap.h          |  3 ++-
 mm/swapfile.c                 | 20 +++++++++++++++++++-
 3 files changed, 32 insertions(+), 10 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
