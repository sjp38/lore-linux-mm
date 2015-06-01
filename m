Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 81EFC6B007B
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:56:35 -0400 (EDT)
Received: by obew15 with SMTP id w15so112317791obe.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:56:35 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id fy16si9391516oeb.33.2015.06.01.12.56.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:56:34 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v12 10/10] drivers/block/pmem: Map NVDIMM with ioremap_wt()
Date: Mon,  1 Jun 2015 13:36:33 -0600
Message-Id: <1433187393-22688-11-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
write back the contents of the CPU caches in case of a crash.

This patch changes to use ioremap_wt(), which provides uncached
writes but cached reads, for improving read performance.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Acked-by: Dan Williams <dan.j.williams@intel.com>
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
