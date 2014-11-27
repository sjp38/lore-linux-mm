Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id CF0AF6B006E
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:30 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so5085204pdj.23
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:30 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id s4si12168409pdj.117.2014.11.27.08.01.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:28 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP0013HGN4CR70@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:16 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 02/12] x86_64: load_percpu_segment: read
 irq_stack_union.gs_base before load_segment
Date: Thu, 27 Nov 2014 19:00:46 +0300
Message-id: <1417104057-20335-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

Reading irq_stack_union.gs_base after load_segment creates troubles for kasan.
Compiler inserts __asan_load in between load_segment and wrmsrl. If kernel
built with stackprotector this will result in boot failure because __asan_load
has stackprotector.

To avoid this irq_stack_union.gs_base stored to temporary variable before
load_segment, so __asan_load will be called before load_segment().

There are two alternative ways to fix this:
 a) Add __attribute__((no_sanitize_address)) to load_percpu_segment(),
    which tells compiler to not instrument this function. However this
    will result in build failure with CONFIG_KASAN=y and CONFIG_OPTIMIZE_INLINING=y.

 b) Add -fno-stack-protector for mm/kasan/kasan.c

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/kernel/cpu/common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 5475f67..1291d69 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -391,8 +391,10 @@ void load_percpu_segment(int cpu)
 #ifdef CONFIG_X86_32
 	loadsegment(fs, __KERNEL_PERCPU);
 #else
+	void *gs_base = per_cpu(irq_stack_union.gs_base, cpu);
+
 	loadsegment(gs, 0);
-	wrmsrl(MSR_GS_BASE, (unsigned long)per_cpu(irq_stack_union.gs_base, cpu));
+	wrmsrl(MSR_GS_BASE, (unsigned long)gs_base);
 #endif
 	load_stack_canary_segment();
 }
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
