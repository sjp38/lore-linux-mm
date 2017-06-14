Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id D530D6B0292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:56:37 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a30so65071293otd.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:56:37 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q125si1080134oic.174.2017.06.13.21.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 21:56:37 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 02/10] x86/mm: Remove reset_lazy_tlbstate()
Date: Tue, 13 Jun 2017 21:56:20 -0700
Message-Id: <7e505cd9680b60f6995443bd1320deb7689125f0.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

The only call site also calls idle_task_exit(), and idle_task_exit()
puts us into a clean state by explicitly switching to init_mm.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 8 --------
 arch/x86/kernel/smpboot.c       | 1 -
 2 files changed, 9 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 5f78c6a77578..50ea3482e1d1 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -259,14 +259,6 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 #define TLBSTATE_OK	1
 #define TLBSTATE_LAZY	2
 
-static inline void reset_lazy_tlbstate(void)
-{
-	this_cpu_write(cpu_tlbstate.state, 0);
-	this_cpu_write(cpu_tlbstate.loaded_mm, &init_mm);
-
-	WARN_ON(read_cr3_pa() != __pa_symbol(swapper_pg_dir));
-}
-
 static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 					struct mm_struct *mm)
 {
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index f04479a8f74f..6169a56aab49 100644
--- a/arch/x86/kernel/smpboot.c
+++ b/arch/x86/kernel/smpboot.c
@@ -1589,7 +1589,6 @@ void native_cpu_die(unsigned int cpu)
 void play_dead_common(void)
 {
 	idle_task_exit();
-	reset_lazy_tlbstate();
 
 	/* Ack it */
 	(void)cpu_report_death();
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
