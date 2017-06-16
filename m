Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3A244041A
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:54:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p14so49719087pgc.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:54:44 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0076.outbound.protection.outlook.com. [104.47.40.76])
        by mx.google.com with ESMTPS id f19si2487680pgk.358.2017.06.16.11.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:54:43 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 25/36] swiotlb: Add warnings for use of bounce buffers
 with SME
Date: Fri, 16 Jun 2017 13:54:36 -0500
Message-ID: <20170616185435.18967.26665.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
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
 include/linux/dma-mapping.h |   11 +++++++++++
 include/linux/mem_encrypt.h |    8 ++++++++
 lib/swiotlb.c               |    3 +++
 3 files changed, 22 insertions(+)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4f3eece..ee2307e 100644
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
+	/* Since mask is unsigned, this can only be true if SME is active */
+	if (mask < sme_dma_mask())
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+
 	*dev->dma_mask = mask;
 	return 0;
 }
@@ -596,6 +602,11 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask))
 		return -EIO;
+
+	/* Since mask is unsigned, this can only be true if SME is active */
+	if (mask < sme_dma_mask())
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+
 	dev->coherent_dma_mask = mask;
 	return 0;
 }
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 837c66b..2168002 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -30,6 +30,14 @@ static inline bool sme_active(void)
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
  * The __sme_set() and __sme_clr() macros are useful for adding or removing
  * the encryption mask from a value (e.g. when dealing with pagetable
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
