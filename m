Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CF9936B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:09:46 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n5so20116034wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:09:46 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id xb9si4340612wjc.63.2016.01.27.02.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 02:09:43 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 27 Jan 2016 10:09:42 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0D9AB1B08079
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:09:47 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0RA9dwC9765362
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:09:39 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0RA9cCK030236
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 03:09:39 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v3 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
Date: Wed, 27 Jan 2016 11:10:01 +0100
Message-Id: <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk, Christian Borntraeger <borntraeger@de.ibm.com>

We can use debug_pagealloc_enabled() to check if we can map
the identity mapping with 1MB/2GB pages as well as to print
the current setting in dump_stack.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Reviewed-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/kernel/dumpstack.c |  6 +++---
 arch/s390/mm/vmem.c          | 10 ++++------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/arch/s390/kernel/dumpstack.c b/arch/s390/kernel/dumpstack.c
index dc8e204..e57eb22 100644
--- a/arch/s390/kernel/dumpstack.c
+++ b/arch/s390/kernel/dumpstack.c
@@ -11,6 +11,7 @@
 #include <linux/export.h>
 #include <linux/kdebug.h>
 #include <linux/ptrace.h>
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <asm/processor.h>
@@ -185,9 +186,8 @@ void die(struct pt_regs *regs, const char *str)
 #ifdef CONFIG_SMP
 	printk("SMP ");
 #endif
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	printk("DEBUG_PAGEALLOC");
-#endif
+	if (debug_pagealloc_enabled())
+		printk("DEBUG_PAGEALLOC");
 	printk("\n");
 	notify_die(DIE_OOPS, str, regs, 0, regs->int_code & 0xffff, SIGSEGV);
 	print_modules();
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index ef7d6c8..d27fccba 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -94,16 +94,15 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 			pgd_populate(&init_mm, pg_dir, pu_dir);
 		}
 		pu_dir = pud_offset(pg_dir, address);
-#ifndef CONFIG_DEBUG_PAGEALLOC
 		if (MACHINE_HAS_EDAT2 && pud_none(*pu_dir) && address &&
-		    !(address & ~PUD_MASK) && (address + PUD_SIZE <= end)) {
+		    !(address & ~PUD_MASK) && (address + PUD_SIZE <= end) &&
+		     !debug_pagealloc_enabled()) {
 			pud_val(*pu_dir) = __pa(address) |
 				_REGION_ENTRY_TYPE_R3 | _REGION3_ENTRY_LARGE |
 				(ro ? _REGION_ENTRY_PROTECT : 0);
 			address += PUD_SIZE;
 			continue;
 		}
-#endif
 		if (pud_none(*pu_dir)) {
 			pm_dir = vmem_pmd_alloc();
 			if (!pm_dir)
@@ -111,9 +110,9 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 			pud_populate(&init_mm, pu_dir, pm_dir);
 		}
 		pm_dir = pmd_offset(pu_dir, address);
-#ifndef CONFIG_DEBUG_PAGEALLOC
 		if (MACHINE_HAS_EDAT1 && pmd_none(*pm_dir) && address &&
-		    !(address & ~PMD_MASK) && (address + PMD_SIZE <= end)) {
+		    !(address & ~PMD_MASK) && (address + PMD_SIZE <= end) &&
+		    !debug_pagealloc_enabled()) {
 			pmd_val(*pm_dir) = __pa(address) |
 				_SEGMENT_ENTRY | _SEGMENT_ENTRY_LARGE |
 				_SEGMENT_ENTRY_YOUNG |
@@ -121,7 +120,6 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 			address += PMD_SIZE;
 			continue;
 		}
-#endif
 		if (pmd_none(*pm_dir)) {
 			pt_dir = vmem_pte_alloc(address);
 			if (!pt_dir)
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
