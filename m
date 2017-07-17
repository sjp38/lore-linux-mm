Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2536B02C3
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:10:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o3so594069qto.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:10:54 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0069.outbound.protection.outlook.com. [104.47.33.69])
        by mx.google.com with ESMTPS id i68si265625qke.182.2017.07.17.14.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:10:53 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 01/38] x86: Document AMD Secure Memory Encryption (SME)
Date: Mon, 17 Jul 2017 16:09:58 -0500
Message-Id: <ca0a0c13b055fd804cfc92cbaca8acd68057eed0.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Create a Documentation entry to describe the AMD Secure Memory
Encryption (SME) feature and add documentation for the mem_encrypt=
kernel parameter.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 11 ++++
 Documentation/x86/amd-memory-encryption.txt     | 68 +++++++++++++++++++++++++
 2 files changed, 79 insertions(+)
 create mode 100644 Documentation/x86/amd-memory-encryption.txt

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index f701430..372cc66 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2233,6 +2233,17 @@
 			memory contents and reserves bad memory
 			regions that are detected.
 
+	mem_encrypt=	[X86-64] AMD Secure Memory Encryption (SME) control
+			Valid arguments: on, off
+			Default (depends on kernel configuration option):
+			  on  (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y)
+			  off (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=n)
+			mem_encrypt=on:		Activate SME
+			mem_encrypt=off:	Do not activate SME
+
+			Refer to Documentation/x86/amd-memory-encryption.txt
+			for details on when memory encryption can be activated.
+
 	mem_sleep_default=	[SUSPEND] Default system suspend mode:
 			s2idle  - Suspend-To-Idle
 			shallow - Power-On Suspend or equivalent (if supported)
diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
new file mode 100644
index 0000000..f512ab7
--- /dev/null
+++ b/Documentation/x86/amd-memory-encryption.txt
@@ -0,0 +1,68 @@
+Secure Memory Encryption (SME) is a feature found on AMD processors.
+
+SME provides the ability to mark individual pages of memory as encrypted using
+the standard x86 page tables.  A page that is marked encrypted will be
+automatically decrypted when read from DRAM and encrypted when written to
+DRAM.  SME can therefore be used to protect the contents of DRAM from physical
+attacks on the system.
+
+A page is encrypted when a page table entry has the encryption bit set (see
+below on how to determine its position).  The encryption bit can also be
+specified in the cr3 register, allowing the PGD table to be encrypted. Each
+successive level of page tables can also be encrypted by setting the encryption
+bit in the page table entry that points to the next table. This allows the full
+page table hierarchy to be encrypted. Note, this means that just because the
+encryption bit is set in cr3, doesn't imply the full hierarchy is encyrpted.
+Each page table entry in the hierarchy needs to have the encryption bit set to
+achieve that. So, theoretically, you could have the encryption bit set in cr3
+so that the PGD is encrypted, but not set the encryption bit in the PGD entry
+for a PUD which results in the PUD pointed to by that entry to not be
+encrypted.
+
+Support for SME can be determined through the CPUID instruction. The CPUID
+function 0x8000001f reports information related to SME:
+
+	0x8000001f[eax]:
+		Bit[0] indicates support for SME
+	0x8000001f[ebx]:
+		Bits[5:0]  pagetable bit number used to activate memory
+			   encryption
+		Bits[11:6] reduction in physical address space, in bits, when
+			   memory encryption is enabled (this only affects
+			   system physical addresses, not guest physical
+			   addresses)
+
+If support for SME is present, MSR 0xc00100010 (MSR_K8_SYSCFG) can be used to
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
+The state of SME in the Linux kernel can be documented as follows:
+	- Supported:
+	  The CPU supports SME (determined through CPUID instruction).
+
+	- Enabled:
+	  Supported and bit 23 of MSR_K8_SYSCFG is set.
+
+	- Active:
+	  Supported, Enabled and the Linux kernel is actively applying
+	  the encryption bit to page table entries (the SME mask in the
+	  kernel is non-zero).
+
+SME can also be enabled and activated in the BIOS. If SME is enabled and
+activated in the BIOS, then all memory accesses will be encrypted and it will
+not be necessary to activate the Linux memory encryption support.  If the BIOS
+merely enables SME (sets bit 23 of the MSR_K8_SYSCFG), then Linux can activate
+memory encryption by default (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y) or
+by supplying mem_encrypt=on on the kernel command line.  However, if BIOS does
+not enable SME, then Linux will not be able to activate memory encryption, even
+if configured to do so by default or the mem_encrypt=on command line parameter
+is specified.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
