Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11E7B6B026F
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:58:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a66so60053587qkg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:58:09 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0067.outbound.protection.outlook.com. [65.55.169.67])
        by mx.google.com with ESMTPS id h81si727522qhc.41.2016.04.26.15.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:58:08 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 12/18] x86: Access device tree in the clear
Date: Tue, 26 Apr 2016 17:58:00 -0500
Message-ID: <20160426225800.13567.99120.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

The device tree is not encrypted and needs to be accessed as such. Be sure
to memmap it without the encryption mask set.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/devicetree.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/devicetree.c b/arch/x86/kernel/devicetree.c
index 3fe45f8..ff11f7a 100644
--- a/arch/x86/kernel/devicetree.c
+++ b/arch/x86/kernel/devicetree.c
@@ -22,6 +22,7 @@
 #include <asm/pci_x86.h>
 #include <asm/setup.h>
 #include <asm/i8259.h>
+#include <asm/mem_encrypt.h>
 
 __initdata u64 initial_dtb;
 char __initdata cmd_line[COMMAND_LINE_SIZE];
@@ -276,11 +277,12 @@ static void __init x86_flattree_get_config(void)
 
 	map_len = max(PAGE_SIZE - (initial_dtb & ~PAGE_MASK), (u64)128);
 
-	initial_boot_params = dt = early_memremap(initial_dtb, map_len);
+	initial_boot_params = dt = sme_early_memremap(initial_dtb, map_len);
 	size = of_get_flat_dt_size();
 	if (map_len < size) {
 		early_memunmap(dt, map_len);
-		initial_boot_params = dt = early_memremap(initial_dtb, size);
+		initial_boot_params = dt = sme_early_memremap(initial_dtb,
+							      size);
 		map_len = size;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
