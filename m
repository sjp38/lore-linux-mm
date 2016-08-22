Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAA36B0253
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:35:47 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n6so207596681qtn.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:35:47 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0088.outbound.protection.outlook.com. [104.47.33.88])
        by mx.google.com with ESMTPS id h37si244297qte.29.2016.08.22.15.35.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:35:47 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 01/20] x86: Documentation for AMD Secure Memory
 Encryption (SME)
Date: Mon, 22 Aug 2016 17:35:39 -0500
Message-ID: <20160822223539.29880.96739.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch adds a Documenation entry to decribe the AMD Secure Memory
Encryption (SME) feature.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 Documentation/x86/amd-memory-encryption.txt |   35 +++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)
 create mode 100644 Documentation/x86/amd-memory-encryption.txt

diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
new file mode 100644
index 0000000..f19c555
--- /dev/null
+++ b/Documentation/x86/amd-memory-encryption.txt
@@ -0,0 +1,35 @@
+Secure Memory Encryption (SME) is a feature found on AMD processors.
+
+SME provides the ability to mark individual pages of memory as encrypted using
+the standard x86 page tables.  A page that is marked encrpyted will be
+automatically decrypted when read from DRAM and encrypted when written to
+DRAM.  SME can therefore be used to protect the contents of DRAM from physical
+attacks on the system.
+
+Support for SME can be determined through the CPUID instruction. The CPUID
+function 0x8000001f reports information related to SME:
+
+	0x8000001f[eax]:
+		Bit[0] indicates support for SME
+	0x8000001f[ebx]:
+		Bit[5:0]  pagetable bit number used to enable memory encryption
+		Bit[11:6] reduction in physical address space, in bits, when
+			  memory encryption is enabled (this only affects system
+			  physical addresses, not guest physical addresses)
+
+If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
+determine if SME is enabled and/or to enable memory encryption:
+
+	0xc0010010:
+		Bit[23]   0 = memory encryption features are disabled
+			  1 = memory encryption features are enabled
+
+Linux relies on BIOS to set this bit if BIOS has determined that the reduction
+in the physical address space as a result of enabling memory encryption (see
+CPUID information above) will not conflict with the address space resource
+requirements for the system.  If this bit is not set upon Linux startup then
+Linux itself will not set it and memory encryption will not be possible.
+
+SME support is configurable in the kernel through the AMD_MEM_ENCRYPT config
+option. Additionally, the mem_encrypt=on command line parameter is required
+to activate memory encryption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
