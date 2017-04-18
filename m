Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 322072806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:20:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q66so2656713pfi.16
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:20:10 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0073.outbound.protection.outlook.com. [104.47.38.73])
        by mx.google.com with ESMTPS id s1si24972plk.256.2017.04.18.14.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:20:09 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 21/32] x86,
 realmode: Decrypt trampoline area if memory encryption is active
Date: Tue, 18 Apr 2017 16:19:59 -0500
Message-ID: <20170418211959.10190.3481.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

When Secure Memory Encryption is enabled, the trampoline area must not
be encrypted. A CPU running in real mode will not be able to decrypt
memory that has been encrypted because it will not be able to use addresses
with the memory encryption mask.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/realmode/init.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index 5db706f1..21d7506 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -6,6 +6,8 @@
 #include <asm/pgtable.h>
 #include <asm/realmode.h>
 #include <asm/tlbflush.h>
+#include <asm/mem_encrypt.h>
+#include <asm/cacheflush.h>
 
 struct real_mode_header *real_mode_header;
 u32 *trampoline_cr4_features;
@@ -130,6 +132,16 @@ static void __init set_real_mode_permissions(void)
 	unsigned long text_start =
 		(unsigned long) __va(real_mode_header->text_start);
 
+	/*
+	 * If SME is active, the trampoline area will need to be in
+	 * decrypted memory in order to bring up other processors
+	 * successfully.
+	 */
+	if (sme_active()) {
+		sme_early_decrypt(__pa(base), size);
+		set_memory_decrypted((unsigned long)base, size >> PAGE_SHIFT);
+	}
+
 	set_memory_nx((unsigned long) base, size >> PAGE_SHIFT);
 	set_memory_ro((unsigned long) base, ro_size >> PAGE_SHIFT);
 	set_memory_x((unsigned long) text_start, text_size >> PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
