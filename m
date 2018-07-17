Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFC116B0278
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:21:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 132-v6so323192pga.18
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:21:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b23-v6si597132pls.341.2018.07.17.04.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 04:21:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 10/19] x86/mm: Implement page_keyid() using page_ext
Date: Tue, 17 Jul 2018 14:20:20 +0300
Message-Id: <20180717112029.42378-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Store KeyID in bits 31:16 of extended page flags. These bits are unused.

page_keyid() returns zero until page_ext is ready. page_ext initializer
enables static branch to indicate that page_keyid() can use page_ext.
The same static branch will gate MKTME readiness in general.

We don't yet set KeyID for the page. It will come in the following
patch that implements prep_encrypted_page(). All pages have KeyID-0 for
now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  7 +++++++
 arch/x86/include/asm/page.h  |  1 +
 arch/x86/mm/mktme.c          | 34 ++++++++++++++++++++++++++++++++++
 include/linux/page_ext.h     | 11 ++++++++++-
 mm/page_ext.c                |  3 +++
 5 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index df31876ec48c..7266494b4f0a 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -2,11 +2,18 @@
 #define	_ASM_X86_MKTME_H
 
 #include <linux/types.h>
+#include <linux/page_ext.h>
 
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
+
+extern struct page_ext_operations page_mktme_ops;
+
+#define page_keyid page_keyid
+int page_keyid(const struct page *page);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 7555b48803a8..39af59487d5f 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -19,6 +19,7 @@
 struct page;
 
 #include <linux/range.h>
+#include <asm/mktme.h>
 extern struct range pfn_mapped[];
 extern int nr_pfn_mapped;
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 467f1b26c737..09cbff678b9f 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -3,3 +3,37 @@
 phys_addr_t mktme_keyid_mask;
 int mktme_nr_keyids;
 int mktme_keyid_shift;
+
+static DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
+
+static inline bool mktme_enabled(void)
+{
+	return static_branch_unlikely(&mktme_enabled_key);
+}
+
+int page_keyid(const struct page *page)
+{
+	if (!mktme_enabled())
+		return 0;
+
+	return lookup_page_ext(page)->keyid;
+}
+EXPORT_SYMBOL(page_keyid);
+
+static bool need_page_mktme(void)
+{
+	/* Make sure keyid doesn't collide with extended page flags */
+	BUILD_BUG_ON(__NR_PAGE_EXT_FLAGS > 16);
+
+	return !!mktme_nr_keyids;
+}
+
+static void init_page_mktme(void)
+{
+	static_branch_enable(&mktme_enabled_key);
+}
+
+struct page_ext_operations page_mktme_ops = {
+	.need = need_page_mktme,
+	.init = init_page_mktme,
+};
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index f84f167ec04c..d9c5aae9523f 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -23,6 +23,7 @@ enum page_ext_flags {
 	PAGE_EXT_YOUNG,
 	PAGE_EXT_IDLE,
 #endif
+	__NR_PAGE_EXT_FLAGS
 };
 
 /*
@@ -33,7 +34,15 @@ enum page_ext_flags {
  * then the page_ext for pfn always exists.
  */
 struct page_ext {
-	unsigned long flags;
+	union {
+		unsigned long flags;
+#ifdef CONFIG_X86_INTEL_MKTME
+		struct {
+			unsigned short __pad;
+			unsigned short keyid;
+		};
+#endif
+	};
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/mm/page_ext.c b/mm/page_ext.c
index a9826da84ccb..036658229842 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -68,6 +68,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
+#ifdef CONFIG_X86_INTEL_MKTME
+	&page_mktme_ops,
+#endif
 };
 
 static unsigned long total_usage;
-- 
2.18.0
