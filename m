Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67C52280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:06:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id s7so3241925pal.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:06:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a85si16604323pfe.100.2016.10.24.11.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:06:22 -0700 (PDT)
Subject: [net-next PATCH RFC 15/26] arch/openrisc: Add option to skip DMA
 sync as a part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:05:46 -0400
Message-ID: <20161024120546.16276.32687.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Jonas Bonn <jonas@southpole.se>, davem@davemloft.net, brouer@redhat.com

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
@@ -141,6 +141,9 @@
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
