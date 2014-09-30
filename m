Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id A3C696B003B
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:25:51 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id rp18so4134201iec.16
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 09:25:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w2si17104113igl.16.2014.09.30.09.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 09:25:50 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH v2 3/4] x86: add high_memory check to (xlate|unxlate)_dev_mem_ptr
Date: Tue, 30 Sep 2014 18:25:02 +0200
Message-Id: <1412094303-28183-4-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1412094303-28183-1-git-send-email-fhrbata@redhat.com>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
 <1412094303-28183-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

So far (xlate|unxlate)_dev_mem_ptr for read/write /dev/mem relies on a generic
high_memory check in valid_phys_addr_range(), which does not allow to access any
memory above high_memory whatsoever. By adding the high_memory check to
(xlate|unxlate)_dev_mem_ptr, it still will be possible to use __va safely for
kernel mapped memory and it will also allow read/write to access non-system RAM
above high_memory once the high_memory check is removed from
valid_phys_addr_range.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/mm/ioremap.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index baff1da..1ae7323 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -320,8 +320,11 @@ void *xlate_dev_mem_ptr(unsigned long phys)
 	void *addr;
 	unsigned long start = phys & PAGE_MASK;
 
-	/* If page is RAM, we can use __va. Otherwise ioremap and unmap. */
-	if (page_is_ram(start >> PAGE_SHIFT))
+	/*
+	 * If page is RAM and is mapped by kernel, we can use __va.
+	 * Otherwise ioremap and unmap.
+	 */
+	if (page_is_ram(start >> PAGE_SHIFT) && phys <= __pa(high_memory))
 		return __va(phys);
 
 	addr = (void __force *)ioremap_cache(start, PAGE_SIZE);
@@ -333,7 +336,7 @@ void *xlate_dev_mem_ptr(unsigned long phys)
 
 void unxlate_dev_mem_ptr(unsigned long phys, void *addr)
 {
-	if (page_is_ram(phys >> PAGE_SHIFT))
+	if (page_is_ram(phys >> PAGE_SHIFT) && phys <= __pa(high_memory))
 		return;
 
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
