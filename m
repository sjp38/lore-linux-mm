Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id D11B56B010C
	for <linux-mm@kvack.org>; Wed, 27 May 2015 11:39:25 -0400 (EDT)
Received: by oihd6 with SMTP id d6so10468497oih.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:39:25 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id ge3si11225701obb.10.2015.05.27.08.39.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:39:25 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with ioremap_wt()
Date: Wed, 27 May 2015 09:19:04 -0600
Message-Id: <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
write back the contents of the CPU caches in case of a crash.

This patch changes to use ioremap_wt(), which provides uncached
writes but cached reads, for improving read performance.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/block/pmem.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index eabf4a8..095dfaa 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -139,11 +139,11 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	}
 
 	/*
-	 * Map the memory as non-cachable, as we can't write back the contents
+	 * Map the memory as write-through, as we can't write back the contents
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = ioremap_nocache(pmem->phys_addr, pmem->size);
+	pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
