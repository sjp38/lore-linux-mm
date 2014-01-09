Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0F12C6B003B
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:35:08 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so1156203bkz.14
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:35:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si4077342eew.139.2014.01.09.06.35.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:35:07 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/5] mm: x86: Revisit tlb_flushall_shift tuning for page flushes except on IvyBridge
Date: Thu,  9 Jan 2014 14:34:58 +0000
Message-Id: <1389278098-27154-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-1-git-send-email-mgorman@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There was a large ebizzy performance regression that was bisected to commit
611ae8e3 (x86/tlb: enable tlb flush range support for x86). The problem
was related to the tlb_flushall_shift tuning for IvyBridge which was
altered. The problem is that it is not clear if the tuning values for each
CPU family is correct as the methodology used to tune the values is unclear.

This patch uses a conservative tlb_flushall_shift value for all CPU families
except IvyBridge so the decision can be revisited if any regression is found
as a result of this change. IvyBridge is an exception as testing with one
methodology determined that the value of 2 is acceptable. Details are in the
changelog for the patch "x86: mm: Change tlb_flushall_shift for IvyBridge".

One important aspect of this to watch out for is Xen. The original commit
log mentioned large performance gains on Xen. It's possible Xen is more
sensitive to this value if it flushes small ranges of pages more frequently
than workloads on bare metal typically do.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/kernel/cpu/amd.c   |  5 +----
 arch/x86/kernel/cpu/intel.c | 10 +++-------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index bca023b..7aa2545 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -758,10 +758,7 @@ static unsigned int amd_size_cache(struct cpuinfo_x86 *c, unsigned int size)
 
 static void cpu_set_tlb_flushall_shift(struct cpuinfo_x86 *c)
 {
-	tlb_flushall_shift = 5;
-
-	if (c->x86 <= 0x11)
-		tlb_flushall_shift = 4;
+	tlb_flushall_shift = 6;
 }
 
 static void cpu_detect_tlb_amd(struct cpuinfo_x86 *c)
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index bbe1b8b..d358a39 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -615,21 +615,17 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
 	case 0x61d: /* six-core 45 nm xeon "Dunnington" */
 		tlb_flushall_shift = -1;
 		break;
+	case 0x63a: /* Ivybridge */
+		tlb_flushall_shift = 2;
+		break;
 	case 0x61a: /* 45 nm nehalem, "Bloomfield" */
 	case 0x61e: /* 45 nm nehalem, "Lynnfield" */
 	case 0x625: /* 32 nm nehalem, "Clarkdale" */
 	case 0x62c: /* 32 nm nehalem, "Gulftown" */
 	case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
 	case 0x62f: /* 32 nm Xeon E7 */
-		tlb_flushall_shift = 6;
-		break;
 	case 0x62a: /* SandyBridge */
 	case 0x62d: /* SandyBridge, "Romely-EP" */
-		tlb_flushall_shift = 5;
-		break;
-	case 0x63a: /* Ivybridge */
-		tlb_flushall_shift = 2;
-		break;
 	default:
 		tlb_flushall_shift = 6;
 	}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
