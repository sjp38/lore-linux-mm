Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 654A228025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:36:35 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so39678069ita.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:36:35 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si5008548pay.339.2016.11.10.09.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:36:34 -0800 (PST)
Subject: [mm PATCH v3 13/23] arch/openrisc: Add option to skip DMA sync as a
 part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:24 -0500
Message-ID: <20161110113524.76501.87966.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Jonas Bonn <jonas@southpole.se>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/openrisc/kernel/dma.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index 140c991..906998b 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -141,6 +141,9 @@ or1k_map_page(struct device *dev, struct page *page,
 	unsigned long cl;
 	dma_addr_t addr = page_to_phys(page) + offset;
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return addr;
+
 	switch (dir) {
 	case DMA_TO_DEVICE:
 		/* Flush the dcache for the requested range */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
