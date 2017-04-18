Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F12302806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:20:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s22so2769680pfs.0
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:20:29 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0073.outbound.protection.outlook.com. [104.47.33.73])
        by mx.google.com with ESMTPS id w8si301305pgc.31.2017.04.18.14.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:20:29 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 23/32] swiotlb: Add warnings for use of bounce buffers
 with SME
Date: Tue, 18 Apr 2017 16:20:19 -0500
Message-ID: <20170418212019.10190.24034.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

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
index 0637b4b..b406df2 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -26,6 +26,11 @@ static inline bool sme_active(void)
 	return !!sme_me_mask;
 }
 
+static inline u64 sme_dma_mask(void)
+{
+	return ((u64)sme_me_mask << 1) - 1;
+}
+
 void __init sme_early_encrypt(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_decrypt(resource_size_t paddr,
@@ -50,6 +55,12 @@ static inline bool sme_active(void)
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
index 0977317..f825870 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/kmemcheck.h>
 #include <linux/bug.h>
+#include <linux/mem_encrypt.h>
 
 /**
  * List of possible attributes associated with a DMA mapping. The semantics
@@ -577,6 +578,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn_ratelimited(dev,
+				     "SME is active, device will require DMA bounce buffers\n");
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -596,6 +602,11 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn_ratelimited(dev,
+				     "SME is active, device will require DMA bounce buffers\n");
+
 	dev->coherent_dma_mask = mask;
 	return 0;
 }
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 3c384d1..000c430 100644
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
index 74d6557..af3a268 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -509,6 +509,9 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 	if (no_iotlb_memory)
 		panic("Can not allocate SWIOTLB buffer earlier and can't now provide you with the DMA bounce buffer");
 
+	WARN_ONCE(sme_active(),
+		  "SME is active and the system is using DMA bounce buffers\n");
+
 	mask = dma_get_seg_boundary(hwdev);
 
 	tbl_dma_addr &= mask;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
