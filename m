Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833748E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:37:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m4-v6so7796002pgq.19
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:37:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 10-v6si9957731ple.60.2018.09.07.15.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:37:37 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:38:10 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 10/12] x86/pconfig: Program memory encryption keys on a
 system-wide basis
Message-ID: <0947e4ad711e8b7c1f581a446e808f514620b49b.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

The kernel manages the MKTME (Multi-Key Total Memory Encryption) Keys
as a system wide single pool of keys. The hardware, however, manages
the keys on a per physical package basis. Each physical package
maintains a key table that all CPU's in that package share.

In order to maintain the consistent, system wide view that the kernel
requires, program all physical packages during a key program request.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 arch/x86/include/asm/intel_pconfig.h | 42 ++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/intel_pconfig.h b/arch/x86/include/asm/intel_pconfig.h
index 3cb002b1d0f9..d3bf0a297e89 100644
--- a/arch/x86/include/asm/intel_pconfig.h
+++ b/arch/x86/include/asm/intel_pconfig.h
@@ -3,6 +3,7 @@
 
 #include <asm/asm.h>
 #include <asm/processor.h>
+#include <linux/cpu.h>
 
 enum pconfig_target {
 	INVALID_TARGET	= 0,
@@ -47,19 +48,48 @@ struct mktme_key_program {
 	u8 key_field_2[64];
 } __packed __aligned(256);
 
-static inline int mktme_key_program(struct mktme_key_program *key_program)
+struct mktme_key_program_info {
+	struct mktme_key_program *key_program;
+	unsigned long status;
+};
+
+static void mktme_package_program(void *key_program_info)
 {
+	struct mktme_key_program_info *info = key_program_info;
 	unsigned long rax = MKTME_KEY_PROGRAM;
 
+	asm volatile(PCONFIG
+		: "=a" (rax), "=b" (info->key_program)
+		: "0" (rax), "1" (info->key_program)
+		: "memory", "cc");
+
+	if (rax != MKTME_PROG_SUCCESS)
+		WRITE_ONCE(info->status, rax);
+}
+
+/*
+ * MKTME keys are managed as a system-wide single pool of keys.
+ * In the hardware, each physical package maintains a separate key
+ * table. Program all physical packages with the same key info to
+ * maintain that system-wide kernel view.
+ */
+static inline int mktme_key_program(struct mktme_key_program *key_program,
+				    cpumask_var_t mktme_cpumask)
+{
+	struct mktme_key_program_info info = {
+		.key_program = key_program,
+		.status = MKTME_PROG_SUCCESS,
+	};
+
 	if (!pconfig_target_supported(MKTME_TARGET))
 		return -ENXIO;
 
-	asm volatile(PCONFIG
-		: "=a" (rax), "=b" (key_program)
-		: "0" (rax), "1" (key_program)
-		: "memory", "cc");
+	get_online_cpus();
+	on_each_cpu_mask(mktme_cpumask, mktme_package_program,
+			 &info, 1);
+	put_online_cpus();
 
-	return rax;
+	return info.status;
 }
 
 #endif	/* _ASM_X86_INTEL_PCONFIG_H */
-- 
2.14.1
