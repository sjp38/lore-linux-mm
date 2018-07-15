Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44E426B0005
	for <linux-mm@kvack.org>; Sun, 15 Jul 2018 07:05:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25-v6so23690257pfi.20
        for <linux-mm@kvack.org>; Sun, 15 Jul 2018 04:05:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h16-v6si28811536pli.14.2018.07.15.04.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jul 2018 04:05:04 -0700 (PDT)
Subject: Patch "[PATCH 4.4.y 015/101] x86/cpufeature, x86/mm/pkeys: Add protection keys related CPUID definitions" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 15 Jul 2018 13:04:21 +0200
In-Reply-To: <153156048404.10043.9924019452796692128.stgit@srivatsa-ubuntu>
Message-ID: <1531652661230246@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20160212210201.7714C250@viggo.jf.intel.com, akpm@linux-foundation.org, amakhalov@vmware.com, bp@alien8.de, brgerst@gmail.com, dave.hansen@linux.intel.com, dave@sr71.net, dvlasenk@redhat.com, ganb@vmware.com, gregkh@linuxfoundation.org, hpa@zytor.com, linux-mm@kvack.org, luto@amacapital.net, matt.helsley@gmail.com, mingo@kernel.org, peterz@infradead.org, riel@redhat.com, rostedt@goodmis.org, srivatsa@csail.mit.edu, srivatsab@vmware.com, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    [PATCH 4.4.y 015/101] x86/cpufeature, x86/mm/pkeys: Add protection keys related CPUID definitions

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-cpufeature-x86-mm-pkeys-add-protection-keys-related-cpuid-definitions.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jul 15 12:18:31 CEST 2018
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Date: Sat, 14 Jul 2018 02:28:04 -0700
Subject: [PATCH 4.4.y 015/101] x86/cpufeature, x86/mm/pkeys: Add protection keys related CPUID definitions
To: gregkh@linuxfoundation.org, stable@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave@sr71.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, "Matt Helsley \(VMware\)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>, matt.helsley@gmail.com, rostedt@goodmis.org, amakhalov@vmware.com, ganb@vmware.com, srivatsa@csail.mit.edu, srivatsab@vmware.com
Message-ID: <153156048404.10043.9924019452796692128.stgit@srivatsa-ubuntu>

From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>

From: Dave Hansen <dave.hansen@linux.intel.com>

commit dfb4a70f20c5b3880da56ee4c9484bdb4e8f1e65 upstream

There are two CPUID bits for protection keys.  One is for whether
the CPU contains the feature, and the other will appear set once
the OS enables protection keys.  Specifically:

	Bit 04: OSPKE. If 1, OS has set CR4.PKE to enable
	Protection keys (and the RDPKRU/WRPKRU instructions)

This is because userspace can not see CR4 contents, but it can
see CPUID contents.

X86_FEATURE_PKU is referred to as "PKU" in the hardware documentation:

	CPUID.(EAX=07H,ECX=0H):ECX.PKU [bit 3]

X86_FEATURE_OSPKE is "OSPKU":

	CPUID.(EAX=07H,ECX=0H):ECX.OSPKE [bit 4]

These are the first CPU features which need to look at the
ECX word in CPUID leaf 0x7, so this patch also includes
fetching that word in to the cpuinfo->x86_capability[] array.

Add it to the disabled-features mask when its config option is
off.  Even though we are not using it here, we also extend the
REQUIRED_MASK_BIT_SET() macro to keep it mirroring the
DISABLED_MASK_BIT_SET() version.

This means that in almost all code, you should use:

	cpu_has(c, X86_FEATURE_PKU)

and *not* the CONFIG option.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20160212210201.7714C250@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa@csail.mit.edu>
Reviewed-by: Matt Helsley (VMware) <matt.helsley@gmail.com>
Reviewed-by: Alexey Makhalov <amakhalov@vmware.com>
Reviewed-by: Bo Gan <ganb@vmware.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

 arch/x86/include/asm/cpufeature.h        |   59 ++++++++++++++++++++-----------
 arch/x86/include/asm/cpufeatures.h       |    2 -
 arch/x86/include/asm/disabled-features.h |   15 +++++++
 arch/x86/include/asm/required-features.h |    7 +++
 arch/x86/kernel/cpu/common.c             |    1 
 5 files changed, 63 insertions(+), 21 deletions(-)

--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -26,6 +26,7 @@ enum cpuid_leafs
 	CPUID_8000_0008_EBX,
 	CPUID_6_EAX,
 	CPUID_8000_000A_EDX,
+	CPUID_7_ECX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
@@ -48,28 +49,42 @@ extern const char * const x86_bug_flags[
 	 test_bit(bit, (unsigned long *)((c)->x86_capability))
 
 #define REQUIRED_MASK_BIT_SET(bit)					\
-	 ( (((bit)>>5)==0 && (1UL<<((bit)&31) & REQUIRED_MASK0)) ||	\
-	   (((bit)>>5)==1 && (1UL<<((bit)&31) & REQUIRED_MASK1)) ||	\
-	   (((bit)>>5)==2 && (1UL<<((bit)&31) & REQUIRED_MASK2)) ||	\
-	   (((bit)>>5)==3 && (1UL<<((bit)&31) & REQUIRED_MASK3)) ||	\
-	   (((bit)>>5)==4 && (1UL<<((bit)&31) & REQUIRED_MASK4)) ||	\
-	   (((bit)>>5)==5 && (1UL<<((bit)&31) & REQUIRED_MASK5)) ||	\
-	   (((bit)>>5)==6 && (1UL<<((bit)&31) & REQUIRED_MASK6)) ||	\
-	   (((bit)>>5)==7 && (1UL<<((bit)&31) & REQUIRED_MASK7)) ||	\
-	   (((bit)>>5)==8 && (1UL<<((bit)&31) & REQUIRED_MASK8)) ||	\
-	   (((bit)>>5)==9 && (1UL<<((bit)&31) & REQUIRED_MASK9)) )
+	 ( (((bit)>>5)==0  && (1UL<<((bit)&31) & REQUIRED_MASK0 )) ||	\
+	   (((bit)>>5)==1  && (1UL<<((bit)&31) & REQUIRED_MASK1 )) ||	\
+	   (((bit)>>5)==2  && (1UL<<((bit)&31) & REQUIRED_MASK2 )) ||	\
+	   (((bit)>>5)==3  && (1UL<<((bit)&31) & REQUIRED_MASK3 )) ||	\
+	   (((bit)>>5)==4  && (1UL<<((bit)&31) & REQUIRED_MASK4 )) ||	\
+	   (((bit)>>5)==5  && (1UL<<((bit)&31) & REQUIRED_MASK5 )) ||	\
+	   (((bit)>>5)==6  && (1UL<<((bit)&31) & REQUIRED_MASK6 )) ||	\
+	   (((bit)>>5)==7  && (1UL<<((bit)&31) & REQUIRED_MASK7 )) ||	\
+	   (((bit)>>5)==8  && (1UL<<((bit)&31) & REQUIRED_MASK8 )) ||	\
+	   (((bit)>>5)==9  && (1UL<<((bit)&31) & REQUIRED_MASK9 )) ||	\
+	   (((bit)>>5)==10 && (1UL<<((bit)&31) & REQUIRED_MASK10)) ||	\
+	   (((bit)>>5)==11 && (1UL<<((bit)&31) & REQUIRED_MASK11)) ||	\
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & REQUIRED_MASK12)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK14)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK15)) ||	\
+	   (((bit)>>5)==14 && (1UL<<((bit)&31) & REQUIRED_MASK16)) )
 
 #define DISABLED_MASK_BIT_SET(bit)					\
-	 ( (((bit)>>5)==0 && (1UL<<((bit)&31) & DISABLED_MASK0)) ||	\
-	   (((bit)>>5)==1 && (1UL<<((bit)&31) & DISABLED_MASK1)) ||	\
-	   (((bit)>>5)==2 && (1UL<<((bit)&31) & DISABLED_MASK2)) ||	\
-	   (((bit)>>5)==3 && (1UL<<((bit)&31) & DISABLED_MASK3)) ||	\
-	   (((bit)>>5)==4 && (1UL<<((bit)&31) & DISABLED_MASK4)) ||	\
-	   (((bit)>>5)==5 && (1UL<<((bit)&31) & DISABLED_MASK5)) ||	\
-	   (((bit)>>5)==6 && (1UL<<((bit)&31) & DISABLED_MASK6)) ||	\
-	   (((bit)>>5)==7 && (1UL<<((bit)&31) & DISABLED_MASK7)) ||	\
-	   (((bit)>>5)==8 && (1UL<<((bit)&31) & DISABLED_MASK8)) ||	\
-	   (((bit)>>5)==9 && (1UL<<((bit)&31) & DISABLED_MASK9)) )
+	 ( (((bit)>>5)==0  && (1UL<<((bit)&31) & DISABLED_MASK0 )) ||	\
+	   (((bit)>>5)==1  && (1UL<<((bit)&31) & DISABLED_MASK1 )) ||	\
+	   (((bit)>>5)==2  && (1UL<<((bit)&31) & DISABLED_MASK2 )) ||	\
+	   (((bit)>>5)==3  && (1UL<<((bit)&31) & DISABLED_MASK3 )) ||	\
+	   (((bit)>>5)==4  && (1UL<<((bit)&31) & DISABLED_MASK4 )) ||	\
+	   (((bit)>>5)==5  && (1UL<<((bit)&31) & DISABLED_MASK5 )) ||	\
+	   (((bit)>>5)==6  && (1UL<<((bit)&31) & DISABLED_MASK6 )) ||	\
+	   (((bit)>>5)==7  && (1UL<<((bit)&31) & DISABLED_MASK7 )) ||	\
+	   (((bit)>>5)==8  && (1UL<<((bit)&31) & DISABLED_MASK8 )) ||	\
+	   (((bit)>>5)==9  && (1UL<<((bit)&31) & DISABLED_MASK9 )) ||	\
+	   (((bit)>>5)==10 && (1UL<<((bit)&31) & DISABLED_MASK10)) ||	\
+	   (((bit)>>5)==11 && (1UL<<((bit)&31) & DISABLED_MASK11)) ||	\
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & DISABLED_MASK12)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK14)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK15)) ||	\
+	   (((bit)>>5)==14 && (1UL<<((bit)&31) & DISABLED_MASK16)) )
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
@@ -79,6 +94,10 @@ extern const char * const x86_bug_flags[
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 : 	\
 	 x86_this_cpu_test_bit(bit, (unsigned long *)&cpu_info.x86_capability))
 
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx), word 16 */
+#define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
+
 /*
  * This macro is for detection of features which need kernel
  * infrastructure to be used.  It may *not* directly test the CPU
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -12,7 +12,7 @@
 /*
  * Defines x86 CPU feature bits
  */
-#define NCAPINTS	16	/* N 32-bit words worth of info */
+#define NCAPINTS	17	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -30,6 +30,14 @@
 # define DISABLE_PCID		(1<<(X86_FEATURE_PCID & 31))
 #endif /* CONFIG_X86_64 */
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+# define DISABLE_PKU		(1<<(X86_FEATURE_PKU))
+# define DISABLE_OSPKE		(1<<(X86_FEATURE_OSPKE))
+#else
+# define DISABLE_PKU		0
+# define DISABLE_OSPKE		0
+#endif /* CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS */
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -43,5 +51,12 @@
 #define DISABLED_MASK7	0
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX)
+#define DISABLED_MASK10	0
+#define DISABLED_MASK11	0
+#define DISABLED_MASK12	0
+#define DISABLED_MASK13	0
+#define DISABLED_MASK14	0
+#define DISABLED_MASK15	0
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
--- a/arch/x86/include/asm/required-features.h
+++ b/arch/x86/include/asm/required-features.h
@@ -92,5 +92,12 @@
 #define REQUIRED_MASK7	0
 #define REQUIRED_MASK8	0
 #define REQUIRED_MASK9	0
+#define REQUIRED_MASK10	0
+#define REQUIRED_MASK11	0
+#define REQUIRED_MASK12	0
+#define REQUIRED_MASK13	0
+#define REQUIRED_MASK14	0
+#define REQUIRED_MASK15	0
+#define REQUIRED_MASK16	0
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -693,6 +693,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		c->x86_capability[CPUID_7_0_EBX] = ebx;
 
 		c->x86_capability[CPUID_6_EAX] = cpuid_eax(0x00000006);
+		c->x86_capability[CPUID_7_ECX] = ecx;
 	}
 
 	/* Extended state features: level 0x0000000d */


Patches currently in stable-queue which might be from srivatsa@csail.mit.edu are

queue-4.4/x86-cpufeature-x86-mm-pkeys-add-protection-keys-related-cpuid-definitions.patch
queue-4.4/x86-cpufeature-get-rid-of-the-non-asm-goto-variant.patch
queue-4.4/x86-boot-simplify-kernel-load-address-alignment-check.patch
queue-4.4/x86-cpufeature-speed-up-cpu_feature_enabled.patch
queue-4.4/x86-fpu-get-rid-of-xstate_fault.patch
queue-4.4/x86-cpufeature-x86-mm-pkeys-fix-broken-compile-time-disabling-of-pkeys.patch
queue-4.4/x86-cpufeature-add-helper-macro-for-mask-check-macros.patch
queue-4.4/x86-cpufeature-move-some-of-the-scattered-feature-bits-to-x86_capability.patch
queue-4.4/x86-cpu-add-detection-of-amd-ras-capabilities.patch
queue-4.4/x86-cpu-provide-a-config-option-to-disable-static_cpu_has.patch
queue-4.4/x86-fpu-add-an-xstate_op-macro.patch
queue-4.4/x86-cpufeature-make-sure-disabled-required-macros-are-updated.patch
queue-4.4/x86-headers-don-t-include-asm-processor.h-in-asm-atomic.h.patch
queue-4.4/x86-cpufeature-cleanup-get_cpu_cap.patch
queue-4.4/x86-mm-pkeys-fix-mismerge-of-protection-keys-cpuid-bits.patch
queue-4.4/x86-cpufeature-carve-out-x86_feature_.patch
queue-4.4/x86-cpufeature-update-cpufeaure-macros.patch
queue-4.4/x86-cpufeature-replace-the-old-static_cpu_has-with-safe-variant.patch
queue-4.4/x86-vdso-use-static_cpu_has.patch
queue-4.4/x86-alternatives-discard-dynamic-check-after-init.patch
queue-4.4/x86-alternatives-add-an-auxilary-section.patch
