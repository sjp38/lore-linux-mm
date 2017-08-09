Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF3EB6B039F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:09:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j194so7113503oib.15
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:01 -0700 (PDT)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id w123si3521111oiw.536.2017.08.09.13.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:09:01 -0700 (PDT)
Received: by mail-it0-x22a.google.com with SMTP id m34so3265390iti.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:01 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v5 06/10] arm64/mm: Disable section mappings if XPFO is enabled
Date: Wed,  9 Aug 2017 14:07:51 -0600
Message-Id: <20170809200755.11234-7-tycho@docker.com>
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

XPFO (eXclusive Page Frame Ownership) doesn't support section mappings
yet, so disable it if XPFO is turned on.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Tested-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/mm/mmu.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index f1eb15e0e864..38026b3ccb46 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -176,6 +176,18 @@ static void alloc_init_cont_pte(pmd_t *pmd, unsigned long addr,
 	} while (addr = next, addr != end);
 }
 
+static inline bool use_section_mapping(unsigned long addr, unsigned long next,
+				unsigned long phys)
+{
+	if (IS_ENABLED(CONFIG_XPFO))
+		return false;
+
+	if (((addr | next | phys) & ~SECTION_MASK) != 0)
+		return false;
+
+	return true;
+}
+
 static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
 		     phys_addr_t phys, pgprot_t prot,
 		     phys_addr_t (*pgtable_alloc)(void), int flags)
@@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 
 		/* try section mapping first */
-		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
+		if (use_section_mapping(addr, next, phys) &&
 		    (flags & NO_BLOCK_MAPPINGS) == 0) {
 			pmd_set_huge(pmd, phys, prot);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
