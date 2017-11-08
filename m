Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD0A44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 15:18:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v105so1952404wrc.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 12:18:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o93si1494858edd.219.2017.11.08.12.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 12:18:21 -0800 (PST)
Date: Wed, 8 Nov 2017 21:18:18 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL
 availability
Message-ID: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

From: Jiri Kosina <jkosina@suse.cz>

Commit

  7744ccdbc16f0 ("x86/mm: Add Secure Memory Encryption (SME) support")

as a side-effect made PAGE_KERNEL all of a sudden unavailable to modules 
which can't make use of EXPORT_SYMBOL_GPL() symbols.

This is because once SME is enabled, sme_me_mask (which is introduced as 
EXPORT_SYMBOL_GPL) makes its way to PAGE_KERNEL through _PAGE_ENC, causing 
imminent build failure for all the modules which make use of all the 
EXPORT-SYMBOL()-exported API (such as vmap(), __vmalloc(), 
remap_pfn_range(), ...).

Exporting (as EXPORT_SYMBOL()) interfaces (and having done so for ages) 
that take pgprot_t argument, while making it impossible to -- all of a 
sudden -- pass PAGE_KERNEL to it, feels rather incosistent.

Restore the original behavior and make it possible to pass PAGE_KERNEL to 
all its EXPORT_SYMBOL() consumers.

Cc: Tom Lendacky <thomas.lendacky@amd.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 arch/x86/mm/mem_encrypt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 16c5f37933a2..0286327e65fa 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -40,7 +40,7 @@ static char sme_cmdline_off[] __initdata = "off";
  * section is later cleared.
  */
 u64 sme_me_mask __section(.data) = 0;
-EXPORT_SYMBOL_GPL(sme_me_mask);
+EXPORT_SYMBOL(sme_me_mask);
 
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
