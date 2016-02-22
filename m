Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8408482F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:05:18 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id a4so183304071wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 14:05:18 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id d84si35330175wmc.17.2016.02.22.14.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 14:05:17 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] nvdimm: use 'u64' for pfn flags
Date: Mon, 22 Feb 2016 22:58:34 +0100
Message-Id: <1456178322-1728962-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Stuart Foster <smf.linux@ntlworld.com>, Julian Margetson <runaway@candw.ms>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

A recent bugfix changed pfn_t to always be 64-bit wide, but did not
change the code in pmem.c, which is now broken on 32-bit architectures
as reported by gcc:

In file included from ../drivers/nvdimm/pmem.c:28:0:
drivers/nvdimm/pmem.c: In function 'pmem_alloc':
include/linux/pfn_t.h:15:17: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
 #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))

This changes the intermediate pfn_flags in struct pmem_device to
be 64 bit wide as well, so they can store the flags correctly.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: db78c22230d0 ("mm: fix pfn_t vs highmem")
---
 drivers/nvdimm/pmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7edf31671dab..8d0b54670184 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -41,7 +41,7 @@ struct pmem_device {
 	phys_addr_t		phys_addr;
 	/* when non-zero this device is hosting a 'pfn' instance */
 	phys_addr_t		data_offset;
-	unsigned long		pfn_flags;
+	u64			pfn_flags;
 	void __pmem		*virt_addr;
 	size_t			size;
 	struct badblocks	bb;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
