Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0CB6B04B0
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:12:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so1467200pgk.8
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:12:34 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0087.outbound.protection.outlook.com. [104.47.33.87])
        by mx.google.com with ESMTPS id 1si198922pgu.95.2017.07.17.14.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:12:33 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 25/38] swiotlb: Add warnings for use of bounce buffers with SME
Date: Mon, 17 Jul 2017 16:10:22 -0500
Message-Id: <d112564053c3f2e86ca634a8d4fa4abc0eb53a6a.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Add warnings to let the user know when bounce buffers are being used for
DMA when SME is active.  Since the bounce buffers are not in encrypted
memory, these notifications are to allow the user to determine some
appropriate action - if necessary.  Actions can range from utilizing an
IOMMU, replacing the device with another device that can support 64-bit
DMA, ignoring the message if the device isn't used much, etc.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 include/linux/dma-mapping.h | 13 +++++++++++++
 lib/swiotlb.c               |  3 +++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 843ab86..fce2369 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/kmemcheck.h>
 #include <linux/bug.h>
+#include <linux/mem_encrypt.h>
 
 /**
  * List of possible attributes associated with a DMA mapping. The semantics
@@ -548,6 +549,12 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return 0;
 }
 
+static inline void dma_check_mask(struct device *dev, u64 mask)
+{
+	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+}
+
 static inline int dma_supported(struct device *dev, u64 mask)
 {
 	const struct dma_map_ops *ops = get_dma_ops(dev);
@@ -564,6 +571,9 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
+
+	dma_check_mask(dev, mask);
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -583,6 +593,9 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask))
 		return -EIO;
+
+	dma_check_mask(dev, mask);
+
 	dev->coherent_dma_mask = mask;
 	return 0;
 }
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 04ac91a..8c6c83e 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -507,6 +507,9 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 	if (no_iotlb_memory)
 		panic("Can not allocate SWIOTLB buffer earlier and can't now provide you with the DMA bounce buffer");
 
+	if (sme_active())
+		pr_warn_once("SME is active and system is using DMA bounce buffers\n");
+
 	mask = dma_get_seg_boundary(hwdev);
 
 	tbl_dma_addr &= mask;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
