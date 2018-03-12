Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A92476B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:02:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bb5-v6so8339878plb.22
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 03:02:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b66si3050064pgc.148.2018.03.12.03.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 03:02:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] x86/boot/compressed/64: Make sure we have 32-bit code segment
Date: Mon, 12 Mar 2018 13:02:43 +0300
Message-Id: <20180312100246.89175-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
References: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

When kernel starts in 64-bit mode we inherit GDT from a bootloader.
It may cause a problem if the GDT doesn't have 32-bit code segment
where we expect it to be.

Load our own GDT with known segments.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index c813cb004056..f0c3a2f7e528 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -313,6 +313,11 @@ ENTRY(startup_64)
 	 * first.
 	 */
 
+	/* Make sure we have GDT with 32-bit code segment */
+	leaq	gdt(%rip), %rax
+	movq	%rax, gdt64+2(%rip)
+	lgdt	gdt64(%rip)
+
 	/*
 	 * paging_prepare() sets up the trampoline and checks if we need to
 	 * enable 5-level paging.
@@ -547,6 +552,11 @@ no_longmode:
 #include "../../kernel/verify_cpu.S"
 
 	.data
+gdt64:
+	.word	gdt_end - gdt
+	.long	0
+	.word	0
+	.quad   0
 gdt:
 	.word	gdt_end - gdt
 	.long	gdt
-- 
2.16.1
