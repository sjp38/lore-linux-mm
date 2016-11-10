Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68A606B026B
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:37:22 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id t125so217245258ywc.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:37:22 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0040.outbound.protection.outlook.com. [104.47.37.40])
        by mx.google.com with ESMTPS id l35si930450otb.203.2016.11.09.16.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:37:21 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 12/20] x86: Decrypt trampoline area if memory
 encryption is active
Date: Wed, 9 Nov 2016 18:37:08 -0600
Message-ID: <20161110003708.3280.29934.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

When Secure Memory Encryption is enabled, the trampoline area must not
be encrypted. A CPU running in real mode will not be able to decrypt
memory that has been encrypted because it will not be able to use addresses
with the memory encryption mask.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/realmode/init.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index 5db706f1..44ed32a 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -6,6 +6,7 @@
 #include <asm/pgtable.h>
 #include <asm/realmode.h>
 #include <asm/tlbflush.h>
+#include <asm/mem_encrypt.h>
 
 struct real_mode_header *real_mode_header;
 u32 *trampoline_cr4_features;
@@ -130,6 +131,14 @@ static void __init set_real_mode_permissions(void)
 	unsigned long text_start =
 		(unsigned long) __va(real_mode_header->text_start);
 
+	/*
+	 * If memory encryption is active, the trampoline area will need to
+	 * be in un-encrypted memory in order to bring up other processors
+	 * successfully.
+	 */
+	sme_early_mem_dec(__pa(base), size);
+	sme_set_mem_unenc(base, size);
+
 	set_memory_nx((unsigned long) base, size >> PAGE_SHIFT);
 	set_memory_ro((unsigned long) base, ro_size >> PAGE_SHIFT);
 	set_memory_x((unsigned long) text_start, text_size >> PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
