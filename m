Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B44A6B034C
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:19:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so74394971pfg.5
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 13:19:08 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b10si31949871pfd.39.2016.12.22.13.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 13:19:07 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 2/4] dax: add stub for pmdp_huge_clear_flush()
Date: Thu, 22 Dec 2016 14:18:54 -0700
Message-Id: <1482441536-14550-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add a pmdp_huge_clear_flush() stub for configs that don't define
CONFIG_TRANSPARENT_HUGEPAGE.

We use a WARN_ON_ONCE() instead of a BUILD_BUG() because in the DAX code at
least we do want this compile successfully even for configs without
CONFIG_TRANSPARENT_HUGEPAGE.  It'll be a runtime decision whether we call
this code gets called, based on whether we find DAX PMD entries in our
tree.  We shouldn't ever find such PMD entries for
!CONFIG_TRANSPARENT_HUGEPAGE configs, so this function should never be
called.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/asm-generic/pgtable.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 18af2bc..65e9536 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -178,9 +178,19 @@ extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
 			      unsigned long address,
 			      pmd_t *pmdp);
+#else
+static inline pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
+			      unsigned long address,
+			      pmd_t *pmdp)
+{
+	WARN_ON_ONCE(1);
+	return *pmdp;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
