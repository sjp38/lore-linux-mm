Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48B416B0275
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:38:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n128so8554048ith.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:38:26 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0078.outbound.protection.outlook.com. [104.47.38.78])
        by mx.google.com with ESMTPS id v11si101829ota.71.2016.08.22.15.38.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:38:25 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 15/20] iommu/amd: AMD IOMMU support for memory
 encryption
Date: Mon, 22 Aug 2016 17:38:20 -0500
Message-ID: <20160822223820.29880.17752.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add support to the AMD IOMMU driver to set the memory encryption mask if
memory encryption is enabled.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    2 ++
 arch/x86/mm/mem_encrypt.c          |    5 +++++
 drivers/iommu/amd_iommu.c          |   10 ++++++++++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 384fdfb..e395729 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -36,6 +36,8 @@ void __init sme_early_init(void);
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_init(void);
 
+unsigned long amd_iommu_get_me_mask(void);
+
 unsigned long swiotlb_get_me_mask(void);
 void swiotlb_set_mem_dec(void *vaddr, unsigned long size);
 
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 6b2e8bf..2f28d87 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -185,6 +185,11 @@ void __init mem_encrypt_init(void)
 	swiotlb_clear_encryption();
 }
 
+unsigned long amd_iommu_get_me_mask(void)
+{
+	return sme_me_mask;
+}
+
 unsigned long swiotlb_get_me_mask(void)
 {
 	return sme_me_mask;
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 96de97a..63995e3 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -166,6 +166,15 @@ struct dma_ops_domain {
 static struct iova_domain reserved_iova_ranges;
 static struct lock_class_key reserved_rbtree_key;
 
+/*
+ * Support for memory encryption. If memory encryption is supported, then an
+ * override to this function will be provided.
+ */
+unsigned long __weak amd_iommu_get_me_mask(void)
+{
+	return 0;
+}
+
 /****************************************************************************
  *
  * Helper functions
@@ -2302,6 +2311,7 @@ static dma_addr_t __map_single(struct device *dev,
 
 	prot = dir2prot(direction);
 
+	paddr |= amd_iommu_get_me_mask();
 	start = address;
 	for (i = 0; i < pages; ++i) {
 		ret = iommu_map_page(&dma_dom->domain, start, paddr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
