Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2A88E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:35:42 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id l1so6445691wrn.3
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 00:35:42 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v126si27970199wmf.58.2019.01.18.00.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 00:35:40 -0800 (PST)
Date: Fri, 18 Jan 2019 09:35:39 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190118083539.GA30479@lst.de>
References: <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de> <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de> <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de> <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de> <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de> <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de> <20190115133558.GA29225@lst.de> <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de> <20190115151732.GA2325@lst.de> <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi Christian,

can you check if the debug printks in this patch trigger?

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 355d16acee6d..e46c9b64ec0d 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -118,8 +118,11 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
 			page = NULL;
 		}
 	}
-	if (!page)
+	if (!page) {
 		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
+		if (!page)
+			pr_warn("failed to allocate memory with gfp 0x%x\n", gfp);
+	}
 
 	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 		__free_pages(page, page_order);
@@ -139,6 +142,10 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
 		}
 	}
 
+	if (!page) {
+		pr_warn("failed to allocate DMA memory!\n");
+		dump_stack();
+	}
 	return page;
 }
 
