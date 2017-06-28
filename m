Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73E4D6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:03:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 21so8673569wmt.15
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:03:22 -0700 (PDT)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id r16si1449097wra.40.2017.06.28.03.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 03:03:21 -0700 (PDT)
Date: Wed, 28 Jun 2017 12:02:46 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@redhat.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

Trying to boot tip/master resulted in:
|DMAR: dmar0: Using Queued invalidation
|DMAR: dmar1: Using Queued invalidation
|DMAR: Setting RMRR:
|DMAR: Setting identity map for device 0000:00:1a.0 [0xbdcf9000 - 0xbdd1dfff]
|BUG: unable to handle kernel NULL pointer dereference at           (null)
|IP: __domain_mapping+0x10f/0x3d0
|PGD 0
|P4D 0
|
|Oops: 0002 [#1] PREEMPT SMP
|Modules linked in:
|CPU: 19 PID: 1 Comm: swapper/0 Not tainted 4.12.0-rc6-00117-g235a93822a21 #113
|task: ffff8805271c2c80 task.stack: ffffc90000058000
|RIP: 0010:__domain_mapping+0x10f/0x3d0
|RSP: 0000:ffffc9000005bca0 EFLAGS: 00010246
|RAX: 0000000000000000 RBX: 00000000bdcf9003 RCX: 0000000000000000
|RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
|RBP: ffffc9000005bd00 R08: ffff880a243e9780 R09: ffff8805259e67c8
|R10: 00000000000bdcf9 R11: 0000000000000000 R12: 0000000000000025
|R13: 0000000000000025 R14: 0000000000000000 R15: 00000000000bdcf9
|FS:  0000000000000000(0000) GS:ffff88052acc0000(0000) knlGS:0000000000000000
|CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
|CR2: 0000000000000000 CR3: 0000000001c0f000 CR4: 00000000000406e0
|Call Trace:
| iommu_domain_identity_map+0x5a/0x80
| domain_prepare_identity_map+0x9f/0x160
| iommu_prepare_identity_map+0x7e/0x9b

bisect points to commit 235a93822a21 ("locking/atomics, asm-generic: Add KASAN
instrumentation to atomic operations"), RIP is at
	 tmp = cmpxchg64_local(&pte->val, 0ULL, pteval);
in drivers/iommu/intel-iommu.c. The assembly for this inline assembly
is:
    xor    %edx,%edx
    xor    %eax,%eax
    cmpxchg %rbx,(%rdx)

and as you see edx is set to zero and used later as a pointer via the
full register. This happens with gcc-6, 5 and 8 (snapshot from last
week).
After a longer while of searching and swearing I figured out that this
bug occures once cmpxchg64_local() and cmpxchg_local() uses the same
____ptr macro and they are shadow somehow. What I don't know why edx is
set to zero.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/asm-generic/atomic-instrumented.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index a0f5b7525bb2..ac6155362b39 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -359,16 +359,16 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
 
 #define cmpxchg64(ptr, old, new)			\
 ({							\
-	__typeof__(ptr) ____ptr = (ptr);		\
-	kasan_check_write(____ptr, sizeof(*____ptr));	\
-	arch_cmpxchg64(____ptr, (old), (new));		\
+	__typeof__(ptr) ____ptr64 = (ptr);		\
+	kasan_check_write(____ptr64, sizeof(*____ptr64));\
+	arch_cmpxchg64(____ptr64, (old), (new));	\
 })
 
 #define cmpxchg64_local(ptr, old, new)			\
 ({							\
-	__typeof__(ptr) ____ptr = (ptr);		\
-	kasan_check_write(____ptr, sizeof(*____ptr));	\
-	arch_cmpxchg64_local(____ptr, (old), (new));	\
+	__typeof__(ptr) ____ptr64 = (ptr);		\
+	kasan_check_write(____ptr64, sizeof(*____ptr64));\
+	arch_cmpxchg64_local(____ptr64, (old), (new));	\
 })
 
 #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
