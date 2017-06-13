Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B65C36B0365
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 09:01:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x58so63616601qtc.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:01:15 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id v28si11721085qth.285.2017.06.13.06.01.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 06:01:13 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH v2] exit: avoid undefined behaviour when call wait4
Date: Tue, 13 Jun 2017 20:53:31 +0800
Message-ID: <1497358411-53071-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jlayton@redhat.com
Cc: oleg@redhat.com, jslaby@suse.cz, viro@zeniv.linux.org.uk, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhongjiang <zhongjiang@huawei.com>

wait4(-2147483648, 0x20, 0, 0xdd0000) triggers:
UBSAN: Undefined behaviour in kernel/exit.c:1651:9

The related calltrace is as follows:

[518871.435738] negation of -2147483648 cannot be represented in type 'int':
[518871.442618] CPU: 9 PID: 16482 Comm: zj Tainted: G    B          ---- -------   3.10.0-327.53.58.71.x86_64+ #66
[518871.452874] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIOS CTSAV036 04/27/2011
[518871.464690]  ffffffff82599190 000000008b740a25 ffff880112447d90 ffffffff81d6eb16
[518871.472395]  ffff880112447da8 ffffffff81d6ebc9 ffffffff82599180 ffff880112447e98
[518871.480101]  ffffffff81d6fc99 0000000041b58ab3 ffffffff8228d698 ffffffff81d6fb90
[518871.487801] Call Trace:
[518871.490435]  [<ffffffff81d6eb16>] dump_stack+0x19/0x1b
[518871.495751]  [<ffffffff81d6ebc9>] ubsan_epilogue+0xd/0x50
[518871.501328]  [<ffffffff81d6fc99>] __ubsan_handle_negate_overflow+0x109/0x14e
[518871.508548]  [<ffffffff81d6fb90>] ? __ubsan_handle_divrem_overflow+0x1df/0x1df
[518871.516041]  [<ffffffff8116e0d4>] ? lg_local_lock+0x24/0xb0
[518871.521785]  [<ffffffff8116e640>] ? lg_local_unlock+0x20/0xd0
[518871.527708]  [<ffffffff81366fa0>] ? __pmd_alloc+0x180/0x180
[518871.533458]  [<ffffffff8143f81b>] ? mntput+0x3b/0x70
[518871.538598]  [<ffffffff8110d7bb>] SyS_wait4+0x1cb/0x1e0
[518871.543999]  [<ffffffff8110d5f0>] ? SyS_waitid+0x220/0x220
[518871.549661]  [<ffffffff8123bb57>] ? __audit_syscall_entry+0x1f7/0x2a0
[518871.556278]  [<ffffffff81d91109>] system_call_fastpath+0x16/0x1b

The patch by excluding the overflow to avoid the UBSAN warning.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 kernel/exit.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb..cfe70cf 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1701,6 +1701,10 @@ static long do_wait(struct wait_opts *wo)
 	if (upid == -1)
 		type = PIDTYPE_MAX;
 	else if (upid < 0) {
+		/* -INT_MIN is not defined */
+		if (upid == INT_MIN)
+			return -ESRCH;
+
 		type = PIDTYPE_PGID;
 		pid = find_get_pid(-upid);
 	} else if (upid == 0) {
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
