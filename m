Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D07A6B003C
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:25:58 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so605512igb.0
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 09:25:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ga9si17072522igd.45.2014.09.30.09.25.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 09:25:57 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH v2 4/4] x86: remove high_memory check from valid_phys_addr_range
Date: Tue, 30 Sep 2014 18:25:03 +0200
Message-Id: <1412094303-28183-5-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1412094303-28183-1-git-send-email-fhrbata@redhat.com>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
 <1412094303-28183-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

There is no need to block read/write access to /dev/mem for phys. addr. above
high_memory for non-system RAM. The only limitation should be
boot_cpu_data.x86_phys_bits(max phys. addr. size).

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 77a13f8..788f2b7 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -127,7 +127,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 
 int valid_phys_addr_range(phys_addr_t addr, size_t count)
 {
-	return addr + count <= __pa(high_memory);
+	return arch_pfn_possible((addr + count) >> PAGE_SHIFT);
 }
 
 int valid_mmap_phys_addr_range(unsigned long pfn, size_t len_bytes)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
