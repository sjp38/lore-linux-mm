Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2624E6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 13:11:17 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o126so42067056pfb.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 10:11:17 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0071.outbound.protection.outlook.com. [104.47.41.71])
        by mx.google.com with ESMTPS id 92si19766165plc.237.2017.03.06.10.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 10:11:16 -0800 (PST)
Subject: Re: [RFC PATCH v2 01/32] x86: Add the Secure Encrypted
 Virtualization CPU feature
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 6 Mar 2017 13:11:03 -0500
Message-ID: <148882363019.12034.4647462304803229954.stgit@brijesh-build-machine>
In-Reply-To: <20170304101113.k6ontjjbljanm6tv@pd.tnic>
References: <20170304101113.k6ontjjbljanm6tv@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@suse.de
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On 03/04/2017 04:11 AM, Borislav Petkov wrote:
> On Fri, Mar 03, 2017 at 03:01:23PM -0600, Brijesh Singh wrote:
> 
> This looks like a wraparound...
> 
> $ test-apply.sh /tmp/brijesh.singh.delta
> checking file Documentation/admin-guide/kernel-parameters.txt
> Hunk #1 succeeded at 2144 (offset -9 lines).
> checking file Documentation/x86/amd-memory-encryption.txt
> patch: **** malformed patch at line 23: DRAM from physical
> 
> Yap.
> 
> Looks like exchange or your mail client decided to do some patch editing
> on its own.
> 
> Please send it to yourself first and try applying.
> 

Sending it through stg mail to avoid line wrapping. Please let me know if something
is still messed up. I have tried applying it and it seems to apply okay.

---
 Documentation/admin-guide/kernel-parameters.txt |    4 +--
 Documentation/x86/amd-memory-encryption.txt     |   33 +++++++++++++----------
 arch/x86/include/asm/cpufeature.h               |    7 +----
 arch/x86/include/asm/cpufeatures.h              |    6 +---
 arch/x86/include/asm/disabled-features.h        |    3 +-
 arch/x86/include/asm/required-features.h        |    3 +-
 arch/x86/kernel/cpu/amd.c                       |   23 ++++++++++++++++
 arch/x86/kernel/cpu/common.c                    |   23 ----------------
 arch/x86/kernel/cpu/scattered.c                 |    1 +
 9 files changed, 50 insertions(+), 53 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 91c40fa..b91e2495 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2153,8 +2153,8 @@
 			mem_encrypt=on:		Activate SME
 			mem_encrypt=off:	Do not activate SME
 
-			Refer to the SME documentation for details on when
-			memory encryption can be activated.
+			Refer to Documentation/x86/amd-memory-encryption.txt
+			for details on when memory encryption can be activated.
 
 	mem_sleep_default=	[SUSPEND] Default system suspend mode:
 			s2idle  - Suspend-To-Idle
diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
index 0938e89..0b72ff2 100644
--- a/Documentation/x86/amd-memory-encryption.txt
+++ b/Documentation/x86/amd-memory-encryption.txt
@@ -7,9 +7,9 @@ DRAM.  SME can therefore be used to protect the contents of DRAM from physical
 attacks on the system.
 
 A page is encrypted when a page table entry has the encryption bit set (see
-below how to determine the position of the bit).  The encryption bit can be
-specified in the cr3 register, allowing the PGD table to be encrypted. Each
-successive level of page tables can also be encrypted.
+below on how to determine its position).  The encryption bit can be specified
+in the cr3 register, allowing the PGD table to be encrypted. Each successive
+level of page tables can also be encrypted.
 
 Support for SME can be determined through the CPUID instruction. The CPUID
 function 0x8000001f reports information related to SME:
@@ -17,13 +17,14 @@ function 0x8000001f reports information related to SME:
 	0x8000001f[eax]:
 		Bit[0] indicates support for SME
 	0x8000001f[ebx]:
-		Bit[5:0]  pagetable bit number used to activate memory
-			  encryption
-		Bit[11:6] reduction in physical address space, in bits, when
-			  memory encryption is enabled (this only affects system
-			  physical addresses, not guest physical addresses)
-
-If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
+		Bits[5:0]  pagetable bit number used to activate memory
+			   encryption
+		Bits[11:6] reduction in physical address space, in bits, when
+			   memory encryption is enabled (this only affects
+			   system physical addresses, not guest physical
+			   addresses)
+
+If support for SME is present, MSR 0xc00100010 (MSR_K8_SYSCFG) can be used to
 determine if SME is enabled and/or to enable memory encryption:
 
 	0xc0010010:
@@ -41,7 +42,7 @@ The state of SME in the Linux kernel can be documented as follows:
 	  The CPU supports SME (determined through CPUID instruction).
 
 	- Enabled:
-	  Supported and bit 23 of the SYS_CFG MSR is set.
+	  Supported and bit 23 of MSR_K8_SYSCFG is set.
 
 	- Active:
 	  Supported, Enabled and the Linux kernel is actively applying
@@ -51,7 +52,9 @@ The state of SME in the Linux kernel can be documented as follows:
 SME can also be enabled and activated in the BIOS. If SME is enabled and
 activated in the BIOS, then all memory accesses will be encrypted and it will
 not be necessary to activate the Linux memory encryption support.  If the BIOS
-merely enables SME (sets bit 23 of the SYS_CFG MSR), then Linux can activate
-memory encryption.  However, if BIOS does not enable SME, then Linux will not
-attempt to activate memory encryption, even if configured to do so by default
-or the mem_encrypt=on command line parameter is specified.
+merely enables SME (sets bit 23 of the MSR_K8_SYSCFG), then Linux can activate
+memory encryption by default (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y) or
+by supplying mem_encrypt=on on the kernel command line.  However, if BIOS does
+not enable SME, then Linux will not be able to activate memory encryption, even
+if configured to do so by default or the mem_encrypt=on command line parameter
+is specified.
diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index ea2de6a..d59c15c 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -28,7 +28,6 @@ enum cpuid_leafs
 	CPUID_8000_000A_EDX,
 	CPUID_7_ECX,
 	CPUID_8000_0007_EBX,
-	CPUID_8000_001F_EAX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
@@ -79,9 +78,8 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 15, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 16, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 17, feature_bit) ||	\
-	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 18, feature_bit) ||	\
 	   REQUIRED_MASK_CHECK					  ||	\
-	   BUILD_BUG_ON_ZERO(NCAPINTS != 19))
+	   BUILD_BUG_ON_ZERO(NCAPINTS != 18))
 
 #define DISABLED_MASK_BIT_SET(feature_bit)				\
 	 ( CHECK_BIT_IN_MASK_WORD(DISABLED_MASK,  0, feature_bit) ||	\
@@ -102,9 +100,8 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 15, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 16, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 17, feature_bit) ||	\
-	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 18, feature_bit) ||	\
 	   DISABLED_MASK_CHECK					  ||	\
-	   BUILD_BUG_ON_ZERO(NCAPINTS != 19))
+	   BUILD_BUG_ON_ZERO(NCAPINTS != 18))
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 331fb81..b1a4468 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -12,7 +12,7 @@
 /*
  * Defines x86 CPU feature bits
  */
-#define NCAPINTS	19	/* N 32-bit words worth of info */
+#define NCAPINTS	18	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -187,6 +187,7 @@
  * Reuse free bits when adding new feature flags!
  */
 
+#define X86_FEATURE_SME		( 7*32+ 0) /* AMD Secure Memory Encryption */
 #define X86_FEATURE_CPB		( 7*32+ 2) /* AMD Core Performance Boost */
 #define X86_FEATURE_EPB		( 7*32+ 3) /* IA32_ENERGY_PERF_BIAS support */
 #define X86_FEATURE_CAT_L3	( 7*32+ 4) /* Cache Allocation Technology L3 */
@@ -296,9 +297,6 @@
 #define X86_FEATURE_SUCCOR	(17*32+1) /* Uncorrectable error containment and recovery */
 #define X86_FEATURE_SMCA	(17*32+3) /* Scalable MCA */
 
-/* AMD-defined CPU features, CPUID level 0x8000001f (eax), word 18 */
-#define X86_FEATURE_SME		(18*32+0) /* Secure Memory Encryption */
-
 /*
  * BUG word(s)
  */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 8b45e08..85599ad 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -57,7 +57,6 @@
 #define DISABLED_MASK15	0
 #define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE)
 #define DISABLED_MASK17	0
-#define DISABLED_MASK18	0
-#define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
+#define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff --git a/arch/x86/include/asm/required-features.h b/arch/x86/include/asm/required-features.h
index 6847d85..fac9a5c 100644
--- a/arch/x86/include/asm/required-features.h
+++ b/arch/x86/include/asm/required-features.h
@@ -100,7 +100,6 @@
 #define REQUIRED_MASK15	0
 #define REQUIRED_MASK16	0
 #define REQUIRED_MASK17	0
-#define REQUIRED_MASK18	0
-#define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
+#define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index 35a5d5d..6bddda3 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -615,6 +615,29 @@ static void early_init_amd(struct cpuinfo_x86 *c)
 	 */
 	if (cpu_has_amd_erratum(c, amd_erratum_400))
 		set_cpu_bug(c, X86_BUG_AMD_E400);
+
+	/*
+	 * BIOS support is required for SME. If BIOS has enabld SME then
+	 * adjust x86_phys_bits by the SME physical address space reduction
+	 * value. If BIOS has not enabled SME then don't advertise the
+	 * feature (set in scattered.c).
+	 */
+	if (c->extended_cpuid_level >= 0x8000001f) {
+		if (cpu_has(c, X86_FEATURE_SME)) {
+			u64 msr;
+
+			/* Check if SME is enabled */
+			rdmsrl(MSR_K8_SYSCFG, msr);
+			if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT) {
+				unsigned int ebx;
+
+				ebx = cpuid_ebx(0x8000001f);
+				c->x86_phys_bits -= (ebx >> 6) & 0x3f;
+			} else {
+				clear_cpu_cap(c, X86_FEATURE_SME);
+			}
+		}
+	}
 }
 
 static void init_amd_k8(struct cpuinfo_x86 *c)
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 358208d7..c188ae5 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -763,29 +763,6 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 	if (c->extended_cpuid_level >= 0x8000000a)
 		c->x86_capability[CPUID_8000_000A_EDX] = cpuid_edx(0x8000000a);
 
-	if (c->extended_cpuid_level >= 0x8000001f) {
-		cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);
-
-		/* SME feature support */
-		if ((c->x86_vendor == X86_VENDOR_AMD) && (eax & 0x01)) {
-			u64 msr;
-
-			/*
-			 * For SME, BIOS support is required. If BIOS has
-			 * enabled SME adjust x86_phys_bits by the SME
-			 * physical address space reduction value. If BIOS
-			 * has not enabled SME don't advertise the feature.
-			 */
-			rdmsrl(MSR_K8_SYSCFG, msr);
-			if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT)
-				c->x86_phys_bits -= (ebx >> 6) & 0x3f;
-			else
-				eax &= ~0x01;
-		}
-
-		c->x86_capability[CPUID_8000_001F_EAX] = eax;
-	}
-
 	init_scattered_cpuid_features(c);
 
 	/*
diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
index d979406..cabda87 100644
--- a/arch/x86/kernel/cpu/scattered.c
+++ b/arch/x86/kernel/cpu/scattered.c
@@ -30,6 +30,7 @@ static const struct cpuid_bit cpuid_bits[] = {
 	{ X86_FEATURE_HW_PSTATE,	CPUID_EDX,  7, 0x80000007, 0 },
 	{ X86_FEATURE_CPB,		CPUID_EDX,  9, 0x80000007, 0 },
 	{ X86_FEATURE_PROC_FEEDBACK,    CPUID_EDX, 11, 0x80000007, 0 },
+	{ X86_FEATURE_SME,		CPUID_EAX,  0, 0x8000001f, 0 },
 	{ 0, 0, 0, 0, 0 }
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
