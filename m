Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 874F06B0011
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q3-v6so1777971wrn.3
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:58 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id y8si1576216edk.410.2018.04.26.07.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:52 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 7/9] s390: mm: migrate: add pmd swap entry to support thp migration.
Date: Thu, 26 Apr 2018 10:28:02 -0400
Message-Id: <20180426142804.180152-8-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Janosch Frank <frankja@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-s390@vger.kernel.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

pmd swap soft dirty support is added, too.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/s390/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 2d24d33bf188..215fbb34203e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -798,18 +798,21 @@ static inline int pmd_soft_dirty(pmd_t pmd)
 {
 	return pmd_val(pmd) & _SEGMENT_ENTRY_SOFT_DIRTY;
 }
+#define pmd_swp_soft_dirty pmd_soft_dirty
 
 static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 {
 	pmd_val(pmd) |= _SEGMENT_ENTRY_SOFT_DIRTY;
 	return pmd;
 }
+#define pmd_swp_mksoft_dirty pmd_mksoft_dirty
 
 static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
 {
 	pmd_val(pmd) &= ~_SEGMENT_ENTRY_SOFT_DIRTY;
 	return pmd;
 }
+#define pmd_swp_clear_soft_dirty pmd_clear_soft_dirty
 
 /*
  * query functions pte_write/pte_dirty/pte_young only work if
@@ -1594,7 +1597,9 @@ static inline swp_entry_t __swp_entry(unsigned long type, unsigned long offset)
 }
 
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
+#define __pmd_to_swp_entry(pte)	((swp_entry_t) { pmd_val(pmd) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
+#define __swp_entry_to_pmd(x)	((pmd_t) { (x).val })
 
 #define kern_addr_valid(addr)   (1)
 
-- 
2.17.0
