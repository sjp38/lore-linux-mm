Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAA46B03E2
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:51:56 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id f20so118215526otd.9
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:51:56 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id t11si5047866oib.369.2017.06.21.04.51.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 04:51:54 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH] futex: avoid undefined behaviour when shift exponent is negative
Date: Wed, 21 Jun 2017 19:43:57 +0800
Message-ID: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tglx@linutronix.de, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

when futex syscall is called from userspace, we find the following
warning by ubsan detection.

[   63.237803] UBSAN: Undefined behaviour in /root/rpmbuild/BUILDROOT/kernel-3.10.0-327.49.58.52.x86_64/usr/src/linux-3.10.0-327.49.58.52.x86_64/arch/x86/include/asm/futex.h:53:13
[   63.237803] shift exponent -16 is negative
[   63.237803] CPU: 0 PID: 67 Comm: driver Not tainted 3.10.0 #1
[   63.237803] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.1-0-g4adadbd-20150316_085822-nilsson.home.kraxel.org 04/01/2014
[   63.237803]  fffffffffffffff0 000000009ad70fde ffff88000002fa08 ffffffff81ef0d6f
[   63.237803]  ffff88000002fa20 ffffffff81ef0e2c ffffffff828f2540 ffff88000002fb90
[   63.237803]  ffffffff81ef1ad0 ffffffff8141cc88 1ffff10000005f48 0000000041b58ab3
[   63.237803] Call Trace:
[   63.237803]  [<ffffffff81ef0d6f>] dump_stack+0x1e/0x20
[   63.237803]  [<ffffffff81ef0e2c>] ubsan_epilogue+0x12/0x55
[   63.237803]  [<ffffffff81ef1ad0>] __ubsan_handle_shift_out_of_bounds+0x237/0x29c
[   63.237803]  [<ffffffff8141cc88>] ? kasan_alloc_pages+0x38/0x40
[   63.237803]  [<ffffffff81ef1899>] ? __ubsan_handle_load_invalid_value+0x162/0x162
[   63.237803]  [<ffffffff812092c1>] ? get_futex_key+0x361/0x6c0
[   63.237803]  [<ffffffff81208f60>] ? get_futex_key_refs+0xb0/0xb0
[   63.237803]  [<ffffffff8120b938>] futex_wake_op+0xb48/0xc70
[   63.237803]  [<ffffffff8120b938>] ? futex_wake_op+0xb48/0xc70
[   63.237803]  [<ffffffff8120adf0>] ? futex_wake+0x380/0x380
[   63.237803]  [<ffffffff8121006c>] do_futex+0x2cc/0xb60
[   63.237803]  [<ffffffff8120fda0>] ? exit_robust_list+0x350/0x350
[   63.237803]  [<ffffffff814fa140>] ? __fsnotify_inode_delete+0x20/0x20
[   63.237803]  [<ffffffff818cabc0>] ? n_tty_flush_buffer+0x80/0x80
[   63.237803]  [<ffffffff814faed3>] ? __fsnotify_parent+0x53/0x210
[   63.237803]  [<ffffffff81210a47>] SyS_futex+0x147/0x300
[   63.237803]  [<ffffffff81210900>] ? do_futex+0xb60/0xb60
[   63.237803]  [<ffffffff81f0a134>] ? do_page_fault+0x44/0xa0
[   63.237803]  [<ffffffff81f16809>] system_call_fastpath+0x16/0x1b

when shift expoment is negative, left shift alway zero. therefore, we
modify the logic to avoid the warining.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/x86/include/asm/futex.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
index b4c1f54..2425fca 100644
--- a/arch/x86/include/asm/futex.h
+++ b/arch/x86/include/asm/futex.h
@@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret, tem;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
+	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
+		if (oparg >= 0)
+			oparg = 1 << oparg;
+		else
+			oparg = 0;
+	}
 
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
 		return -EFAULT;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
