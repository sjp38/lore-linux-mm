Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1DF280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:46:26 -0400 (EDT)
Received: by wiar9 with SMTP id r9so130189213wia.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:46:26 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id v3si14368147wjz.77.2015.07.03.05.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jul 2015 05:46:20 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 3 Jul 2015 13:46:19 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 97DE7219005E
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:45:54 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t63CkGnr39649516
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 12:46:16 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t63CkF01015005
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 06:46:16 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/4] Revert "s390/mm: make hugepages_supported a boot time decision"
Date: Fri,  3 Jul 2015 14:46:07 +0200
Message-Id: <1435927569-41132-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

This reverts commit bea41197ead3e03308bdd10c11db3ce91ae5c8ab.
---
 arch/s390/include/asm/page.h | 8 ++++----
 arch/s390/kernel/setup.c     | 2 --
 arch/s390/mm/pgtable.c       | 2 --
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index 0844b78..53eacbd 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -17,10 +17,7 @@
 #define PAGE_DEFAULT_ACC	0
 #define PAGE_DEFAULT_KEY	(PAGE_DEFAULT_ACC << 4)
 
-#include <asm/setup.h>
-#ifndef __ASSEMBLY__
-
-extern unsigned int HPAGE_SHIFT;
+#define HPAGE_SHIFT	20
 #define HPAGE_SIZE	(1UL << HPAGE_SHIFT)
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
@@ -30,6 +27,9 @@ extern unsigned int HPAGE_SHIFT;
 #define ARCH_HAS_PREPARE_HUGEPAGE
 #define ARCH_HAS_HUGEPAGE_CLEAR_FLUSH
 
+#include <asm/setup.h>
+#ifndef __ASSEMBLY__
+
 static inline void storage_key_init_range(unsigned long start, unsigned long end)
 {
 #if PAGE_DEFAULT_KEY
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index f7f027c..ca070d2 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -885,8 +885,6 @@ void __init setup_arch(char **cmdline_p)
 	 */
 	setup_hwcaps();
 
-	HPAGE_SHIFT = MACHINE_HAS_HPAGE ? 20 : 0;
-
 	/*
 	 * Create kernel page tables and switch to virtual addressing.
 	 */
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 16154720..b33f661 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -31,8 +31,6 @@
 #define ALLOC_ORDER	2
 #define FRAG_MASK	0x03
 
-unsigned int HPAGE_SHIFT;
-
 unsigned long *crst_table_alloc(struct mm_struct *mm)
 {
 	struct page *page = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
-- 
2.3.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
