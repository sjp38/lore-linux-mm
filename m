Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EED29828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:42 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id e65so15938292pfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:42 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id d16si7950622pfb.152.2016.01.08.15.15.42
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:42 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 04/13] x86/mm: If INVPCID is available, use it to flush global mappings
Date: Fri,  8 Jan 2016 15:15:22 -0800
Message-Id: <1ddac818ae831c89dc4f680bbf4bfac7b6ba2b4c.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

On my Skylake laptop, INVPCID function 2 (flush absolutely
everything) takes about 376ns, whereas saving flags, twiddling
CR4.PGE to flush global mappings, and restoring flags takes about
539ns.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 20fc38d8478a..4eba5164430d 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -145,6 +145,15 @@ static inline void __native_flush_tlb_global(void)
 {
 	unsigned long flags;
 
+	if (static_cpu_has_safe(X86_FEATURE_INVPCID)) {
+		/*
+		 * Using INVPCID is considerably faster than a pair of writes
+		 * to CR4 sandwiched inside an IRQ flag save/restore.
+		 */
+		invpcid_flush_everything();
+		return;
+	}
+
 	/*
 	 * Read-modify-write to CR4 - protect it from preemption and
 	 * from interrupts. (Use the raw variant because this code can
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
