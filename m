Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAAF76B0267
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:56:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f63so53194753oig.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:56:44 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0099.outbound.protection.outlook.com. [65.55.169.99])
        by mx.google.com with ESMTPS id p143si5881369ioe.43.2016.04.26.15.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:56:44 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 04/18] x86: Add the Secure Memory Encryption cpu
 feature
Date: Tue, 26 Apr 2016 17:56:35 -0500
Message-ID: <20160426225635.13567.39381.stgit@tlendack-t1.amdoffice.net>
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

Update the cpu features to include identifying and reporting on the
Secure Memory Encryption feature.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cpufeature.h  |    1 +
 arch/x86/include/asm/cpufeatures.h |    5 ++++-
 arch/x86/kernel/cpu/scattered.c    |    1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index 07c942d..e27e352 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -27,6 +27,7 @@ enum cpuid_leafs
 	CPUID_6_EAX,
 	CPUID_8000_000A_EDX,
 	CPUID_7_ECX,
+	CPUID_8000_001F_EAX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 47b5056..4aea205 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -12,7 +12,7 @@
 /*
  * Defines x86 CPU feature bits
  */
-#define NCAPINTS	17	/* N 32-bit words worth of info */
+#define NCAPINTS	18	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -282,6 +282,9 @@
 #define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
 
+/* AMD SME Feature Identification, CPUID level 0x8000001f (eax), word 17 */
+#define X86_FEATURE_SME		(17*32+ 0) /* Secure Memory Encryption support */
+
 /*
  * BUG word(s)
  */
diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
index 8cb57df..d86d9a5 100644
--- a/arch/x86/kernel/cpu/scattered.c
+++ b/arch/x86/kernel/cpu/scattered.c
@@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struct cpuinfo_x86 *c)
 		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
 		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
 		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
+		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },
 		{ 0, 0, 0, 0, 0 }
 	};
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
