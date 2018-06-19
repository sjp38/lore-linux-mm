Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A48106B0266
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:15:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a12-v6so9715603pfn.12
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:15:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z14-v6si13744202pgr.62.2018.06.18.23.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:15:18 -0700 (PDT)
Subject: [PATCH v3 8/8] mm: Fix exports that inadvertently make put_page()
 EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 23:05:20 -0700
Message-ID: <152938832086.17797.4538943238207602944.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Joe Gorse <jhgorse@gmail.com>, John Hubbard <jhubbard@nvidia.com>, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
