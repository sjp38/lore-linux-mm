Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBCFD83296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:11:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m54so13288965qtb.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:11:52 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0085.outbound.protection.outlook.com. [104.47.33.85])
        by mx.google.com with ESMTPS id l67si2861798qte.88.2017.06.27.08.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:11:52 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 23/38] x86/realmode: Decrypt trampoline area if
 memory encryption is active
Date: Tue, 27 Jun 2017 10:11:38 -0500
Message-ID: <20170627151138.17428.15995.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

When Secure Memory Encryption is enabled, the trampoline area must not
be encrypted. A CPU running in real mode will not be able to decrypt
memory that has been encrypted because it will not be able to use addresses
with the memory encryption mask.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/realmode/init.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index cd4be19..d6ddc7e 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -1,6 +1,7 @@
 #include <linux/io.h>
 #include <linux/slab.h>
 #include <linux/memblock.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/set_memory.h>
 #include <asm/pgtable.h>
@@ -59,6 +60,13 @@ static void __init setup_real_mode(void)
 
 	base = (unsigned char *)real_mode_header;
 
+	/*
+	 * If SME is active, the trampoline area will need to be in
+	 * decrypted memory in order to bring up other processors
+	 * successfully.
+	 */
+	set_memory_decrypted((unsigned long)base, size >> PAGE_SHIFT);
+
 	memcpy(base, real_mode_blob, size);
 
 	phys_base = __pa(base);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
