Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B13836B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 05:49:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v5so47631604pgv.12
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:49:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0104.outbound.protection.outlook.com. [104.47.2.104])
        by mx.google.com with ESMTPS id q18si12769808pgd.436.2017.07.17.02.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 02:49:23 -0700 (PDT)
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: [PATCH] x86/mm, KVM: fix warning when !CONFIG_PREEMPT_COUNT
Date: Mon, 17 Jul 2017 12:49:07 +0300
Message-Id: <20170717094907.6089-1-rkagan@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bpetkov@suse.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav Amit <namit@vmware.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, kvm@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

Recent commit d6e41f1151fe ("x86/mm, KVM: Teach KVM's VMX code that CR3
isn't a constant") introduced a VM_WARN_ON(!in_atomic()) which generates
false positives on every vm entry on !CONFIG_PREEMPT_COUNT kernels.

Replace it with a test for preemptible(), which appears to match the
original intent and works across different CONFIG_PREEMPT* variations.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: X86 ML <x86@kernel.org>
Cc: kvm@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@kernel.org>
Fixes: d6e41f1151fe ("x86/mm, KVM: Teach KVM's VMX code that CR3 isn't a constant")
Signed-off-by: Roman Kagan <rkagan@virtuozzo.com>
---
 arch/x86/include/asm/mmu_context.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index ecfcb6643c9b..265c907d7d4c 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -293,7 +293,7 @@ static inline unsigned long __get_current_cr3_fast(void)
 	unsigned long cr3 = __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd);
 
 	/* For now, be very restrictive about when this can be called. */
-	VM_WARN_ON(in_nmi() || !in_atomic());
+	VM_WARN_ON(in_nmi() || preemptible());
 
 	VM_BUG_ON(cr3 != __read_cr3());
 	return cr3;
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
