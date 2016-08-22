Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA726B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 12:54:36 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i184so179783810ywb.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 09:54:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q3si14396442qkq.307.2016.08.22.09.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 09:54:35 -0700 (PDT)
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH] mm: fix overlap check in hardened usercopy
Date: Mon, 22 Aug 2016 11:53:59 -0500
Message-Id: <a6fefe6183906e4d08e4cfbcb55156fcd63f3e29.1471884716.git.jpoimboe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When running with a local patch which moves the '_stext' symbol to the
very beginning of the kernel text area, I got the following panic with
CONFIG_HARDENED_USERCOPY:

  usercopy: kernel memory exposure attempt detected from ffff88103dfff000 (<linear kernel text>) (4096 bytes)
  ------------[ cut here ]------------
  kernel BUG at mm/usercopy.c:79!
  invalid opcode: 0000 [#1] SMP
  ...
  CPU: 0 PID: 4800 Comm: cp Not tainted 4.8.0-rc3.after+ #1
  Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.5.4 01/22/2016
  task: ffff880817444140 task.stack: ffff880816274000
  RIP: 0010:[<ffffffff8121c796>] __check_object_size+0x76/0x413
  RSP: 0018:ffff880816277c40 EFLAGS: 00010246
  RAX: 000000000000006b RBX: ffff88103dfff000 RCX: 0000000000000000
  RDX: 0000000000000000 RSI: ffff88081f80dfa8 RDI: ffff88081f80dfa8
  RBP: ffff880816277c90 R08: 000000000000054c R09: 0000000000000000
  R10: 0000000000000005 R11: 0000000000000006 R12: 0000000000001000
  R13: ffff88103e000000 R14: ffff88103dffffff R15: 0000000000000001
  FS:  00007fb9d1750800(0000) GS:ffff88081f800000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00000000021d2000 CR3: 000000081a08f000 CR4: 00000000001406f0
  Stack:
   ffff880816277cc8 0000000000010000 000000043de07000 0000000000000000
   0000000000001000 ffff880816277e60 0000000000001000 ffff880816277e28
   000000000000c000 0000000000001000 ffff880816277ce8 ffffffff8136c3a6
  Call Trace:
   [<ffffffff8136c3a6>] copy_page_to_iter_iovec+0xa6/0x1c0
   [<ffffffff8136e766>] copy_page_to_iter+0x16/0x90
   [<ffffffff811970e3>] generic_file_read_iter+0x3e3/0x7c0
   [<ffffffffa06a738d>] ? xfs_file_buffered_aio_write+0xad/0x260 [xfs]
   [<ffffffff816e6262>] ? down_read+0x12/0x40
   [<ffffffffa06a61b1>] xfs_file_buffered_aio_read+0x51/0xc0 [xfs]
   [<ffffffffa06a6692>] xfs_file_read_iter+0x62/0xb0 [xfs]
   [<ffffffff812224cf>] __vfs_read+0xdf/0x130
   [<ffffffff81222c9e>] vfs_read+0x8e/0x140
   [<ffffffff81224195>] SyS_read+0x55/0xc0
   [<ffffffff81003a47>] do_syscall_64+0x67/0x160
   [<ffffffff816e8421>] entry_SYSCALL64_slow_path+0x25/0x25
  RIP: 0033:[<00007fb9d0c33c00>] 0x7fb9d0c33c00
  RSP: 002b:00007ffc9c262f28 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
  RAX: ffffffffffffffda RBX: fffffffffff8ffff RCX: 00007fb9d0c33c00
  RDX: 0000000000010000 RSI: 00000000021c3000 RDI: 0000000000000004
  RBP: 00000000021c3000 R08: 0000000000000000 R09: 00007ffc9c264d6c
  R10: 00007ffc9c262c50 R11: 0000000000000246 R12: 0000000000010000
  R13: 00007ffc9c2630b0 R14: 0000000000000004 R15: 0000000000010000
  Code: 81 48 0f 44 d0 48 c7 c6 90 4d a3 81 48 c7 c0 bb b3 a2 81 48 0f 44 f0 4d 89 e1 48 89 d9 48 c7 c7 68 16 a3 81 31 c0 e8 f4 57 f7 ff <0f> 0b 48 8d 90 00 40 00 00 48 39 d3 0f 83 22 01 00 00 48 39 c3
  RIP  [<ffffffff8121c796>] __check_object_size+0x76/0x413
   RSP <ffff880816277c40>

The checked object's range [ffff88103dfff000, ffff88103e000000) is
valid, so there shouldn't have been a BUG.  The hardened usercopy code
got confused because the range's ending address is the same as the
kernel's text starting address at 0xffff88103e000000.  The overlap check
is slightly off.

Fixes: f5509cc18daa ("mm: Hardened usercopy")
Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
---
 mm/usercopy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 8ebae91..6b1c20f 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -83,7 +83,7 @@ static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
 	unsigned long check_high = check_low + n;
 
 	/* Does not overlap if entirely above or entirely below. */
-	if (check_low >= high || check_high < low)
+	if (check_low >= high || check_high <= low)
 		return false;
 
 	return true;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
