Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17B2D6B026D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:25:19 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so14101406plo.9
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 22:25:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m86-v6si10870832pfj.48.2018.07.10.22.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 22:25:18 -0700 (PDT)
Subject: [PATCH v4 8/8] mm: Fix exports that inadvertently make put_page()
 EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Jul 2018 22:15:19 -0700
Message-ID: <153128611970.2928.11310692420711601254.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153128607743.2928.4465435789810433432.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153128607743.2928.4465435789810433432.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Joe Gorse <jhgorse@gmail.com>, John Hubbard <jhubbard@nvidia.com>Joe Gorse <jhgorse@gmail.com>John Hubbard <jhubbard@nvidia.com>, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that all producers of dev_pagemap instances in the kernel are
properly converted to EXPORT_SYMBOL_GPL, fix up implicit consumers that
interact with dev_pagemap owners via put_page(). To reiterate,
dev_pagemap producers are EXPORT_SYMBOL_GPL because they adopt and
modify core memory management interfaces such that the dev_pagemap owner
can interact with all other kernel infrastructure and sub-systems
(drivers, filesystems, etc...) that consume page structures.

Fixes: e76384884344 ("mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS")
Reported-by: Joe Gorse <jhgorse@gmail.com>
Reported-by: John Hubbard <jhubbard@nvidia.com>
Tested-by: Joe Gorse <jhgorse@gmail.com>
Tested-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 16141b608b63..ecee37b44aa1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -330,7 +330,7 @@ EXPORT_SYMBOL_GPL(get_dev_pagemap);
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
 DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
-EXPORT_SYMBOL_GPL(devmap_managed_key);
+EXPORT_SYMBOL(devmap_managed_key);
 static atomic_t devmap_enable;
 
 /*
@@ -371,5 +371,5 @@ void __put_devmap_managed_page(struct page *page)
 	} else if (!count)
 		__put_page(page);
 }
-EXPORT_SYMBOL_GPL(__put_devmap_managed_page);
+EXPORT_SYMBOL(__put_devmap_managed_page);
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
