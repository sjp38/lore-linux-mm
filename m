Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4979A6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 12:05:03 -0500 (EST)
Received: by wmww144 with SMTP id w144so9466799wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 09:05:02 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id m131si6599632wmb.65.2015.11.10.09.05.00
        for <linux-mm@kvack.org>;
        Tue, 10 Nov 2015 09:05:00 -0800 (PST)
Date: Tue, 10 Nov 2015 18:04:47 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151110170447.GH19187@pd.tnic>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20151110150713.GA11956@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>

On Tue, Nov 10, 2015 at 05:07:13PM +0200, Kirill A. Shutemov wrote:
> Yeah. Looks good to me.

It gets even cleaner. Let me run it through the *config build tests.

---
diff --git a/arch/x86/boot/boot.h b/arch/x86/boot/boot.h
index 0033e96c3f09..9011a88353de 100644
--- a/arch/x86/boot/boot.h
+++ b/arch/x86/boot/boot.h
@@ -23,7 +23,6 @@
 #include <stdarg.h>
 #include <linux/types.h>
 #include <linux/edd.h>
-#include <asm/boot.h>
 #include <asm/setup.h>
 #include "bitops.h"
 #include "ctype.h"
diff --git a/arch/x86/boot/video-mode.c b/arch/x86/boot/video-mode.c
index aa8a96b052e3..95c7a818c0ed 100644
--- a/arch/x86/boot/video-mode.c
+++ b/arch/x86/boot/video-mode.c
@@ -19,6 +19,8 @@
 #include "video.h"
 #include "vesa.h"
 
+#include <uapi/asm/boot.h>
+
 /*
  * Common variables
  */
diff --git a/arch/x86/boot/video.c b/arch/x86/boot/video.c
index 05111bb8d018..77780e386e9b 100644
--- a/arch/x86/boot/video.c
+++ b/arch/x86/boot/video.c
@@ -13,6 +13,8 @@
  * Select video mode
  */
 
+#include <uapi/asm/boot.h>
+
 #include "boot.h"
 #include "video.h"
 #include "vesa.h"
diff --git a/arch/x86/include/asm/x86_init.h b/arch/x86/include/asm/x86_init.h
index 48d34d28f5a6..cd0fc0cc78bc 100644
--- a/arch/x86/include/asm/x86_init.h
+++ b/arch/x86/include/asm/x86_init.h
@@ -1,7 +1,6 @@
 #ifndef _ASM_X86_PLATFORM_H
 #define _ASM_X86_PLATFORM_H
 
-#include <asm/pgtable_types.h>
 #include <asm/bootparam.h>
 
 struct mpc_bus;

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
