Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95CB76B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n6so2168304pfg.19
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r21si1067114pgr.31.2017.11.29.02.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:49 -0800 (PST)
Message-Id: <20171129103512.918991807@infradead.org>
Date: Wed, 29 Nov 2017 11:33:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 6/6] x86/mm/kaiser: Optimize __native_flush_tlb
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-opt-tlb.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Now that we have lazy user asid flushing, use that even if we have
INVPCID. Even if INVPCID would not be slower than a flushing CR3 write
(it is) this allows folding multiple user flushes.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |   38 ++++++++++++++------------------------
 1 file changed, 14 insertions(+), 24 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -377,33 +377,23 @@ static inline void flush_user_asid(u16 a
 
 static inline void __native_flush_tlb(void)
 {
-	if (!cpu_feature_enabled(X86_FEATURE_INVPCID)) {
-		flush_user_asid(this_cpu_read(cpu_tlbstate.loaded_mm_asid));
+	flush_user_asid(this_cpu_read(cpu_tlbstate.loaded_mm_asid));
 
-		/*
-		 * If current->mm == NULL then we borrow a mm
-		 * which may change during a task switch and
-		 * therefore we must not be preempted while we
-		 * write CR3 back:
-		 */
-		preempt_disable();
-		native_write_cr3(__native_read_cr3());
-		preempt_enable();
-		/*
-		 * Does not need tlb_flush_shared_nonglobals()
-		 * since the CR3 write without PCIDs flushes all
-		 * non-globals.
-		 */
-		return;
-	}
 	/*
-	 * We are no longer using globals with KAISER, so a
-	 * "nonglobals" flush would work too. But, this is more
-	 * conservative.
-	 *
-	 * Note, this works with CR4.PCIDE=0 or 1.
+	 * If current->mm == NULL then we borrow a mm
+	 * which may change during a task switch and
+	 * therefore we must not be preempted while we
+	 * write CR3 back:
 	 */
-	invpcid_flush_all();
+	preempt_disable();
+	native_write_cr3(__native_read_cr3());
+	preempt_enable();
+	/*
+	 * Does not need tlb_flush_shared_nonglobals()
+	 * since the CR3 write without PCIDs flushes all
+	 * non-globals.
+	 */
+	return;
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
