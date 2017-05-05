Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7BA6B0311
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:03:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z125so13423582itc.12
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:03:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a78si27080336ioa.51.2017.05.05.10.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:03:33 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v3 6/9] sparc64: teach sparc not to zero struct pages memory
Date: Fri,  5 May 2017 13:03:13 -0400
Message-Id: <1494003796-748672-7-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

If we are using deferred struct page initialization feature, most of
"struct page"es are getting initialized after other CPUs are started, and
hence we are benefiting from doing this job in parallel. However, we are
still zeroing all the memory that is allocated for "struct pages" using the
boot CPU.  This patch solves this problem, by deferring zeroing "struct
pages" to only when they are initialized on SPARC.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 arch/sparc/mm/init_64.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index c72d070..dae040c 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2546,7 +2546,7 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 		pte = pmd_val(*pmd);
 		if (!(pte & _PAGE_VALID)) {
 			void *block = vmemmap_alloc_block(PMD_SIZE, node,
-							  true);
+							  VMEMMAP_ZERO);
 
 			if (!block)
 				return -ENOMEM;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
