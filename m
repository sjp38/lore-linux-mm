Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 977226B0081
	for <linux-mm@kvack.org>; Wed, 13 May 2015 17:25:44 -0400 (EDT)
Received: by oign205 with SMTP id n205so41778706oig.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 14:25:44 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id os7si2377618obc.73.2015.05.13.14.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 14:25:44 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v9 10/10] drivers/block/pmem: Map NVDIMM with ioremap_wt()
Date: Wed, 13 May 2015 15:05:51 -0600
Message-Id: <1431551151-19124-11-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
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
