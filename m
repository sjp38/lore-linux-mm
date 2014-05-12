Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 742FF6B0035
	for <linux-mm@kvack.org>; Sun, 11 May 2014 23:06:25 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so7363256pab.36
        for <linux-mm@kvack.org>; Sun, 11 May 2014 20:06:25 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0128.outbound.protection.outlook.com. [65.55.169.128])
        by mx.google.com with ESMTPS id ps1si5624249pbc.465.2014.05.11.20.06.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 11 May 2014 20:06:24 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused support.
Date: Mon, 12 May 2014 10:19:55 +0800
Message-ID: <1399861195-21087-3-git-send-email-superlibj8301@gmail.com>
In-Reply-To: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Richard Lee <superlibj8301@gmail.com>, Richard Lee <superlibj@gmail.com>

For the IO mapping, for the same physical address space maybe
mapped more than one time, for example, in some SoCs:
0x20000000 ~ 0x20001000: are global control IO physical map,
and this range space will be used by many drivers.
And then if each driver will do the same ioremap operation, we
will waste to much malloc virtual spaces.

This patch add IO mapping space reused support.

Signed-off-by: Richard Lee <superlibj@gmail.com>
---
 arch/arm/mm/ioremap.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index f9c32ba..26a3744 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -260,7 +260,7 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 {
 	const struct mem_type *type;
 	int err;
-	unsigned long addr;
+	unsigned long addr, off;
 	struct vm_struct *area;
 	phys_addr_t paddr = __pfn_to_phys(pfn);
 
@@ -301,6 +301,12 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 	if (WARN_ON(pfn_valid(pfn)))
 		return NULL;
 
+	area = find_vm_area_paddr(paddr, size, &off, VM_IOREMAP);
+	if (area) {
+		addr = (unsigned long)area->addr;
+		return (void __iomem *)(offset + off + addr);
+	}
+
 	area = get_vm_area_caller(size, VM_IOREMAP, caller);
  	if (!area)
  		return NULL;
@@ -410,6 +416,9 @@ void __iounmap(volatile void __iomem *io_addr)
 	if (svm)
 		return;
 
+	if (!vm_area_is_aready_to_free((unsigned long)addr))
+		return;
+
 #if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
 	{
 		struct vm_struct *vm;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
