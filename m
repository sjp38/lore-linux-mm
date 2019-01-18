Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B96E8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:55:02 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e17so6723523wrw.13
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 04:55:02 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c12si42557516wri.0.2019.01.18.04.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 04:55:01 -0800 (PST)
Date: Fri, 18 Jan 2019 13:55:00 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190118125500.GA15657@lst.de>
References: <20190115133558.GA29225@lst.de> <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de> <20190115151732.GA2325@lst.de> <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de> <20190118083539.GA30479@lst.de> <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de> <20190118112842.GA9115@lst.de> <a2ca0118-5915-8b1c-7cfa-71cb4b43eaa6@xenosoft.de> <20190118121810.GA13327@lst.de> <eceebeda-0e18-00f6-06e7-def2eb0aa961@xenosoft.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="xB0nW4MQa6jZONgY"
Content-Disposition: inline
In-Reply-To: <eceebeda-0e18-00f6-06e7-def2eb0aa961@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org


--xB0nW4MQa6jZONgY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 18, 2019 at 01:46:46PM +0100, Christian Zigotzky wrote:
> Sorry, it's not possible to patch 
> '257002094bc5935dd63207a380d9698ab81f0775' with your patch. I also tried it 
> manually but without any success.

Weird:

hch@carbon:~/work/linux$ git checkout 257002094bc5935dd63207a380d9698ab81f0775
HEAD is now at 257002094bc5 powerpc/dma: use the dma-direct allocator for coherent platforms
hch@carbon:~/work/linux$ patch -p1 < dbg.diff 
patching file kernel/dma/direct.c

I've pushed the result to

git://git.infradead.org/users/hch/misc.git

as a new powerpc-dma.6-debug branch

--xB0nW4MQa6jZONgY
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="dbg.diff"

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
 

--xB0nW4MQa6jZONgY--
