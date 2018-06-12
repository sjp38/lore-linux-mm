Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25E876B026E
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so14147748plf.19
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x4-v6si213451pgv.592.2018.06.12.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 12/17] x86/mm: Allow to disable MKTME after enumeration
Date: Tue, 12 Jun 2018 17:39:10 +0300
Message-Id: <20180612143915.68065-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Separate MKTME enumaration from enabling. We need to postpone enabling
until initialization is complete.

The new helper mktme_disable() allows to disable MKTME even if it's
enumerated successfully. MKTME initialization may fail and this
functionallity allows system to boot regardless of the failure.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 12 ++++++++++++
 arch/x86/kernel/cpu/intel.c  | 15 ++++-----------
 arch/x86/mm/mktme.c          |  9 +++++++++
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index ec7036abdb3f..9363b989a021 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -6,11 +6,21 @@
 
 struct vm_area_struct;
 
+/* Values for mktme_status */
+#define MKTME_DISABLED			0
+#define MKTME_ENUMERATED		1
+#define MKTME_ENABLED			2
+#define MKTME_UNINITIALIZED		3
+
+extern int mktme_status;
+
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
 
+void mktme_disable(void);
+
 #define prep_encrypted_page prep_encrypted_page
 void prep_encrypted_page(struct page *page, int order, int keyid, bool zero);
 
@@ -28,6 +38,8 @@ extern struct page_ext_operations page_mktme_ops;
 #define page_keyid page_keyid
 int page_keyid(const struct page *page);
 
+void mktme_disable(void);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index efc9e9fc47d4..fb58776513e6 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -508,11 +508,7 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 #define TME_ACTIVATE_CRYPTO_ALGS(x)	((x >> 48) & 0xffff)	/* Bits 63:48 */
 #define TME_ACTIVATE_CRYPTO_AES_XTS_128	1
 
-/* Values for mktme_status (SW only construct) */
-#define MKTME_ENABLED			0
-#define MKTME_DISABLED			1
-#define MKTME_UNINITIALIZED		2
-static int mktme_status = MKTME_UNINITIALIZED;
+int mktme_status __ro_after_init = MKTME_UNINITIALIZED;
 
 static void detect_tme(struct cpuinfo_x86 *c)
 {
@@ -568,11 +564,11 @@ static void detect_tme(struct cpuinfo_x86 *c)
 
 	if (mktme_status == MKTME_UNINITIALIZED) {
 		/* MKTME is usable */
-		mktme_status = MKTME_ENABLED;
+		mktme_status = MKTME_ENUMERATED;
 	}
 
 #ifdef CONFIG_X86_INTEL_MKTME
-	if (mktme_status == MKTME_ENABLED && nr_keyids) {
+	if (mktme_status == MKTME_ENUMERATED && nr_keyids) {
 		mktme_nr_keyids = nr_keyids;
 		mktme_keyid_shift = c->x86_phys_bits - keyid_bits;
 
@@ -591,10 +587,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		 * Maybe needed if there's inconsistent configuation
 		 * between CPUs.
 		 */
-		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
-		mktme_keyid_mask = 0;
-		mktme_keyid_shift = 0;
-		mktme_nr_keyids = 0;
+		mktme_disable();
 	}
 #endif
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 1821b87abb2f..43a44f0f2a2d 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -6,6 +6,15 @@ phys_addr_t mktme_keyid_mask;
 int mktme_nr_keyids;
 int mktme_keyid_shift;
 
+void mktme_disable(void)
+{
+	physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	mktme_keyid_mask = 0;
+	mktme_keyid_shift = 0;
+	mktme_nr_keyids = 0;
+	mktme_status = MKTME_DISABLED;
+}
+
 int page_keyid(const struct page *page)
 {
 	if (mktme_status != MKTME_ENABLED)
-- 
2.17.1
