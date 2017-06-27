Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0511F6B0314
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:58:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o62so29460380pga.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:58:19 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0080.outbound.protection.outlook.com. [104.47.41.80])
        by mx.google.com with ESMTPS id q67si1988838pfi.204.2017.06.27.07.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:58:19 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 11/38] x86/mm: Add SME support for read_cr3_pa()
Date: Tue, 27 Jun 2017 09:58:12 -0500
Message-ID: <20170627145812.15908.39913.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

The cr3 register entry can contain the SME encryption mask that indicates
the PGD is encrypted.  The encryption mask should not be used when
creating a virtual address from the cr3 register, so remove the SME
encryption mask in the read_cr3_pa() function.

During early boot SME will need to use a native version of read_cr3_pa(),
so create native_read_cr3_pa().

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/processor-flags.h |    5 +++--
 arch/x86/include/asm/processor.h       |    5 +++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 79aa2f9..f5d3e50 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_PROCESSOR_FLAGS_H
 
 #include <uapi/asm/processor-flags.h>
+#include <linux/mem_encrypt.h>
 
 #ifdef CONFIG_VM86
 #define X86_VM_MASK	X86_EFLAGS_VM
@@ -32,8 +33,8 @@
  * CR3_ADDR_MASK is the mask used by read_cr3_pa().
  */
 #ifdef CONFIG_X86_64
-/* Mask off the address space ID bits. */
-#define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
+/* Mask off the address space ID and SME encryption bits. */
+#define CR3_ADDR_MASK __sme_clr(0x7FFFFFFFFFFFF000ull)
 #define CR3_PCID_MASK 0xFFFull
 #else
 /*
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 8010c97..ab878bd 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -240,6 +240,11 @@ static inline unsigned long read_cr3_pa(void)
 	return __read_cr3() & CR3_ADDR_MASK;
 }
 
+static inline unsigned long native_read_cr3_pa(void)
+{
+	return __native_read_cr3() & CR3_ADDR_MASK;
+}
+
 static inline void load_cr3(pgd_t *pgdir)
 {
 	write_cr3(__sme_pa(pgdir));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
