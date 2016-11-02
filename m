Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAE206B02BA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:15:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l66so5297993pfl.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:15:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c186si4143634pga.181.2016.11.02.10.15.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 10:15:55 -0700 (PDT)
Subject: [mm PATCH v2 16/26] arch/openrisc: Add option to skip DMA sync as a
 part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:14:55 -0400
Message-ID: <20161102111452.79519.97790.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
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
