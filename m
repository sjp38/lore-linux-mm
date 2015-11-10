Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C9C066B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 09:47:02 -0500 (EST)
Received: by wmww144 with SMTP id w144so120832885wmw.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 06:47:02 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 123si24176887wmx.111.2015.11.10.06.47.01
        for <linux-mm@kvack.org>;
        Tue, 10 Nov 2015 06:47:01 -0800 (PST)
Date: Tue, 10 Nov 2015 15:46:48 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151110144648.GG19187@pd.tnic>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20151110135303.GA11246@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>

On Tue, Nov 10, 2015 at 03:53:03PM +0200, Kirill A. Shutemov wrote:
> Oh.. pmdval_t/pudval_t is 'unsinged long' on 64 bit. But realmode code
> uses -m16 which makes 'unsigned long' 32-bit therefore truncation warning.
> 
> These helpers not really used in realmode code.

Hrrm, yeah, that's just the nasty include hell causing it. The diff
below fixes it with my config but it'll probably need a more careful
analysis and reshuffling of includes/defines.

Certainly better to do that than accomodating realmode to not throw
warnings with ifdeffery...

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
index aa8a96b052e3..896077ed3381 100644
--- a/arch/x86/boot/video-mode.c
+++ b/arch/x86/boot/video-mode.c
@@ -19,6 +19,9 @@
 #include "video.h"
 #include "vesa.h"
 
+#define NORMAL_VGA	0xffff		/* 80x25 mode */
+#define EXTENDED_VGA	0xfffe		/* 80x50 mode */
+
 /*
  * Common variables
  */
diff --git a/arch/x86/boot/video.c b/arch/x86/boot/video.c
index 05111bb8d018..a839448038b6 100644
--- a/arch/x86/boot/video.c
+++ b/arch/x86/boot/video.c
@@ -17,6 +17,8 @@
 #include "video.h"
 #include "vesa.h"
 
+#define ASK_VGA		0xfffd		/* ask for it at bootup */
+
 static u16 video_segment;
 
 static void store_cursor_position(void)
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
