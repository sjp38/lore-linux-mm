Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBC46B038D
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 16:01:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 77so169310pgc.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 13:01:33 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0083.outbound.protection.outlook.com. [104.47.36.83])
        by mx.google.com with ESMTPS id l33si11589634pld.320.2017.03.03.13.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 13:01:31 -0800 (PST)
Subject: Re: [RFC PATCH v2 01/32] x86: Add the Secure Encrypted Virtualization
 CPU feature
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846752953.2349.17505492128445909591.stgit@brijesh-build-machine>
 <20170303165915.3233fx7wo74vsslx@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <404fafd8-bbd6-b8c7-1abb-787ac083ea41@amd.com>
Date: Fri, 3 Mar 2017 15:01:23 -0600
MIME-Version: 1.0
In-Reply-To: <20170303165915.3233fx7wo74vsslx@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

Hi Boris,

On 03/03/2017 10:59 AM, Borislav Petkov wrote:
> On Thu, Mar 02, 2017 at 10:12:09AM -0500, Brijesh Singh wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>>
>> Update the CPU features to include identifying and reporting on the
>> Secure Encrypted Virtualization (SEV) feature.  SME is identified by
>> CPUID 0x8000001f, but requires BIOS support to enable it (set bit 23 of
>> MSR_K8_SYSCFG and set bit 0 of MSR_K7_HWCR).  Only show the SEV feature
>> as available if reported by CPUID and enabled by BIOS.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/cpufeatures.h |    1 +
>>  arch/x86/include/asm/msr-index.h   |    2 ++
>>  arch/x86/kernel/cpu/amd.c          |   22 ++++++++++++++++++----
>>  arch/x86/kernel/cpu/scattered.c    |    1 +
>>  4 files changed, 22 insertions(+), 4 deletions(-)
>
> So this patchset is not really ontop of Tom's patchset because this
> patch doesn't apply. The reason is, Tom did the SME bit this way:
>
> https://lkml.kernel.org/r/20170216154236.19244.7580.stgit@tlendack-t1.amdoffice.net
>
> but it should've been in scattered.c.
>
>> diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
>> index cabda87..c3f58d9 100644
>> --- a/arch/x86/kernel/cpu/scattered.c
>> +++ b/arch/x86/kernel/cpu/scattered.c
>> @@ -31,6 +31,7 @@ static const struct cpuid_bit cpuid_bits[] = {
>>  	{ X86_FEATURE_CPB,		CPUID_EDX,  9, 0x80000007, 0 },
>>  	{ X86_FEATURE_PROC_FEEDBACK,    CPUID_EDX, 11, 0x80000007, 0 },
>>  	{ X86_FEATURE_SME,		CPUID_EAX,  0, 0x8000001f, 0 },
>> +	{ X86_FEATURE_SEV,		CPUID_EAX,  1, 0x8000001f, 0 },
>>  	{ 0, 0, 0, 0, 0 }
>
> ... and here it is in scattered.c, as it should be. So you've used an
> older version of the patch, it seems.
>
> Please sync with Tom to see whether he's reworked the v4 version of that
> patch already. If yes, then you could send only the SME and SEV adding
> patches as a reply to this message so that I can continue reviewing in
> the meantime.
>

Just realized my error, I actually end up using Tom's recent updates to 
v4 instead of original v4. Here is the diff. If you have Tom's v4 
applied then apply this diff before applying SEV v2 version. Sorry about 
that.

Optionally, you also pull the complete tree from github [1].

[1] https://github.com/codomania/tip/tree/sev-rfc-v2


diff --git a/Documentation/admin-guide/kernel-parameters.txt 
b/Documentation/admin-guide/kernel-parameters.txt
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
diff --git a/Documentation/x86/amd-memory-encryption.txt 
b/Documentation/x86/amd-memory-encryption.txt
index 0938e89..0b72ff2 100644
--- a/Documentation/x86/amd-memory-encryption.txt
+++ b/Documentation/x86/amd-memory-encryption.txt
@@ -7,9 +7,9 @@ DRAM.  SME can therefore be used to protect the contents 
of DRAM from physical
  attacks on the system.

  A page is encrypted when a page table entry has the encryption bit set 
(see
-below how to determine the position of the bit).  The encryption bit can be
-specified in the cr3 register, allowing the PGD table to be encrypted. Each
-successive level of page tables can also be encrypted.
+below on how to determine its position).  The encryption bit can be 
specified
+in the cr3 register, allowing the PGD table to be encrypted. Each 
successive
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
+If support for SME is present, MSR 0xc00100010 (MSR_K8_SYSCFG) can be 
used to
  determine if SME is enabled and/or to enable memory encryption:

  	0xc0010010:
@@ -41,7 +42,7 @@ The state of SME in the Linux kernel can be documented 
as follows:
  	  The CPU supports SME (determined through CPUID instruction).

  	- Enabled:
-	  Supported and bit 23 of the SYS_CFG MSR is set.
+	  Supported and bit 23 of MSR_K8_SYSCFG is set.

  	- Active:
  	  Supported, Enabled and the Linux kernel is actively applying
@@ -51,7 +52,9 @@ The state of SME in the Linux kernel can be documented 
as follows:
  SME can also be enabled and activated in the BIOS. If SME is enabled and
  activated in the BIOS, then all memory accesses will be encrypted and 
it will
  not be necessary to activate the Linux memory encryption support.  If 
the BIOS
-merely enables SME (sets bit 23 of the SYS_CFG MSR), then Linux can 
activate
-memory encryption.  However, if BIOS does not enable SME, then Linux 
will not
-attempt to activate memory encryption, even if configured to do so by 
default
-or the mem_encrypt=on command line parameter is specified.
+merely enables SME (sets bit 23 of the MSR_K8_SYSCFG), then Linux can 
activate
+memory encryption by default 
(CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y) or
+by supplying mem_encrypt=on on the kernel command line.  However, if 
BIOS does
+not enable SME, then Linux will not be able to activate memory 
encryption, even
+if configured to do so by default or the mem_encrypt=on command line 
parameter
+is specified.
diff --git a/arch/x86/include/asm/cpufeature.h 
b/arch/x86/include/asm/cpufeature.h
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
diff --git a/arch/x86/include/asm/cpufeatures.h 
b/arch/x86/include/asm/cpufeatures.h
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
  #define X86_FEATURE_SUCCOR	(17*32+1) /* Uncorrectable error 
containment and recovery */
  #define X86_FEATURE_SMCA	(17*32+3) /* Scalable MCA */

-/* AMD-defined CPU features, CPUID level 0x8000001f (eax), word 18 */
-#define X86_FEATURE_SME		(18*32+0) /* Secure Memory Encryption */
-
  /*
   * BUG word(s)
   */
diff --git a/arch/x86/include/asm/disabled-features.h 
b/arch/x86/include/asm/disabled-features.h
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
diff --git a/arch/x86/include/asm/required-features.h 
b/arch/x86/include/asm/required-features.h
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
diff --git a/arch/x86/kernel/cpu/scattered.c 
b/arch/x86/kernel/cpu/scattered.c
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
