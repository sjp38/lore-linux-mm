Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89F916B025F
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 19:39:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so423799538pfg.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:39:49 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id u3si11192774pay.67.2016.08.03.16.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 16:39:48 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH v3 2/7] x86: Use simpler API for random address requests
Date: Wed,  3 Aug 2016 23:39:08 +0000
Message-Id: <20160803233913.32511-3-jason@lakedaemon.net>
In-Reply-To: <20160803233913.32511-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160803233913.32511-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>, Jason Cooper <jason@lakedaemon.net>

Currently, all callers to randomize_range() set the length to 0 and
calculate end by adding a constant to the start address.  We can
simplify the API to remove a bunch of needless checks and variables.

Use the new randomize_addr(start, range) call to set the requested
address.

Signed-off-by: Jason Cooper <jason@lakedaemon.net>
---
Changes from v2:
 - s/randomize_addr/randomize_page/ (Kees Cook)

 arch/x86/kernel/process.c    | 3 +--
 arch/x86/kernel/sys_x86_64.c | 5 +----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 96becbbb52e0..8ca7f42d97f3 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -507,8 +507,7 @@ unsigned long arch_align_stack(unsigned long sp)
 
 unsigned long arch_randomize_brk(struct mm_struct *mm)
 {
-	unsigned long range_end = mm->brk + 0x02000000;
-	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
+	return randomize_page(mm->brk, 0x02000000);
 }
 
 /*
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 10e0272d789a..a55ed63b9f91 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -101,7 +101,6 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
 	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
-		unsigned long new_begin;
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
 		   it to that.  This means we need to move the
@@ -112,9 +111,7 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 		*begin = 0x40000000;
 		*end = 0x80000000;
 		if (current->flags & PF_RANDOMIZE) {
-			new_begin = randomize_range(*begin, *begin + 0x02000000, 0);
-			if (new_begin)
-				*begin = new_begin;
+			*begin = randomize_page(*begin, 0x02000000);
 		}
 	} else {
 		*begin = current->mm->mmap_legacy_base;
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
