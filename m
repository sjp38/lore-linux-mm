Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1F66B025F
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:43:08 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so45999423pab.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:43:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id wu1si3928300pab.71.2016.01.29.11.43.07
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 11:43:07 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 3/3] x86/mm: If INVPCID is available, use it to flush global mappings
Date: Fri, 29 Jan 2016 11:42:59 -0800
Message-Id: <ed0ef62581c0ea9c99b9bf6df726015e96d44743.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
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
index 8b576832777e..985f1162c505 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -152,6 +152,15 @@ static inline void __native_flush_tlb_global(void)
 {
 	unsigned long flags;
 
+	if (static_cpu_has_safe(X86_FEATURE_INVPCID)) {
+		/*
+		 * Using INVPCID is considerably faster than a pair of writes
+		 * to CR4 sandwiched inside an IRQ flag save/restore.
+		 */
+		invpcid_flush_all();
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
