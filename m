Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA2A828E4
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:25:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so78647684pfd.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:25:48 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id j80si14261047pfa.194.2016.07.28.14.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 14:25:47 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH 6/7] unicore32: Use simpler API for random address requests
Date: Thu, 28 Jul 2016 20:47:29 +0000
Message-Id: <20160728204730.27453-7-jason@lakedaemon.net>
In-Reply-To: <20160728204730.27453-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: william.c.roberts@intel.com, Yann Droneaud <ydroneaud@opteya.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, will.deacon@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com, Jason Cooper <jason@lakedaemon.net>

Currently, all callers to randomize_range() set the length to 0 and
calculate end by adding a constant to the start address.  We can
simplify the API to remove a bunch of needless checks and variables.

Use the new randomize_addr(start, range) call to set the requested
address.

Signed-off-by: Jason Cooper <jason@lakedaemon.net>
---
 arch/unicore32/kernel/process.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index 00299c927852..b856178cf167 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -295,8 +295,7 @@ unsigned long get_wchan(struct task_struct *p)
 
 unsigned long arch_randomize_brk(struct mm_struct *mm)
 {
-	unsigned long range_end = mm->brk + 0x02000000;
-	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
+	return randomize_addr(mm->brk, 0x02000000);
 }
 
 /*
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
