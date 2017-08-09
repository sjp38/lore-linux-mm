Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8836B0313
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:08:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p62so7108940oih.12
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:08:59 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id e14si3561450oib.377.2017.08.09.13.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:08:58 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id 76so3293101ith.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:08:58 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Date: Wed,  9 Aug 2017 14:07:49 -0600
Message-Id: <20170809200755.11234-5-tycho@docker.com>
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

Add a hook for flushing a single TLB entry on arm64.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Tested-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/include/asm/tlbflush.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm64/include/asm/tlbflush.h b/arch/arm64/include/asm/tlbflush.h
index af1c76981911..8e0c49105d3e 100644
--- a/arch/arm64/include/asm/tlbflush.h
+++ b/arch/arm64/include/asm/tlbflush.h
@@ -184,6 +184,14 @@ static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end
 	isb();
 }
 
+static inline void __flush_tlb_one(unsigned long addr)
+{
+	dsb(ishst);
+	__tlbi(vaae1is, addr >> 12);
+	dsb(ish);
+	isb();
+}
+
 /*
  * Used to invalidate the TLB (walk caches) corresponding to intermediate page
  * table levels (pgd/pud/pmd).
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
