Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2053B6B0628
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 13:05:19 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id c16-v6so18693463wrr.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 10:05:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j20-v6sor3029732wrd.49.2018.11.08.10.05.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 10:05:17 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] efi: permit calling efi_mem_reserve_persistent from atomic context
Date: Thu,  8 Nov 2018 19:05:11 +0100
Message-Id: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, cai@gmx.us, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marc.zyngier@arm.com, will.deacon@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Currently, efi_mem_reserve_persistent() may not be called from atomic
context, since both the kmalloc() call and the memremap() call may
sleep.

The kmalloc() call is easy enough to fix, but the memremap() call
needs to be moved into an init hook since we cannot control the
memory allocation behavior of memremap() at the call site.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 drivers/firmware/efi/efi.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 249eb70691b0..cfc876e0b67b 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -963,36 +963,43 @@ bool efi_is_table_address(unsigned long phys_addr)
 }
 
 static DEFINE_SPINLOCK(efi_mem_reserve_persistent_lock);
+static struct linux_efi_memreserve *efi_memreserve_root __ro_after_init;
 
 int efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
 {
-	struct linux_efi_memreserve *rsv, *parent;
+	struct linux_efi_memreserve *rsv;
 
-	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
+	if (!efi_memreserve_root)
 		return -ENODEV;
 
-	rsv = kmalloc(sizeof(*rsv), GFP_KERNEL);
+	rsv = kmalloc(sizeof(*rsv), GFP_ATOMIC);
 	if (!rsv)
 		return -ENOMEM;
 
-	parent = memremap(efi.mem_reserve, sizeof(*rsv), MEMREMAP_WB);
-	if (!parent) {
-		kfree(rsv);
-		return -ENOMEM;
-	}
-
 	rsv->base = addr;
 	rsv->size = size;
 
 	spin_lock(&efi_mem_reserve_persistent_lock);
-	rsv->next = parent->next;
-	parent->next = __pa(rsv);
+	rsv->next = efi_memreserve_root->next;
+	efi_memreserve_root->next = __pa(rsv);
 	spin_unlock(&efi_mem_reserve_persistent_lock);
 
-	memunmap(parent);
+	return 0;
+}
 
+static int __init efi_memreserve_root_init(void)
+{
+	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
+		return -ENODEV;
+
+	efi_memreserve_root = memremap(efi.mem_reserve,
+				       sizeof(*efi_memreserve_root),
+				       MEMREMAP_WB);
+	if (!efi_memreserve_root)
+		return -ENOMEM;
 	return 0;
 }
+early_initcall(efi_memreserve_root_init);
 
 #ifdef CONFIG_KEXEC
 static int update_efi_random_seed(struct notifier_block *nb,
-- 
2.19.1
