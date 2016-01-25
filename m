Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C19CA6B0256
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:37:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so84459796pab.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:37:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id rp7si35138147pab.99.2016.01.25.10.37.50
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 10:37:50 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 3/3] x86/mm: If INVPCID is available, use it to flush global mappings
Date: Mon, 25 Jan 2016 10:37:44 -0800
Message-Id: <e3e4f31df42ea5d5e190a6d1e300e01d55e09d79.1453746505.git.luto@kernel.org>
In-Reply-To: <cover.1453746505.git.luto@kernel.org>
References: <cover.1453746505.git.luto@kernel.org>
In-Reply-To: <cover.1453746505.git.luto@kernel.org>
References: <cover.1453746505.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>

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
