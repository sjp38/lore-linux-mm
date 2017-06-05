Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73AEB6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h4so174558809oib.5
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:06 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n52si11943616otd.72.2017.06.05.15.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:05 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 02/11] x86/mm: Remove reset_lazy_tlbstate()
Date: Mon,  5 Jun 2017 15:36:26 -0700
Message-Id: <4b5fe3931b9b33282865d9582061c98598852e9c.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

The only call site also calls idle_task_exit(), and idle_task_exit()
puts us into a clean state by explicitly switching to init_mm.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 8 --------
 arch/x86/kernel/smpboot.c       | 1 -
 2 files changed, 9 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 388c2463fde6..ee5a138602e8 100644
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
-	WARN_ON(read_cr3() != __pa_symbol(swapper_pg_dir));
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
