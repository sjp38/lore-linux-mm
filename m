Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63DFC6B0031
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v186so9930477pfb.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:40 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v77si4239219pfa.108.2018.03.05.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 05/22] x86/pconfig: Provide defines and helper to run MKTME_KEY_PROG leaf
Date: Mon,  5 Mar 2018 19:25:53 +0300
Message-Id: <20180305162610.37510-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

MKTME_KEY_PROG allows to manipulate MKTME keys in the CPU.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/intel_pconfig.h | 50 ++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/arch/x86/include/asm/intel_pconfig.h b/arch/x86/include/asm/intel_pconfig.h
index fb7a37c3798b..3cb002b1d0f9 100644
--- a/arch/x86/include/asm/intel_pconfig.h
+++ b/arch/x86/include/asm/intel_pconfig.h
@@ -12,4 +12,54 @@ enum pconfig_target {
 
 int pconfig_target_supported(enum pconfig_target target);
 
+enum pconfig_leaf {
+	MKTME_KEY_PROGRAM	= 0,
+	PCONFIG_LEAF_INVALID,
+};
+
+#define PCONFIG ".byte 0x0f, 0x01, 0xc5"
+
+/* Defines and structure for MKTME_KEY_PROGRAM of PCONFIG instruction */
+
+/* mktme_key_program::keyid_ctrl COMMAND, bits [7:0] */
+#define MKTME_KEYID_SET_KEY_DIRECT	0
+#define MKTME_KEYID_SET_KEY_RANDOM	1
+#define MKTME_KEYID_CLEAR_KEY		2
+#define MKTME_KEYID_NO_ENCRYPT		3
+
+/* mktme_key_program::keyid_ctrl ENC_ALG, bits [23:8] */
+#define MKTME_AES_XTS_128	(1 << 8)
+
+/* Return codes from the PCONFIG MKTME_KEY_PROGRAM */
+#define MKTME_PROG_SUCCESS	0
+#define MKTME_INVALID_PROG_CMD	1
+#define MKTME_ENTROPY_ERROR	2
+#define MKTME_INVALID_KEYID	3
+#define MKTME_INVALID_ENC_ALG	4
+#define MKTME_DEVICE_BUSY	5
+
+/* Hardware requires the structure to be 256 byte alinged. Otherwise #GP(0). */
+struct mktme_key_program {
+	u16 keyid;
+	u32 keyid_ctrl;
+	u8 __rsvd[58];
+	u8 key_field_1[64];
+	u8 key_field_2[64];
+} __packed __aligned(256);
+
+static inline int mktme_key_program(struct mktme_key_program *key_program)
+{
+	unsigned long rax = MKTME_KEY_PROGRAM;
+
+	if (!pconfig_target_supported(MKTME_TARGET))
+		return -ENXIO;
+
+	asm volatile(PCONFIG
+		: "=a" (rax), "=b" (key_program)
+		: "0" (rax), "1" (key_program)
+		: "memory", "cc");
+
+	return rax;
+}
+
 #endif	/* _ASM_X86_INTEL_PCONFIG_H */
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
