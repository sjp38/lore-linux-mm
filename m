Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E915A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 22:04:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b35so67154874qta.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 19:04:51 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id b65si58842vkd.219.2016.07.19.19.04.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 19:04:51 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] kexec: add resriction on the kexec_load
Date: Wed, 20 Jul 2016 10:00:49 +0800
Message-ID: <1468980049-1753-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiederm@xmission.com, yinghai@kernel.org, horms@verge.net.au, akpm@linux-foundation.org
Cc: kexec@lists.infradead.org, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

I hit the following question when run trinity in my system. The
kernel is 3.4 version. but the mainline have same question to be
solved. The root cause is the segment size is too large, it can
expand the most of the area or the whole memory, therefore, it
may waste an amount of time to abtain a useable page. and other
cases will block until the test case quit. at the some time,
OOM will come up.

ck time:20160628120131-243c5
rlock reason:SOFT-WATCHDOG detected! on cpu 5.
CPU 5 Pid: 9485, comm: trinity-c5
RIP: 0010:[<ffffffff8111a4cf>]  [<ffffffff8111a4cf>] next_zones_zonelist+0x3f/0x60
RSP: 0018:ffff88088783bc38  EFLAGS: 00000283
RAX: ffff8808bffd9b08 RBX: ffff88088783bbb8 RCX: ffff88088783bd30
RDX: ffff88088f15a248 RSI: 0000000000000002 RDI: 0000000000000000
RBP: ffff88088783bc38 R08: ffff8808bffd8d80 R09: 0000000412c4d000
R10: 0000000412c4e000 R11: 0000000000000000 R12: 0000000000000002
R13: 0000000000000000 R14: ffff8808bffd9b00 R15: 0000000000000000
FS:  00007f91137ee700(0000) GS:ffff88089f2a0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000016161a CR3: 0000000887820000 CR4: 00000000000407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-c5 (pid: 9485, threadinfo ffff88088783a000, task ffff88088f159980)
Stack:
 ffff88088783bd88 ffffffff81106eac ffff8808bffd8d80 0000000000000000
 0000000000000000 ffffffff8124c2be 0000000000000001 000000000000001e
 0000000000000000 ffffffff8124c2be 0000000000000002 ffffffff8124c2be
Call Trace:
 [<ffffffff81106eac>] __alloc_pages_nodemask+0x14c/0x8f0
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8113e5ef>] alloc_pages_current+0xaf/0x120
 [<ffffffff810a0da0>] kimage_alloc_pages+0x10/0x60
 [<ffffffff810a15ad>] kimage_alloc_control_pages+0x5d/0x270
 [<ffffffff81027e85>] machine_kexec_prepare+0xe5/0x6c0
 [<ffffffff810a0d52>] ? kimage_free_page_list+0x52/0x70
 [<ffffffff810a1921>] sys_kexec_load+0x141/0x600
 [<ffffffff8115e6b0>] ? vfs_write+0x100/0x180
 [<ffffffff8145fbd9>] system_call_fastpath+0x16/0x1b

The patch just add condition on sanity_check_segment_list to
restriction the segment size.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/x86/include/asm/kexec.h |  1 +
 kernel/kexec_core.c          | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index d2434c1..b31a723 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -67,6 +67,7 @@ struct kimage;
 /* Memory to backup during crash kdump */
 #define KEXEC_BACKUP_SRC_START	(0UL)
 #define KEXEC_BACKUP_SRC_END	(640 * 1024UL)	/* 640K */
+#define KEXEC_MAX_SEGMENT_SIZE	(5 * 1024 * 1024UL)	/* 5M */
 
 /*
  * CPU does not save ss and sp on stack if execution is already
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 448127d..35c5159 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -209,6 +209,18 @@ int sanity_check_segment_list(struct kimage *image)
 			return result;
 	}
 
+
+	/* Verity all segment size donnot exceed the specified size.
+ 	 * if segment size from user space is too large,  a large 
+ 	 * amount of time will be wasted when allocating page. so,
+ 	 * softlockup may be come up.
+ 	 */
+	for (i = 0; i< nr_segments; i++) {
+		if (image->segment[i].memsz > KEXEC_MAX_SEGMENT_SIZE)
+			return result;
+	}
+
+
 	/*
 	 * Verify we have good destination addresses.  Normally
 	 * the caller is responsible for making certain we don't
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
