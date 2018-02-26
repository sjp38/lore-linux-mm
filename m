Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA9B06B000C
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:05:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i11so5831071pgq.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:05:04 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r2si5761764pgp.704.2018.02.26.10.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:05:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/5] x86/boot/compressed/64: Describe the logic behind LA57 check
Date: Mon, 26 Feb 2018 21:04:47 +0300
Message-Id: <20180226180451.86788-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch explains the LA57 check in more details.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/pgtable_64.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 3f1697fcc7a8..45c76eff2718 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -18,10 +18,22 @@ struct paging_config paging_prepare(void)
 {
 	struct paging_config paging_config = {};
 
-	/* Check if LA57 is desired and supported */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL) && native_cpuid_eax(0) >= 7 &&
-			(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
+	/*
+	 * Check if LA57 is desired and supported.
+	 *
+	 * There are two parts to the check:
+	 *   - if the kernel supports 5-level paging: CONFIG_X86_5LEVEL=y
+	 *   - if the machine supports 5-level paging:
+	 *     + CPUID leaf 7 is supported
+	 *     + the leaf has the feature bit set
+	 *
+	 * That's substitute for boot_cpu_has() in early boot code.
+	 */
+	if (IS_ENABLED(CONFIG_X86_5LEVEL) &&
+			native_cpuid_eax(0) >= 7 &&
+			(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31)))) {
 		paging_config.l5_required = 1;
+	}
 
 	return paging_config;
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
