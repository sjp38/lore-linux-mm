Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA076B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 03:54:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t15so1083003wmh.3
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 00:54:18 -0800 (PST)
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id r19si271642wmd.122.2018.01.11.00.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 00:54:16 -0800 (PST)
From: Alexandre Ghiti <aghiti@upmem.com>
Subject: [PATCH] mm, THP: vmf_insert_pfn_pud depends on CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
Date: Thu, 11 Jan 2018 09:53:31 +0100
Message-Id: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, gregkh@linuxfoundation.org, n-horiguchi@ah.jp.nec.com, willy@linux.intel.com, mark.rutland@arm.com, linux-kernel@vger.kernel.org, Alexandre Ghiti <aghiti@upmem.com>

The only definition of vmf_insert_pfn_pud depends on
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD being defined. Then its declaration in
include/linux/huge_mm.h should have the same restriction so that we do
not expose this function if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is
not defined.

Signed-off-by: Alexandre Ghiti <aghiti@upmem.com>
---
 include/linux/huge_mm.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a1262..11794f6a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -48,8 +48,10 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
+#endif
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
