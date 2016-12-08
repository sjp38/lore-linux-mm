Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9CA26B0276
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:33 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so652794005pfx.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d2si29475052pli.315.2016.12.08.08.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 16/28] x86/asm: remove __VIRTUAL_MASK_SHIFT==47 assert
Date: Thu,  8 Dec 2016 19:21:38 +0300
Message-Id: <20161208162150.148763-18-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need it anymore. 17be0aec74fb ("x86/asm/entry/64: Implement
better check for canonical addresses") made canonical address check
generic wrt. address width.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/entry/entry_64.S | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 02fff3ebfb87..92a6753f8c85 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -267,12 +267,9 @@ return_from_SYSCALL_64:
 	 *
 	 * If width of "canonical tail" ever becomes variable, this will need
 	 * to be updated to remain correct on both old and new CPUs.
+	 *
+	 * Change top 16 bits to be the sign-extension of 47th bit
 	 */
-	.ifne __VIRTUAL_MASK_SHIFT - 47
-	.error "virtual address width changed -- SYSRET checks need update"
-	.endif
-
-	/* Change top 16 bits to be the sign-extension of 47th bit */
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
