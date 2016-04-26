Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 175D86B0272
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:58:31 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id u5so48080020igk.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:58:31 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0098.outbound.protection.outlook.com. [207.46.100.98])
        by mx.google.com with ESMTPS id d76si5891300iod.12.2016.04.26.15.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:58:30 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 14/18] iommu/amd: AMD IOMMU support for memory
 encryption
Date: Tue, 26 Apr 2016 17:58:24 -0500
Message-ID: <20160426225824.13567.79822.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

Add support to the AMD IOMMU driver to set the memory encryption mask if
memory encryption is enabled.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    2 ++
 arch/x86/mm/mem_encrypt.c          |    5 +++++
 drivers/iommu/amd_iommu.c          |   10 ++++++++++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index d17d8cf..55163e4 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -39,6 +39,8 @@ void __init sme_early_init(void);
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_init(void);
 
+unsigned long amd_iommu_get_me_mask(void);
+
 unsigned long swiotlb_get_me_mask(void);
 void swiotlb_set_mem_dec(void *vaddr, unsigned long size);
 
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 594dc65..6efceb8 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -179,6 +179,11 @@ void __init mem_encrypt_init(void)
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
index 5efadad..5dc8f52 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -156,6 +156,15 @@ struct dma_ops_domain {
 	struct aperture_range *aperture[APERTURE_MAX_RANGES];
 };
 
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
@@ -2612,6 +2621,7 @@ static dma_addr_t __map_single(struct device *dev,
 	if (address == DMA_ERROR_CODE)
 		goto out;
 
+	paddr |= amd_iommu_get_me_mask();
 	start = address;
 	for (i = 0; i < pages; ++i) {
 		ret = dma_ops_domain_map(dma_dom, start, paddr, dir);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
