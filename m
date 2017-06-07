Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5964C6B03A7
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:17:44 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i65so6156758ioo.6
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:17:44 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0070.outbound.protection.outlook.com. [104.47.37.70])
        by mx.google.com with ESMTPS id 134si3364530itf.122.2017.06.07.12.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:17:43 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 25/34] swiotlb: Add warnings for use of bounce buffers
 with SME
Date: Wed, 07 Jun 2017 14:17:32 -0500
Message-ID: <20170607191732.28645.42876.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add warnings to let the user know when bounce buffers are being used for
DMA when SME is active.  Since the bounce buffers are not in encrypted
memory, these notifications are to allow the user to determine some
appropriate action - if necessary.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    8 ++++++++
 include/asm-generic/mem_encrypt.h  |    5 +++++
 include/linux/dma-mapping.h        |    9 +++++++++
 lib/swiotlb.c                      |    3 +++
 4 files changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index f1215a4..c7a2525 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -69,6 +69,14 @@ static inline bool sme_active(void)
 	return !!sme_me_mask;
 }
 
+static inline u64 sme_dma_mask(void)
+{
+	if (!sme_me_mask)
+		return 0ULL;
+
+	return ((u64)sme_me_mask << 1) - 1;
+}
+
 /*
  * The __sme_pa() and __sme_pa_nodebug() macros are meant for use when
  * writing to or comparing values from the cr3 register.  Having the
diff --git a/include/asm-generic/mem_encrypt.h b/include/asm-generic/mem_encrypt.h
index b55c3f9..fb02ff0 100644
--- a/include/asm-generic/mem_encrypt.h
+++ b/include/asm-generic/mem_encrypt.h
@@ -22,6 +22,11 @@ static inline bool sme_active(void)
 	return false;
 }
 
+static inline u64 sme_dma_mask(void)
+{
+	return 0ULL;
+}
+
 /*
  * The __sme_set() and __sme_clr() macros are useful for adding or removing
  * the encryption mask from a value (e.g. when dealing with pagetable
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4f3eece..e2c5fda 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/kmemcheck.h>
 #include <linux/bug.h>
+#include <linux/mem_encrypt.h>
 
 /**
  * List of possible attributes associated with a DMA mapping. The semantics
@@ -577,6 +578,10 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -596,6 +601,10 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask))
 		return -EIO;
+
+	if (sme_active() && (mask < sme_dma_mask()))
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+
 	dev->coherent_dma_mask = mask;
 	return 0;
 }
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 74d6557..f78906a 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -509,6 +509,9 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 	if (no_iotlb_memory)
 		panic("Can not allocate SWIOTLB buffer earlier and can't now provide you with the DMA bounce buffer");
 
+	if (sme_active())
+		pr_warn_once("SME is active and system is using DMA bounce buffers\n");
+
 	mask = dma_get_seg_boundary(hwdev);
 
 	tbl_dma_addr &= mask;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
