Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D08A8E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f9so15242490pgs.13
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133351.828074959@intel.com>
Date: Wed, 26 Dec 2018 21:14:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 13/21] x86/pgtable: dont check PMD accessed bit
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0006-pgtable-don-t-check-the-page-accessed-bit.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Jingqi Liu <jingqi.liu@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Jingqi Liu <jingqi.liu@intel.com>

ept-idle will clear PMD accessed bit to speedup PTE scan -- if the bit
remains unset in the next scan, all the 512 PTEs can be skipped.

So don't complain on !_PAGE_ACCESSED in pmd_bad().

Note that clearing PMD accessed bit has its own cost, the optimization
may only be worthwhile for
- large idle area
- sparsely populated area

Signed-off-by: Jingqi Liu <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/pgtable.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/include/asm/pgtable.h	2018-12-23 19:50:50.917902600 +0800
+++ linux/arch/x86/include/asm/pgtable.h	2018-12-23 19:50:50.913902605 +0800
@@ -821,7 +821,8 @@ static inline pte_t *pte_offset_kernel(p
 
 static inline int pmd_bad(pmd_t pmd)
 {
-	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
+	return (pmd_flags(pmd) & ~(_PAGE_USER | _PAGE_ACCESSED)) !=
+					(_KERNPG_TABLE & ~_PAGE_ACCESSED);
 }
 
 static inline unsigned long pages_to_mb(unsigned long npg)
