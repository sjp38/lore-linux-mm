Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 830FA6B57B8
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 05:32:24 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id p12so3639747wrt.17
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 02:32:24 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t8si4127097wmf.11.2018.11.30.02.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 02:32:23 -0800 (PST)
Date: Fri, 30 Nov 2018 11:32:22 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181130103222.GA23393@lst.de>
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: hch@lst.de, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hi Rui,

can you check if the patch below fixes the issue for you?

diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index 2e24fc87ed84..809797dbe169 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -392,7 +392,9 @@ static void pci_dma_dev_setup_dart(struct pci_dev *dev)
 
 static bool iommu_bypass_supported_dart(struct pci_dev *dev, u64 mask)
 {
-	return dart_is_u4 && dart_device_on_pcie(&dev->dev);
+	return dart_is_u4 &&
+		dart_device_on_pcie(&dev->dev) &&
+		mask >= DMA_BIT_MASK(40);
 }
 
 void __init iommu_init_early_dart(struct pci_controller_ops *controller_ops)
