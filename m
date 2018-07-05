Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D31BD6B0271
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:59:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v10-v6so4271559pfm.11
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:59:39 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n8-v6si5154556pgl.101.2018.07.04.23.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:59:38 -0700 (PDT)
Subject: [PATCH 07/13] nvdimm/pmem-dax: check the validity of the pointer pfn
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:49:40 -0700
Message-ID: <153077338038.40830.8894996377094953603.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Huaisheng Ye <yehs1@lenovo.com>, Jan Kara <jack@suse.cz>, vishal.l.verma@intel.com, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huaisheng Ye <yehs1@lenovo.com>

direct_access needs to check the validity of pointer pfn for NULL
assignment. If pfn equals to NULL, it doesn't need to calculate the value.

Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 tools/testing/nvdimm/pmem-dax.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/testing/nvdimm/pmem-dax.c b/tools/testing/nvdimm/pmem-dax.c
index b53596ad601b..d4cb5281b30e 100644
--- a/tools/testing/nvdimm/pmem-dax.c
+++ b/tools/testing/nvdimm/pmem-dax.c
@@ -33,7 +33,8 @@ long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 
 		*kaddr = pmem->virt_addr + offset;
 		page = vmalloc_to_page(pmem->virt_addr + offset);
-		*pfn = page_to_pfn_t(page);
+		if (pfn)
+			*pfn = page_to_pfn_t(page);
 		pr_debug_ratelimited("%s: pmem: %p pgoff: %#lx pfn: %#lx\n",
 				__func__, pmem, pgoff, page_to_pfn(page));
 
@@ -41,7 +42,8 @@ long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 	}
 
 	*kaddr = pmem->virt_addr + offset;
-	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
+	if (pfn)
+		*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
 	/*
 	 * If badblocks are present, limit known good range to the
