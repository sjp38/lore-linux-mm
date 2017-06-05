Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1BA6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 09:54:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k30so11496562wrc.9
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 06:54:04 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id r18si5460733wrc.172.2017.06.05.06.54.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 06:54:02 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v3] signal: Avoid undefined behaviour in kill_something_info
Date: Mon, 5 Jun 2017 21:40:08 +0800
Message-ID: <1496670008-59084-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: oleg@redhat.com, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com, zhongjiang@huawei.com

when I run the kill(72057458746458112, 0) in the userspace, I hit
the following issue.

[  304.606353] UBSAN: Undefined behaviour in kernel/signal.c:1462:11
[  304.612622] negation of -2147483648 cannot be represented in type 'int':
[  304.619516] CPU: 226 PID: 9849 Comm: test Tainted: G    B          ---- -------   3.10.0-327.53.58.70.x86_64_ubsan+ #116
[  304.630692] Hardware name: Huawei Technologies Co., Ltd. RH8100 V3/BC61PBIA, BIOS BLHSV028 11/11/2014
[  304.640168]  ffffffff825ded30 000000005dc276fa ffff883c3a4b7ce0 ffffffff81d6eb06
[  304.647870]  ffff883c3a4b7cf8 ffffffff81d6ebb9 ffffffff825ded20 ffff883c3a4b7de8
[  304.655584]  ffffffff81d6fc89 0000000041b58ab3 ffffffff8228d6d8 ffffffff81d6fb80
[  304.663299] Call Trace:
[  304.665827]  [<ffffffff81d6eb06>] dump_stack+0x19/0x1b
[  304.671115]  [<ffffffff81d6ebb9>] ubsan_epilogue+0xd/0x50
[  304.676668]  [<ffffffff81d6fc89>] __ubsan_handle_negate_overflow+0x109/0x14e
[  304.683917]  [<ffffffff81d6fb80>] ? __ubsan_handle_divrem_overflow+0x1df/0x1df
[  304.691353]  [<ffffffff8134a129>] ? __inc_zone_state+0x29/0xf0
[  304.697358]  [<ffffffff813272df>] ? __lru_cache_add+0x8f/0xe0
[  304.703272]  [<ffffffff8132764e>] ? lru_cache_add+0xe/0x10
[  304.708921]  [<ffffffff812263bd>] ? map_id_up+0xad/0xe0
[  304.714306]  [<ffffffff8113126e>] SYSC_kill+0x43e/0x4d0
[  304.725359]  [<ffffffff8116e630>] ? lg_local_unlock+0x20/0xd0
[  304.736978]  [<ffffffff81130e30>] ? kill_pid+0x20/0x20
[  304.747928]  [<ffffffff81366f90>] ? __pmd_alloc+0x180/0x180
[  304.759273]  [<ffffffff8143f80b>] ? mntput+0x3b/0x70
[  304.769919]  [<ffffffff81d85c3c>] ? __do_page_fault+0x2bc/0x650
[  304.781462]  [<ffffffff8123bb47>] ? __audit_syscall_entry+0x1f7/0x2a0
[  304.793476]  [<ffffffff8113535e>] SyS_kill+0xe/0x10
[  304.803859]  [<ffffffff81d91109>] system_call_fastpath+0x16/0x1b

The patch add particular case to avoid the UBSAN detection.

Signed-off-by: zhongjiang <zhongjiang@huawei.com>
---
 kernel/signal.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/signal.c b/kernel/signal.c
index ca92bcf..1c3fd9a 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1393,6 +1393,13 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
 		return ret;
 	}
 
+	/*
+	 * -INT_MIN is undefined, it need to exclude following case to
+	 * avoid the UBSAN detection.
+	 */
+	if (pid == INT_MIN)
+		return -ESRCH;
+
 	read_lock(&tasklist_lock);
 	if (pid != -1) {
 		ret = __kill_pgrp_info(sig, info,
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
