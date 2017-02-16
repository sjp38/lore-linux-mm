Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FED8680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:46:29 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e137so42890719itc.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:46:29 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0052.outbound.protection.outlook.com. [104.47.32.52])
        by mx.google.com with ESMTPS id y130si7531093ioy.116.2017.02.16.07.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:46:28 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 19/28] swiotlb: Add warnings for use of bounce
 buffers with SME
Date: Thu, 16 Feb 2017 09:46:19 -0600
Message-ID: <20170216154619.19244.76653.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Add warnings to let the user know when bounce buffers are being used for
DMA when SME is active.  Since the bounce buffers are not in encrypted
memory, these notifications are to allow the user to determine some
appropriate action - if necessary.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   11 +++++++++++
 include/linux/dma-mapping.h        |   11 +++++++++++
 include/linux/mem_encrypt.h        |    6 ++++++
 lib/swiotlb.c                      |    3 +++
 4 files changed, 31 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 87e816f..5a17f1b 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -26,6 +26,11 @@ static inline bool sme_active(void)
 	return (sme_me_mask) ? true : false;
 }
 
+static inline u64 sme_dma_mask(void)
+{
+	return ((u64)sme_me_mask << 1) - 1;
+}
+
 void __init sme_early_encrypt(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_decrypt(resource_size_t paddr,
@@ -53,6 +58,12 @@ static inline bool sme_active(void)
 {
 	return false;
 }
+
+static inline u64 sme_dma_mask(void)
+{
+	return 0ULL;
+}
+
 #endif
 
 static inline void __init sme_early_encrypt(resource_size_t paddr,
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 10c5a17..130bef7 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/kmemcheck.h>
 #include <linux/bug.h>
+#include <linux/mem_encrypt.h>
 
 /**
  * List of possible attributes associated with a DMA mapping. The semantics
@@ -557,6 +558,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn(dev,
+			 "SME is active, device will require DMA bounce buffers\n");
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -576,6 +582,11 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn(dev,
+			 "SME is active, device will require DMA bounce buffers\n");
+
 	dev->coherent_dma_mask = mask;
 	return 0;
 }
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 14a7b9f..6829ff1 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -28,6 +28,12 @@ static inline bool sme_active(void)
 {
 	return false;
 }
+
+static inline u64 sme_dma_mask(void)
+{
+	return 0ULL;
+}
+
 #endif
 
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index c463067..aff9353 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -509,6 +509,9 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 	if (no_iotlb_memory)
 		panic("Can not allocate SWIOTLB buffer earlier and can't now provide you with the DMA bounce buffer");
 
+	WARN_ONCE(sme_active(),
+		  "SME is active and system is using DMA bounce buffers\n");
+
 	mask = dma_get_seg_boundary(hwdev);
 
 	tbl_dma_addr &= mask;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
