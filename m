Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8006B03B5
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:42:57 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c190so51746060ith.3
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:42:57 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0068.outbound.protection.outlook.com. [104.47.41.68])
        by mx.google.com with ESMTPS id k101si3407732ioo.276.2017.07.07.06.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 06:42:56 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v9 25/38] swiotlb: Add warnings for use of bounce buffers
 with SME
Date: Fri, 07 Jul 2017 08:42:49 -0500
Message-ID: <20170707134249.29711.3050.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add warnings to let the user know when bounce buffers are being used for
DMA when SME is active.  Since the bounce buffers are not in encrypted
memory, these notifications are to allow the user to determine some
appropriate action - if necessary.  Actions can range from utilizing an
IOMMU, replacing the device with another device that can support 64-bit
DMA, ignoring the message if the device isn't used much, etc.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 include/linux/dma-mapping.h |   13 +++++++++++++
 lib/swiotlb.c               |    3 +++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4f3eece..a156c40 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/kmemcheck.h>
 #include <linux/bug.h>
+#include <linux/mem_encrypt.h>
 
 /**
  * List of possible attributes associated with a DMA mapping. The semantics
@@ -554,6 +555,12 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #endif
 }
 
+static inline void dma_check_mask(struct device *dev, u64 mask)
+{
+	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+}
+
 #ifndef HAVE_ARCH_DMA_SUPPORTED
 static inline int dma_supported(struct device *dev, u64 mask)
 {
@@ -577,6 +584,9 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
+
+	dma_check_mask(dev, mask);
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -596,6 +606,9 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
