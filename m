Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 842846B0039
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:33:32 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id z60so10380534qgd.15
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 04:33:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x77si13202296qgx.82.2014.09.29.04.33.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 04:33:31 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [RESEND PATCH 1/4] x86: add arch_pfn_possible helper
Date: Mon, 29 Sep 2014 13:32:59 +0200
Message-Id: <1411990382-11902-2-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

Add helper to check maximum possible pfn on x86. Also make the current
phys_addr_valid helper using it internally.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/mm/physaddr.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/physaddr.h b/arch/x86/mm/physaddr.h
index a3cd5a0..9df8e3a 100644
--- a/arch/x86/mm/physaddr.h
+++ b/arch/x86/mm/physaddr.h
@@ -1,10 +1,15 @@
 #include <asm/processor.h>
 
-static inline int phys_addr_valid(resource_size_t addr)
+static inline int arch_pfn_possible(unsigned long pfn)
 {
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
-	return !(addr >> boot_cpu_data.x86_phys_bits);
+	return !(pfn >> (boot_cpu_data.x86_phys_bits - PAGE_SHIFT));
 #else
 	return 1;
 #endif
 }
+
+static inline int phys_addr_valid(resource_size_t addr)
+{
+	return arch_pfn_possible(addr >> PAGE_SHIFT);
+}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
