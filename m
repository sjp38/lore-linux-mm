Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 66B83828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:49 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id uo6so271556877pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:49 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id ww1si19628688pab.181.2016.01.08.15.15.48
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:48 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB using CR3
Date: Fri,  8 Jan 2016 15:15:27 -0800
Message-Id: <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 3d905f12cda9..32e3d8769a22 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -135,7 +135,17 @@ static inline void cr4_set_bits_and_update_boot(unsigned long mask)
 
 static inline void __native_flush_tlb(void)
 {
+	unsigned long flags;
+
+	/*
+	 * We mustn't be preempted or handle an IPI while reading and
+	 * writing CR3.  Preemption could switch mms and switch back, and
+	 * an IPI could call leave_mm.  Either of those could cause our
+	 * PCID to change asynchronously.
+	 */
+	raw_local_irq_save(flags);
 	native_write_cr3(native_read_cr3());
+	raw_local_irq_restore(flags);
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
